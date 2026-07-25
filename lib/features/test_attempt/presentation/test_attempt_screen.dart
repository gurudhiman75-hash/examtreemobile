// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../exams/presentation/providers/exam_providers.dart';
import '../../results/presentation/providers/result_providers.dart';
import 'providers/draft_providers.dart';
import '../../../../core/models/attempt_draft_model.dart';
import '../../../../core/models/exam_model.dart';
import '../../../../core/models/question_model.dart' as model;
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/repositories/attempt_draft_repository.dart';
import '../../../../core/repositories/api_exam_repository.dart';

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
    return Center(child: Text('Error: $error'));
  }
}

enum QuestionStatus {
  notVisited,
  notAnswered,
  answered,
  markedForReview,
  answeredAndMarkedForReview,
}

class QuestionState {
  int? selectedOptionIndex;
  QuestionStatus status;

  QuestionState({
    this.selectedOptionIndex,
    this.status = QuestionStatus.notVisited,
  });
}

class TestAttemptScreen extends ConsumerWidget {
  final String examId;
  const TestAttemptScreen({super.key, required this.examId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(examQuestionsProvider(examId));
    final examAsync = ref.watch(examDetailsProvider(examId));

    return Scaffold(
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _ExamLoadError(error: err),
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(child: Text('No questions available'));
          }
          return examAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => _ExamLoadError(error: err),
            data: (exam) =>
                _TestAttemptScreenBody(questions: questions, exam: exam),
          );
        },
      ),
    );
  }
}

class _TestAttemptScreenBody extends ConsumerStatefulWidget {
  final List<model.Question> questions;
  final Exam exam;

  const _TestAttemptScreenBody({required this.questions, required this.exam});

  @override
  ConsumerState<_TestAttemptScreenBody> createState() =>
      _TestAttemptScreenBodyState();
}

