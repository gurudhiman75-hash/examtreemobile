// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/attempt_session_model.dart';
import '../../../core/models/exam_model.dart';
import '../../../core/models/question_model.dart' as model;
import '../../../core/providers/repository_providers.dart';
import '../../../core/repositories/api_attempt_session_repository.dart';
import '../../../core/repositories/api_exam_repository.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../data/local_attempt_draft_store.dart';
import '../../exams/presentation/providers/exam_providers.dart';
import '../../results/presentation/providers/result_providers.dart';
import '../domain/test_attempt_experience.dart';
import 'widgets/question_palette_sheet.dart';
import 'widgets/test_attempt_dialogs.dart';

class CanonicalTestAttemptScreen extends ConsumerWidget {
  const CanonicalTestAttemptScreen({
    super.key,
    required this.examId,
  });

  final String examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(examQuestionsProvider(examId));
    final examAsync = ref.watch(examDetailsProvider(examId));

    return Scaffold(
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ExamLoadError(error: error),
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(child: Text('No questions available'));
          }
          return examAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ExamLoadError(error: error),
            data: (exam) => _CanonicalAttemptBody(
              exam: exam,
              questions: questions,
            ),
          );
        },
      ),
    );
  }
}

class _ExamLoadError extends StatelessWidget {
  const _ExamLoadError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    if (error is ExamLoginRequiredException) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/login');
      });
      return const Center(child: Text('Sign in required. Redirecting...'));
    }
    if (error is ExamPaymentRequiredException) {
      return const Center(child: Text('Purchase required to access this test.'));
    }
    return Center(child: Text('Unable to load test: $error'));
  }
}

class _CanonicalAttemptBody extends ConsumerStatefulWidget {
  const _CanonicalAttemptBody({
    required this.exam,
    required this.questions,
  });

  final Exam exam;
  final List<model.Question> questions;

  @override
  ConsumerState<_CanonicalAttemptBody> createState() =>
      _CanonicalAttemptBodyState();
}

