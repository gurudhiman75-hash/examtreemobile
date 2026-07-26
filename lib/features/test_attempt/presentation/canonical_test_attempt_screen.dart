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
import '../../exams/presentation/providers/exam_providers.dart';
import '../../results/presentation/providers/result_providers.dart';

enum QuestionStatus {
  notVisited,
  notAnswered,
  answered,
  markedForReview,
  answeredAndMarkedForReview,
}

class QuestionState {
  QuestionState({
    this.selectedOptionIndex,
    this.status = QuestionStatus.notVisited,
  });

  int? selectedOptionIndex;
  QuestionStatus status;
}

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

  String? _attemptId;
  int _revision = 0;
  DateTime? _lastSavedAt;

  bool _initialising = true;
  bool _syncing = false;
  bool _syncFailed = false;
  bool _saveQueued = false;
  bool _submitting = false;
  Object? _startupError;

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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      unawaited(_saveSession());
    }
  }

  Future<void> _initialiseAttempt() async {
    _timer?.cancel();
    _periodicAutosave?.cancel();
    setState(() {
      _initialising = true;
      _startupError = null;
    });

    try {
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

      setState(() {
        _attemptId = session.id;
        _revision = session.revision;
        _lastSavedAt = session.savedAt;
        _syncFailed = false;
        if (session.state != null) {
          _restoreState(session.state!);
        }
        _initialising = false;
      });

      _startTimer();
      _periodicAutosave = Timer.periodic(
        const Duration(seconds: 30),
        (_) => unawaited(_saveSession()),
      );

      if (session.state != null && mounted) {
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining <= 0) {
        timer.cancel();
        if (!_submitting) unawaited(_submitAttempt());
        return;
      }
      setState(() {
        _secondsRemaining -= 1;
      });
    });
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
      flags[key] =
          questionState.status == QuestionStatus.markedForReview ||
          questionState.status == QuestionStatus.answeredAndMarkedForReview;
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
    );
  }

  void _scheduleAutosave() {
    _autosaveDebounce?.cancel();
    _autosaveDebounce = Timer(
      const Duration(milliseconds: 900),
      () => unawaited(_saveSession()),
    );
  }

  Future<bool> _saveSession({bool quiet = true}) async {
    final attemptId = _attemptId;
    if (attemptId == null || _initialising) return false;

    if (_syncing) {
      _saveQueued = true;
      return true;
    }

    var success = true;
    do {
      _saveQueued = false;
      if (mounted) {
        setState(() {
          _syncing = true;
        });
      }

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
        _saveQueued = false;
        success = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This test changed on another device. The latest saved progress was loaded.',
            ),
          ),
        );
      } catch (error) {
        if (!mounted) return false;
        setState(() {
          _syncFailed = true;
        });
        success = false;
        if (!quiet) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Progress was not saved: $error')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _syncing = false;
          });
        }
      }
    } while (_saveQueued && success && mounted);

    return success;
  }

  Future<void> _submitAttempt() async {
    if (_submitting || _attemptId == null) return;
    setState(() {
      _submitting = true;
    });

    var completed = false;
    try {
      final saved = await _saveSession(quiet: false);
      if (!saved || !mounted) return;

      final responses = _questions.asMap().entries.map((entry) {
        return AttemptResponsePayload(
          questionId: entry.value.id,
          selectedOption: _states[entry.key].selectedOptionIndex,
        );
      }).toList();
      final flags = <String, bool>{
        for (var i = 0; i < _questions.length; i++)
          _questions[i].id.toString():
              _states[i].status == QuestionStatus.markedForReview ||
              _states[i].status == QuestionStatus.answeredAndMarkedForReview,
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
      ref.invalidate(userResultsProvider);
      context.replace(
        '/review',
        extra: response.attemptId.isEmpty ? _attemptId! : response.attemptId,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to submit attempt: $error')),
      );
    } finally {
      if (mounted && !completed) {
        setState(() {
          _submitting = false;
        });
      }
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
    setState(() {
      _moveToQuestion(index);
    });
    _scheduleAutosave();
  }

  void _saveAndNext() {
    setState(() {
      final state = _states[_currentIndex];
      state.status = state.selectedOptionIndex == null
          ? QuestionStatus.notAnswered
          : QuestionStatus.answered;
      if (_currentIndex < _questions.length - 1) {
        _moveToQuestion(_currentIndex + 1);
      }
    });
    _scheduleAutosave();
  }

  void _markForReview() {
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
    setState(() {
      final state = _states[_currentIndex];
      state.selectedOptionIndex = null;
      state.status = QuestionStatus.notAnswered;
    });
    _scheduleAutosave();
  }

  void _showPalette() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, controller) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Text(
                        'Question Palette',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: GridView.builder(
                    controller: controller,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                    ),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      final status = _states[index].status;
                      final selected = index == _currentIndex;
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _goToQuestion(index);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _statusColour(context, status),
                            border: Border.all(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outlineVariant,
                              width: selected ? 3 : 1,
                            ),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text('${index + 1}'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
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

  @override
  Widget build(BuildContext context) {
    if (_initialising || _startupError != null) {
      return _buildInitialState();
    }

    final theme = Theme.of(context);
    final question = _questions[_currentIndex];
    final questionState = _states[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
              '$_formattedTime  •  Q ${_currentIndex + 1}/${_questions.length}',
              style: theme.textTheme.labelMedium,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: _syncing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Tooltip(
                    message: _syncFailed
                        ? 'Progress not synced'
                        : _lastSavedAt == null
                            ? 'Waiting to sync'
                            : 'Progress synced',
                    child: Icon(
                      _syncFailed ? Icons.cloud_off : Icons.cloud_done,
                      color: _syncFailed ? theme.colorScheme.error : null,
                    ),
                  ),
          ),
          IconButton(
            tooltip: 'Save and exit',
            onPressed: () async {
              await _saveSession(quiet: false);
              if (context.mounted) Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q${_currentIndex + 1}. ${question.text}',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...List.generate(question.options.length, (index) {
                    return RadioListTile<int>(
                      value: index,
                      groupValue: questionState.selectedOptionIndex,
                      title: Text(question.options[index]),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setState(() {
                          questionState.selectedOptionIndex = value;
                        });
                        _scheduleAutosave();
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _currentIndex == 0
                      ? null
                      : () => _goToQuestion(_currentIndex - 1),
                  child: const Text('Previous'),
                ),
                OutlinedButton(
                  onPressed: questionState.selectedOptionIndex == null
                      ? null
                      : _clearResponse,
                  child: const Text('Clear Response'),
                ),
                OutlinedButton(
                  onPressed: _markForReview,
                  child: const Text('Mark for Review'),
                ),
                FilledButton(
                  onPressed: _saveAndNext,
                  child: const Text('Save & Next'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: _showPalette,
              icon: const Icon(Icons.grid_view),
              label: const Text('Palette'),
            ),
            FilledButton.icon(
              onPressed: _submitting ? null : _submitAttempt,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(_submitting ? 'Submitting...' : 'Submit Test'),
            ),
          ],
        ),
      ),
    );
  }
}