class _TestAttemptScreenBodyState extends ConsumerState<_TestAttemptScreenBody>
    with WidgetsBindingObserver {
  late final List<model.Question> _questions;
  late final List<QuestionState> _states;
  int _currentIndex = 0;

  Timer? _timer;
  Timer? _autosaveDebounce;
  Timer? _periodicAutosave;
  late int _secondsRemaining;
  late final int _initialDurationSeconds;
  String? _draftId;
  int? _draftVersion;
  bool _isSavingDraft = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _questions = widget.questions;
    _states = List.generate(_questions.length, (index) => QuestionState());
    _initialDurationSeconds = widget.exam.durationInSeconds;
    _secondsRemaining = _initialDurationSeconds;
    if (_states.isNotEmpty) {
      _states[0].status = QuestionStatus.notAnswered;
    }
    _startTimer();
    _periodicAutosave = Timer.periodic(const Duration(seconds: 30), (_) {
      _saveDraft();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDraft();
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
      _saveDraft(status: AttemptDraftStatus.paused);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        if (mounted && !_isSubmitting) {
          _submitAttempt();
        }
      }
    });
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

  Future<void> _loadDraft() async {
    try {
      final draft = await ref.read(activeDraftProvider(widget.exam.id).future);
      if (!mounted || draft == null) return;

      final resume = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Resume previous session?'),
          content: const Text('A saved attempt was found for this test.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Start fresh'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Resume'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      if (resume != true) {
        await ref.read(attemptDraftRepositoryProvider).deleteDraft(draft.draftId);
        ref.invalidate(activeDraftProvider(widget.exam.id));
        ref.invalidate(draftListProvider);
        return;
      }
      _restoreDraft(draft);
    } catch (_) {
      // Draft sync should not block starting an attempt.
    }
  }

  void _restoreDraft(AttemptDraft draft) {
    final state = draft.state;
    setState(() {
      _draftId = draft.draftId;
      _draftVersion = draft.version;
      _currentIndex = state.currentQuestionIndex
          .clamp(0, _questions.length - 1)
          .toInt();
      _secondsRemaining = state.timeLeft
          .clamp(0, _initialDurationSeconds)
          .toInt();

      for (var i = 0; i < _questions.length; i++) {
        final question = _questions[i];
        final questionKey = question.id.toString();
        final answer = state.answers[questionKey];
        final flagged = state.flags[questionKey] ?? false;
        _states[i].selectedOptionIndex = answer;
        if (flagged && answer != null) {
          _states[i].status = QuestionStatus.answeredAndMarkedForReview;
        } else if (flagged) {
          _states[i].status = QuestionStatus.markedForReview;
        } else if (answer != null) {
          _states[i].status = QuestionStatus.answered;
        } else {
          _states[i].status = QuestionStatus.notVisited;
        }
      }

      if (_states[_currentIndex].status == QuestionStatus.notVisited) {
        _states[_currentIndex].status = QuestionStatus.notAnswered;
      }
    });
  }

  AttemptDraftState _buildDraftState() {
    final answers = <String, int?>{};
    final flags = <String, bool>{};
    final visitedQuestionIds = <int>[];

    for (var i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final state = _states[i];
      final questionKey = question.id.toString();
      answers[questionKey] = state.selectedOptionIndex;
      flags[questionKey] =
          state.status == QuestionStatus.markedForReview ||
          state.status == QuestionStatus.answeredAndMarkedForReview;
      if (state.status != QuestionStatus.notVisited) {
        visitedQuestionIds.add(question.id);
      }
    }

    return AttemptDraftState(
      currentQuestionIndex: _currentIndex,
      currentSectionIndex: 0,
      answers: answers,
      flags: flags,
      timeLeft: _secondsRemaining,
      sectionTimeLeftByName: const {},
      lockedSections: const [],
      visitedQuestionIds: visitedQuestionIds,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  void _scheduleAutosave() {
    _autosaveDebounce?.cancel();
    _autosaveDebounce = Timer(const Duration(milliseconds: 900), () {
      _saveDraft();
    });
  }

  Future<void> _saveDraft({
    AttemptDraftStatus status = AttemptDraftStatus.inProgress,
    bool allowDuringSubmit = false,
  }) async {
    if (_isSavingDraft || (_isSubmitting && !allowDuringSubmit)) return;
    _isSavingDraft = true;
    try {
      final result = await ref
          .read(draftSaveProvider)
          .save(
            testId: widget.exam.id,
            testName: widget.exam.title,
            category: widget.exam.category,
            state: _buildDraftState(),
            expectedVersion: _draftVersion,
            status: status,
          );
      if (!mounted) return;
      _draftId = result.draftId;
      _draftVersion = result.version;
      ref.invalidate(activeDraftProvider(widget.exam.id));
      ref.invalidate(draftListProvider);
    } catch (_) {
      // Keep the local attempt usable if background sync fails.
    } finally {
      _isSavingDraft = false;
    }
  }

  Future<void> _submitAttempt() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    try {
      await _saveDraft(allowDuringSubmit: true);
      final responses = _questions.asMap().entries.map((entry) {
        final question = entry.value;
        final state = _states[entry.key];
        return AttemptDraftResponsePayload(
          questionId: question.id.toString(),
          selectedOption: state.selectedOptionIndex,
        );
      }).toList();

      final flags = <String, bool>{
        for (var i = 0; i < _questions.length; i++)
          _questions[i].id.toString():
              _states[i].status == QuestionStatus.markedForReview ||
              _states[i].status == QuestionStatus.answeredAndMarkedForReview,
      };

      final result = await ref
          .read(attemptDraftRepositoryProvider)
          .submitAttempt(
            testId: widget.exam.id,
            testName: widget.exam.title,
            category: widget.exam.category,
            timeSpent: ((_initialDurationSeconds - _secondsRemaining) / 60)
                .round(),
            responses: responses,
            flags: flags,
            draftId: _draftId,
            expectedDraftVersion: _draftVersion,
          );

      if (!mounted) return;
      ref.invalidate(activeDraftProvider(widget.exam.id));
      ref.invalidate(draftListProvider);
      ref.invalidate(userResultsProvider);
      context.replace(
        '/review',
        extra: result.attemptId.isEmpty ? 'attempt_1' : result.attemptId,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to submit attempt. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
      if (_states[_currentIndex].selectedOptionIndex != null) {
        _states[_currentIndex].status = QuestionStatus.answered;
      } else {
        _states[_currentIndex].status = QuestionStatus.notAnswered;
      }

      if (_currentIndex < _questions.length - 1) {
        _moveToQuestion(_currentIndex + 1);
      }
    });
    _scheduleAutosave();
  }

  void _markForReview() {
    setState(() {
      if (_states[_currentIndex].selectedOptionIndex != null) {
        _states[_currentIndex].status =
            QuestionStatus.answeredAndMarkedForReview;
      } else {
        _states[_currentIndex].status = QuestionStatus.markedForReview;
      }

      if (_currentIndex < _questions.length - 1) {
        _moveToQuestion(_currentIndex + 1);
      }
    });
    _scheduleAutosave();
  }

  void _clearResponse() {
    setState(() {
      _states[_currentIndex].selectedOptionIndex = null;
      _states[_currentIndex].status = QuestionStatus.notAnswered;
    });
    _scheduleAutosave();
  }

  void _showPalette() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question Palette',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                _buildLegend(context),
                const Divider(),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: AppSpacing.sm,
                          mainAxisSpacing: AppSpacing.sm,
                        ),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      return _buildPaletteItem(context, index);
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

  Widget _buildLegend(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        children: [
          _legendItem(context, QuestionStatus.answered, 'Answered'),
          _legendItem(context, QuestionStatus.notAnswered, 'Not Answered'),
          _legendItem(context, QuestionStatus.notVisited, 'Not Visited'),
          _legendItem(context, QuestionStatus.markedForReview, 'Marked'),
          _legendItem(
            context,
            QuestionStatus.answeredAndMarkedForReview,
            'Answered & Marked',
          ),
        ],
      ),
    );
  }

  Widget _legendItem(
    BuildContext context,
    QuestionStatus status,
    String label,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _statusIcon(context, status, size: 16),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildPaletteItem(BuildContext context, int index) {
    final status = _states[index].status;
    final isCurrent = index == _currentIndex;
    final theme = Theme.of(context);

    Color bgColor = theme.colorScheme.surface;
    Color borderColor = theme.colorScheme.outline;
    Color textColor = theme.colorScheme.onSurface;

    switch (status) {
      case QuestionStatus.notVisited:
        bgColor = theme.colorScheme.surface;
        borderColor = theme.colorScheme.outlineVariant;
        textColor = theme.colorScheme.onSurfaceVariant;
        break;
      case QuestionStatus.notAnswered:
        bgColor = theme.colorScheme.errorContainer;
        borderColor = theme.colorScheme.error;
        textColor = theme.colorScheme.error;
        break;
      case QuestionStatus.answered:
        bgColor = Colors.green.shade100;
        borderColor = Colors.green;
        textColor = Colors.green.shade900;
        break;
      case QuestionStatus.markedForReview:
        bgColor = Colors.purple.shade100;
        borderColor = Colors.purple;
        textColor = Colors.purple.shade900;
        break;
      case QuestionStatus.answeredAndMarkedForReview:
        bgColor = Colors.deepPurple.shade100;
        borderColor = Colors.deepPurple;
        textColor = Colors.deepPurple.shade900;
        break;
    }

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _goToQuestion(index);
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: isCurrent ? theme.colorScheme.primary : borderColor,
            width: isCurrent ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${index + 1}',
              style: TextStyle(
                color: textColor,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (status == QuestionStatus.answeredAndMarkedForReview)
              const Positioned(
                bottom: 2,
                right: 2,
                child: Icon(Icons.check_circle, size: 12, color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusIcon(
    BuildContext context,
    QuestionStatus status, {
    double size = 24,
  }) {
    Color bgColor;
    Color borderColor;

    switch (status) {
      case QuestionStatus.notVisited:
        bgColor = Theme.of(context).colorScheme.surface;
        borderColor = Theme.of(context).colorScheme.outlineVariant;
        break;
      case QuestionStatus.notAnswered:
        bgColor = Theme.of(context).colorScheme.errorContainer;
        borderColor = Theme.of(context).colorScheme.error;
        break;
      case QuestionStatus.answered:
        bgColor = Colors.green.shade100;
        borderColor = Colors.green;
        break;
      case QuestionStatus.markedForReview:
        bgColor = Colors.purple.shade100;
        borderColor = Colors.purple;
        break;
      case QuestionStatus.answeredAndMarkedForReview:
        bgColor = Colors.deepPurple.shade100;
        borderColor = Colors.deepPurple;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: status == QuestionStatus.answeredAndMarkedForReview
          ? Icon(Icons.check, size: size * 0.7, color: Colors.green)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentQuestion = _questions[_currentIndex];
    final currentState = _states[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Prevent accidental back
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exam Attempt', // You might want to fetch exam title too
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16),
                const SizedBox(width: 4),
                Text(
                  _formattedTime,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const Spacer(),
                Text(
                  'Q ${_currentIndex + 1}/${_questions.length}',
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              await _saveDraft(status: AttemptDraftStatus.paused);
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q${_currentIndex + 1}. ',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          currentQuestion.text,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...List.generate(currentQuestion.options.length, (index) {
                    final option = currentQuestion.options[index];
                    return RadioListTile<int>(
                      title: Text(option),
                      value: index,
                      groupValue: currentState.selectedOptionIndex,
                      activeColor: theme.colorScheme.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setState(() {
                          currentState.selectedOptionIndex = value;
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
                  onPressed: _currentIndex > 0
                      ? () => _goToQuestion(_currentIndex - 1)
                      : null,
                  child: const Text('Previous'),
                ),
                OutlinedButton(
                  onPressed: currentState.selectedOptionIndex != null
                      ? _clearResponse
                      : null,
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: _showPalette,
              icon: const Icon(Icons.grid_view),
              label: const Text('Palette'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              onPressed: _isSubmitting ? null : _submitAttempt,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(_isSubmitting ? 'Submitting...' : 'Submit Test'),
            ),
          ],
        ),
      ),
    );
  }
}