class _CanonicalAttemptBodyState extends ConsumerState<_CanonicalAttemptBody>
    with WidgetsBindingObserver {
  late final List<model.Question> _questions;
  late final List<QuestionState> _states;
  late final int _initialDurationSeconds;

  int _currentIndex = 0;
  late int _secondsRemaining;

  Timer? _timer;
  Timer? _autosaveDebounce;
  Timer? _periodicAutosave;
  Timer? _localCheckpoint;

  Future<bool>? _activeSave;
  DateTime? _backgroundedAt;
  int? _remainingAtBackground;
  bool _isForeground = true;
  bool _submissionPending = false;
  final Map<String, int> _questionTimeSecondsById = <String, int>{};

  String? _attemptId;
  int _revision = 0;
  DateTime? _lastSavedAt;

  bool _initialising = true;
  bool _syncing = false;
  bool _syncFailed = false;
  bool _saveQueued = false;
  bool _submitting = false;
  bool _timeExpired = false;
  Object? _startupError;
  final Set<int> _shownTimerWarnings = <int>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _questions = widget.questions;
    _states = List.generate(_questions.length, (_) => QuestionState());
    _initialDurationSeconds = widget.exam.durationInSeconds;
    _secondsRemaining = _initialDurationSeconds;
    if (_states.isNotEmpty) {
      _states.first.status = QuestionStatus.notAnswered;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialiseAttempt();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _autosaveDebounce?.cancel();
    _periodicAutosave?.cancel();
    _localCheckpoint?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _isForeground = false;
      _backgroundedAt ??= DateTime.now();
      _remainingAtBackground ??= _secondsRemaining;
      unawaited(_persistLocalDraft());
      unawaited(_saveSession());
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _isForeground = true;
      _applyBackgroundElapsed();
      unawaited(_persistLocalDraft());
      if (_secondsRemaining <= 0) {
        unawaited(_handleTimeExpired());
      } else {
        unawaited(_saveSession());
      }
    }
  }

  void _applyBackgroundElapsed() {
    final backgroundedAt = _backgroundedAt;
    final remainingAtBackground = _remainingAtBackground;
    _backgroundedAt = null;
    _remainingAtBackground = null;
    if (backgroundedAt == null || remainingAtBackground == null) return;

    final elapsed = DateTime.now().difference(backgroundedAt).inSeconds;
    final adjusted = (remainingAtBackground - elapsed).clamp(0, remainingAtBackground);
    if (adjusted < _secondsRemaining && mounted) {
      setState(() => _secondsRemaining = adjusted);
    }
  }

  String? get _currentUserId =>
      ref.read(firebaseAuthProvider).currentUser?.uid.trim();

  Future<void> _persistLocalDraft() async {
    final attemptId = _attemptId;
    final userId = _currentUserId;
    if (attemptId == null || userId == null || userId.isEmpty || _initialising) {
      return;
    }
    try {
      await ref.read(attemptDraftStoreProvider).write(
            LocalAttemptDraft(
              userId: userId,
              testId: widget.exam.id,
              attemptId: attemptId,
              revision: _revision,
              state: _buildState(),
              localSavedAt: DateTime.now(),
            ),
          );
    } catch (_) {
      // Server autosave remains canonical. Local storage is a resilience mirror.
    }
  }

  Future<void> _deleteLocalDraft() async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) return;
    try {
      await ref.read(attemptDraftStoreProvider).delete(
            userId: userId,
            testId: widget.exam.id,
          );
    } catch (_) {
      // A stale local draft is ignored if the server returns a different attempt.
    }
  }

  Future<void> _initialiseAttempt() async {
    _timer?.cancel();
    _periodicAutosave?.cancel();
    _localCheckpoint?.cancel();
    setState(() {
      _initialising = true;
      _startupError = null;
      _timeExpired = false;
      _submissionPending = false;
    });

    try {
      final userId = _currentUserId;
      final localDraft = userId == null || userId.isEmpty
          ? null
          : await ref.read(attemptDraftStoreProvider).read(
                userId: userId,
                testId: widget.exam.id,
              );
      final session = await ref
          .read(attemptSessionRepositoryProvider)
          .startOrResume(testId: widget.exam.id);
      if (!mounted) return;
      if (session.id.isEmpty) {
        throw const AttemptSessionRepositoryException(
          'The server did not create an attempt session.',
          code: 'ATTEMPT_SESSION_MISSING',
        );
      }

      final recovered = recoverableLocalDraft(
        local: localDraft,
        activeAttemptId: session.id,
        remoteState: session.state,
      );
      final restoredState = recovered?.state ?? session.state;

      setState(() {
        _attemptId = session.id;
        _revision = session.revision;
        _lastSavedAt = session.savedAt;
        _syncFailed = recovered != null;
        if (restoredState != null) {
          _restoreState(restoredState);
        }
        _initialising = false;
        _timeExpired = _secondsRemaining <= 0;
      });

      if (localDraft != null && localDraft.attemptId != session.id) {
        await _deleteLocalDraft();
      }

      _periodicAutosave = Timer.periodic(
        const Duration(seconds: 30),
        (_) => unawaited(_saveSession()),
      );
      _localCheckpoint = Timer.periodic(
        const Duration(seconds: 5),
        (_) => unawaited(_persistLocalDraft()),
      );

      if (_secondsRemaining <= 0) {
        unawaited(_handleTimeExpired());
      } else {
        _startTimer();
      }

      if (recovered != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unsynced progress was recovered from this device. Syncing it to ExamTree now.',
            ),
          ),
        );
        unawaited(_saveSession(quiet: false));
      } else if (session.state != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved progress restored from ExamTree.'),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _startupError = error;
        _initialising = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final threshold = currentTimerWarningThreshold(
        secondsRemaining: _secondsRemaining,
        alreadyShown: _shownTimerWarnings,
      );
      if (threshold != null) _showTimerWarning(threshold);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining <= 0) {
        timer.cancel();
        unawaited(_handleTimeExpired());
        return;
      }

      final previous = _secondsRemaining;
      final current = previous - 1;
      setState(() {
        _secondsRemaining = current;
        if (_isForeground) {
          final questionId = _questions[_currentIndex].id.toString();
          _questionTimeSecondsById[questionId] =
              (_questionTimeSecondsById[questionId] ?? 0) + 1;
        }
      });

      final threshold = crossedTimerWarningThreshold(
        previousSeconds: previous,
        currentSeconds: current,
        alreadyShown: _shownTimerWarnings,
      );
      if (threshold != null) _showTimerWarning(threshold);

      if (current <= 0) {
        timer.cancel();
        unawaited(_handleTimeExpired());
      }
    });
  }

  void _showTimerWarning(int threshold) {
    if (!mounted || _shownTimerWarnings.contains(threshold)) return;
    _shownTimerWarnings.add(threshold);
    final message = switch (threshold) {
      600 => '10 minutes remaining',
      300 => '5 minutes remaining',
      60 => '1 minute remaining. Finish your review now.',
      _ => '$threshold seconds remaining',
    };
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  Future<void> _handleTimeExpired() async {
    if ((_timeExpired && _submissionPending) || _submitting) return;
    setState(() {
      _timeExpired = true;
      _submissionPending = true;
    });
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('Time is over. Your test is being submitted.'),
          duration: Duration(seconds: 4),
        ),
      );
    await _submitAttempt(autoSubmit: true);
  }

  void _restoreState(AttemptSessionState state) {
    _currentIndex = state.currentQuestionIndex
        .clamp(0, _questions.length - 1)
        .toInt();
    _secondsRemaining = state.timeLeft
        .clamp(0, _initialDurationSeconds)
        .toInt();

    for (var i = 0; i < _questions.length; i++) {
      final key = _questions[i].id.toString();
      final answer = state.answers[key];
      final flagged = state.flags[key] ?? false;
      final questionState = _states[i];
      questionState.selectedOptionIndex = answer;
      if (flagged && answer != null) {
        questionState.status = QuestionStatus.answeredAndMarkedForReview;
      } else if (flagged) {
        questionState.status = QuestionStatus.markedForReview;
      } else if (answer != null) {
        questionState.status = QuestionStatus.answered;
      } else {
        questionState.status = QuestionStatus.notVisited;
      }
    }

    if (_states[_currentIndex].status == QuestionStatus.notVisited) {
      _states[_currentIndex].status = QuestionStatus.notAnswered;
    }
    _questionTimeSecondsById
      ..clear()
      ..addAll(state.questionTimeSecondsById);
  }

  AttemptSessionState _buildState() {
    final answers = <String, int?>{};
    final flags = <String, bool>{};
    final visited = <int>[];

    for (var i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final questionState = _states[i];
      final key = question.id.toString();
      answers[key] = questionState.selectedOptionIndex;
      flags[key] = _isMarked(questionState.status);
      if (questionState.status != QuestionStatus.notVisited) {
        visited.add(question.id);
      }
    }

    return AttemptSessionState(
      testId: widget.exam.id,
      testName: widget.exam.title,
      category: widget.exam.category,
      currentQuestionIndex: _currentIndex,
      currentSectionIndex: 0,
      answers: answers,
      flags: flags,
      timeLeft: _secondsRemaining,
      sectionTimeLeftByName: const <String, int>{},
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      attemptType: 'REAL',
      lockedSections: const <int>[],
      visitedQuestionIds: visited,
      questionTimeSecondsById: Map<String, int>.unmodifiable(
        _questionTimeSecondsById,
      ),
    );
  }

  void _scheduleAutosave() {
    unawaited(_persistLocalDraft());
    _autosaveDebounce?.cancel();
    _autosaveDebounce = Timer(
      const Duration(milliseconds: 900),
      () => unawaited(_saveSession()),
    );
  }

  Future<bool> _saveSession({bool quiet = true}) async {
    final attemptId = _attemptId;
    if (attemptId == null || _initialising) return false;

    await _persistLocalDraft();
    final activeSave = _activeSave;
    if (activeSave != null) {
      _saveQueued = true;
      return activeSave;
    }

    final future = _performSaveCycle(attemptId: attemptId, quiet: quiet);
    _activeSave = future;
    try {
      return await future;
    } finally {
      if (identical(_activeSave, future)) _activeSave = null;
    }
  }

  Future<bool> _performSaveCycle({
    required String attemptId,
    required bool quiet,
  }) async {
    var success = true;
    do {
      _saveQueued = false;
      if (mounted) setState(() => _syncing = true);

      try {
        final session = await ref
            .read(attemptSessionRepositoryProvider)
            .saveSession(
              attemptId: attemptId,
              expectedRevision: _revision,
              state: _buildState(),
            );
        if (!mounted) return false;
        setState(() {
          _revision = session.revision;
          _lastSavedAt = session.savedAt;
          _syncFailed = false;
        });
        await _persistLocalDraft();
      } on AttemptSessionConflict catch (conflict) {
        if (!mounted) return false;
        setState(() {
          _revision = conflict.latestSession.revision;
          _lastSavedAt = conflict.latestSession.savedAt;
          _syncFailed = false;
          if (conflict.latestSession.state != null) {
            _restoreState(conflict.latestSession.state!);
          }
        });
        await _persistLocalDraft();
        _saveQueued = false;
        success = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This test changed on another device. The latest server progress was loaded.',
            ),
          ),
        );
      } catch (error) {
        if (!mounted) return false;
        setState(() => _syncFailed = true);
        success = false;
        if (!quiet) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Progress is saved on this device but has not reached ExamTree yet.',
              ),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _syncing = false);
      }
    } while (_saveQueued && success && mounted);

    return success;
  }

  Future<void> _requestSubmit() async {
    if (_submitting || _timeExpired) return;
    final summary = AttemptSubmissionSummary.fromStates(_states);
    final decision = await showDialog<SubmissionDecision>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SubmissionSummaryDialog(
        summary: summary,
        testName: widget.exam.title,
      ),
    );
    if (!mounted || decision == null || decision == SubmissionDecision.cancel) {
      return;
    }
    if (decision == SubmissionDecision.reviewUnanswered) {
      final index = _states.indexWhere(
        (state) => matchesPaletteFilter(
          state.status,
          PaletteFilter.unanswered,
        ),
      );
      if (index >= 0) _goToQuestion(index);
      return;
    }
    await _submitAttempt();
  }

  Future<void> _submitAttempt({bool autoSubmit = false}) async {
    if (_submitting || _attemptId == null) return;
    setState(() {
      _submitting = true;
      if (autoSubmit) {
        _timeExpired = true;
        _submissionPending = true;
      }
    });

    var completed = false;
    try {
      final saved = await _saveSession(quiet: autoSubmit);
      if (!mounted) return;
      if (!saved && !autoSubmit) return;

      final responses = _questions.asMap().entries.map((entry) {
        final questionId = entry.value.id;
        return AttemptResponsePayload(
          questionId: questionId,
          selectedOption: _states[entry.key].selectedOptionIndex,
          timeTaken: _questionTimeSecondsById[questionId.toString()] ?? 0,
        );
      }).toList();
      final flags = <String, bool>{
        for (var i = 0; i < _questions.length; i++)
          _questions[i].id.toString(): _isMarked(_states[i].status),
      };

      final response = await ref
          .read(attemptSessionRepositoryProvider)
          .submitAttempt(
            attemptId: _attemptId!,
            testId: widget.exam.id,
            timeSpentMinutes:
                ((_initialDurationSeconds - _secondsRemaining) / 60).round(),
            responses: responses,
            flags: flags,
          );
      if (!mounted) return;

      completed = true;
      _timer?.cancel();
      _periodicAutosave?.cancel();
      _localCheckpoint?.cancel();
      await _deleteLocalDraft();
      ref.invalidate(userResultsProvider);
      if (!mounted) return;
      context.replace(
        '/review',
        extra: response.attemptId.isEmpty ? _attemptId! : response.attemptId,
      );
    } catch (_) {
      if (!mounted) return;
      await _persistLocalDraft();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            autoSubmit
                ? 'Time is over. Your answers are safe on this device; reconnect and retry submission.'
                : 'Unable to submit right now. Your answers remain saved; try again.',
          ),
        ),
      );
    } finally {
      if (mounted && !completed) {
        setState(() {
          _submitting = false;
          if (!autoSubmit) _submissionPending = false;
        });
      }
    }
  }

  Future<void> _confirmExit() async {
    if (_submitting || _timeExpired) return;
    final shouldLeave = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => ExitAttemptDialog(
            syncFailed: _syncFailed,
            syncing: _syncing,
          ),
        ) ??
        false;
    if (!shouldLeave || !mounted) return;

    final saved = await _saveSession(quiet: false);
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The test remains open because the latest progress could not be saved.',
          ),
        ),
      );
    }
  }

  String get _formattedTime {
    final hours = _secondsRemaining ~/ 3600;
    final minutes = (_secondsRemaining % 3600) ~/ 60;
    final seconds = _secondsRemaining % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool _isMarked(QuestionStatus status) {
    return status == QuestionStatus.markedForReview ||
        status == QuestionStatus.answeredAndMarkedForReview;
  }

  void _moveToQuestion(int index) {
    if (_states[_currentIndex].status == QuestionStatus.notVisited) {
      _states[_currentIndex].status = QuestionStatus.notAnswered;
    }
    _currentIndex = index;
    if (_states[_currentIndex].status == QuestionStatus.notVisited) {
      _states[_currentIndex].status = QuestionStatus.notAnswered;
    }
  }

  void _goToQuestion(int index) {
    if (_timeExpired || _submitting) return;
    setState(() => _moveToQuestion(index));
    _scheduleAutosave();
  }

  void _selectAnswer(int? value) {
    if (value == null || _timeExpired || _submitting) return;
    setState(() {
      final state = _states[_currentIndex];
      state.selectedOptionIndex = value;
      state.status = _isMarked(state.status)
          ? QuestionStatus.answeredAndMarkedForReview
          : QuestionStatus.answered;
    });
    _scheduleAutosave();
  }

  void _saveAndNext() {
    if (_timeExpired || _submitting) return;
    setState(() {
      final state = _states[_currentIndex];
      if (state.selectedOptionIndex == null) {
        state.status = _isMarked(state.status)
            ? QuestionStatus.markedForReview
            : QuestionStatus.notAnswered;
      } else {
        state.status = _isMarked(state.status)
            ? QuestionStatus.answeredAndMarkedForReview
            : QuestionStatus.answered;
      }
      if (_currentIndex < _questions.length - 1) {
        _moveToQuestion(_currentIndex + 1);
      }
    });
    _scheduleAutosave();
  }

  void _markForReview() {
    if (_timeExpired || _submitting) return;
    setState(() {
      final state = _states[_currentIndex];
      state.status = state.selectedOptionIndex == null
          ? QuestionStatus.markedForReview
          : QuestionStatus.answeredAndMarkedForReview;
      if (_currentIndex < _questions.length - 1) {
        _moveToQuestion(_currentIndex + 1);
      }
    });
    _scheduleAutosave();
  }

  void _clearResponse() {
    if (_timeExpired || _submitting) return;
    setState(() {
      final state = _states[_currentIndex];
      final wasMarked = _isMarked(state.status);
      state.selectedOptionIndex = null;
      state.status = wasMarked
          ? QuestionStatus.markedForReview
          : QuestionStatus.notAnswered;
    });
    _scheduleAutosave();
  }

  void _showPalette() {
    if (_timeExpired || _submitting) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => QuestionPaletteSheet(
        states: _states,
        currentIndex: _currentIndex,
        onQuestionSelected: _goToQuestion,
        statusColor: _statusColour,
      ),
    );
  }

  Color _statusColour(BuildContext context, QuestionStatus status) {
    switch (status) {
      case QuestionStatus.notVisited:
        return Theme.of(context).colorScheme.surface;
      case QuestionStatus.notAnswered:
        return Theme.of(context).colorScheme.errorContainer;
      case QuestionStatus.answered:
        return Colors.green.shade100;
      case QuestionStatus.markedForReview:
        return Colors.purple.shade100;
      case QuestionStatus.answeredAndMarkedForReview:
        return Colors.deepPurple.shade100;
    }
  }

  Color _timerBackground(ColorScheme colors) {
    if (_secondsRemaining <= 60) return colors.errorContainer;
    if (_secondsRemaining <= 300) return colors.tertiaryContainer;
    return colors.surfaceContainerHighest;
  }

  Color _timerForeground(ColorScheme colors) {
    if (_secondsRemaining <= 60) return colors.onErrorContainer;
    if (_secondsRemaining <= 300) return colors.onTertiaryContainer;
    return colors.onSurfaceVariant;
  }

  Widget _buildInitialState() {
    if (_initialising) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppSpacing.md),
              Text('Preparing your secure test session...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Unable to start test')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'The attempt session could not be created.\n\n$_startupError',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _initialiseAttempt,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionStatus(ThemeData theme) {
    if (_submitting) {
      return Material(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _timeExpired ? 'Time expired — submitting your test' : 'Submitting your test',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(Icons.lock_clock_outlined, color: theme.colorScheme.onErrorContainer),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Time expired. Answers are locked and submission is pending.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => unawaited(_submitAttempt(autoSubmit: true)),
              child: Text(
                'Retry submit',
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initialising || _startupError != null) {
      return _buildInitialState();
    }

    final theme = Theme.of(context);
    final question = _questions[_currentIndex];
    final questionState = _states[_currentIndex];
    final summary = AttemptSubmissionSummary.fromStates(_states);

    return WillPopScope(
      onWillPop: () async {
        await _confirmExit();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: AppSpacing.md,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.exam.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Question ${_currentIndex + 1} of ${_questions.length}',
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _timerBackground(theme.colorScheme),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: _timerForeground(theme.colorScheme),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _formattedTime,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: _timerForeground(theme.colorScheme),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: _syncFailed
                  ? 'Progress not saved. Retry.'
                  : _syncing
                      ? 'Saving progress'
                      : 'Progress saved',
              onPressed: _syncFailed
                  ? () => unawaited(_saveSession(quiet: false))
                  : null,
              icon: _syncing
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_syncFailed ? Icons.cloud_off : Icons.cloud_done),
            ),
            IconButton(
              tooltip: 'Save and exit',
              onPressed: _submitting || _timeExpired ? null : _confirmExit,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        body: Column(
          children: [
            SyncStatusBanner(
              syncing: _syncing,
              syncFailed: _syncFailed,
              lastSavedAt: _lastSavedAt,
              onRetry: () => unawaited(_saveSession(quiet: false)),
            ),
            if (_timeExpired || _submitting) _buildSubmissionStatus(theme),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Q${_currentIndex + 1}. ${question.text}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ...List.generate(question.options.length, (index) {
                        final selected =
                            questionState.selectedOptionIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Card(
                            elevation: 0,
                            color: selected
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                              side: BorderSide(
                                color: selected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outlineVariant,
                              ),
                            ),
                            child: RadioListTile<int>(
                              value: index,
                              groupValue: questionState.selectedOptionIndex,
                              title: Text(
                                question.options[index],
                                style: theme.textTheme.bodyLarge,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              onChanged: _timeExpired || _submitting
                                  ? null
                                  : _selectAnswer,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _currentIndex == 0 ||
                              _timeExpired ||
                              _submitting
                          ? null
                          : () => _goToQuestion(_currentIndex - 1),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                    OutlinedButton.icon(
                      onPressed: questionState.selectedOptionIndex == null ||
                              _timeExpired ||
                              _submitting
                          ? null
                          : _clearResponse,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          _timeExpired || _submitting ? null : _markForReview,
                      icon: const Icon(Icons.bookmark_border),
                      label: const Text('Review'),
                    ),
                    FilledButton.icon(
                      onPressed:
                          _timeExpired || _submitting ? null : _saveAndNext,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        _currentIndex == _questions.length - 1
                            ? 'Save answer'
                            : 'Save & next',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed:
                      _timeExpired || _submitting ? null : _showPalette,
                  icon: const Icon(Icons.grid_view),
                  label: Text('Palette · ${summary.totalUnanswered} left'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed:
                      _submitting || _timeExpired ? null : _requestSubmit,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(_submitting ? 'Submitting…' : 'Submit test'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
