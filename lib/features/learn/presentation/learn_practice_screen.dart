import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../preferences/domain/question_language.dart';
import '../../preferences/presentation/providers/question_language_providers.dart';
import '../data/polity_learn_localizations.dart';
import '../domain/learn_lesson.dart';
import '../domain/learn_practice_models.dart';
import '../domain/learn_practice_question.dart';
import 'providers/learn_practice_providers.dart';

class LearnPracticeScreen extends ConsumerWidget {
  const LearnPracticeScreen({
    super.key,
    required this.topicId,
    this.fresh = false,
  });

  final String topicId;
  final bool fresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language =
        ref.watch(questionLanguageProvider).value ?? QuestionLanguage.english;
    final subject = polityLearnSubjectFor(language);
    LearnLesson? lesson;
    for (final candidate in subject.lessons) {
      if (candidate.id == topicId) {
        lesson = candidate;
        break;
      }
    }

    final resolvedLesson = lesson;
    if (resolvedLesson == null) {
      return const Scaffold(
        body: Center(child: Text('Practice topic unavailable')),
      );
    }

    const target = 20;
    final questionsAsync = ref.watch(
      learnPracticeQuestionsProvider(
        LearnPracticeRequest(
          topicId: topicId,
          limit: target,
          tagQuery: resolvedLesson.practiceTags.join(','),
          fresh: fresh,
        ),
      ),
    );

    return questionsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(resolvedLesson.title)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _PracticeLoadFailure(
        title: resolvedLesson.title,
        onRetry: () => ref.invalidate(
          learnPracticeQuestionsProvider(
            LearnPracticeRequest(
          topicId: topicId,
          limit: target,
          tagQuery: resolvedLesson.practiceTags.join(','),
          fresh: fresh,
        ),
          ),
        ),
      ),
      data: (questions) {
        if (questions.isEmpty) {
          return _PracticeLoadFailure(
            title: resolvedLesson.title,
            message:
                'Practice questions are not published for this topic yet. The lesson is available, but the learner Question Studio feed still needs this topic mapping.',
            onRetry: () => ref.invalidate(
              learnPracticeQuestionsProvider(
                LearnPracticeRequest(
          topicId: topicId,
          limit: target,
          tagQuery: resolvedLesson.practiceTags.join(','),
          fresh: fresh,
        ),
              ),
            ),
          );
        }
        return _LearnPracticeRunner(
          topicId: topicId,
          title: resolvedLesson.title,
          questions: questions.take(target).toList(growable: false),
        );
      },
    );
  }
}

class _PracticeLoadFailure extends StatelessWidget {
  const _PracticeLoadFailure({
    required this.title,
    required this.onRetry,
    this.message,
  });

  final String title;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 44),
              const SizedBox(height: AppSpacing.md),
              Text(
                message ??
                    'Unable to load practice questions right now. Your Learn progress is safe.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearnPracticeRunner extends ConsumerStatefulWidget {
  const _LearnPracticeRunner({
    required this.topicId,
    required this.title,
    required this.questions,
  });

  final String topicId;
  final String title;
  final List<LearnPracticeQuestion> questions;

  @override
  ConsumerState<_LearnPracticeRunner> createState() =>
      _LearnPracticeRunnerState();
}

class _LearnPracticeRunnerState extends ConsumerState<_LearnPracticeRunner> {
  var _index = 0;
  var _correct = 0;
  int? _selected;
  var _revealed = false;
  var _restoring = true;

  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      final saved = await ref
          .read(learnPracticeProgressStoreProvider)
          .read(widget.topicId);
      if (!mounted) return;
      setState(() {
        if (saved != null &&
            saved.status == LearnPracticeStatus.inProgress &&
            saved.totalQuestions == widget.questions.length) {
          _index = saved.currentQuestion
              .clamp(0, widget.questions.length - 1)
              .toInt();
          _correct = saved.correctAnswers;
        }
        _restoring = false;
      });
    });
  }

  Future<void> _choose(int index) async {
    if (_revealed) return;
    final question = widget.questions[_index];
    final correct = index == question.correctOptionIndex;
    setState(() {
      _selected = index;
      _revealed = true;
      if (correct) _correct += 1;
    });
    await _save(
      status: LearnPracticeStatus.inProgress,
      currentQuestion: _index < widget.questions.length - 1 ? _index + 1 : _index,
    );
  }

  Future<void> _next() async {
    if (!_revealed) return;
    if (_index == widget.questions.length - 1) {
      await _finish();
      return;
    }
    setState(() {
      _index += 1;
      _selected = null;
      _revealed = false;
    });
    await _save(
      status: LearnPracticeStatus.inProgress,
      currentQuestion: _index,
    );
  }

  Future<void> _save({
    required LearnPracticeStatus status,
    required int currentQuestion,
  }) async {
    await ref.read(learnPracticeProgressStoreProvider).write(
          LearnPracticeProgress(
            topicId: widget.topicId,
            status: status,
            currentQuestion: currentQuestion,
            totalQuestions: widget.questions.length,
            correctAnswers: _correct,
            updatedAt: DateTime.now(),
          ),
        );
    ref.invalidate(learnPracticeProgressProvider(widget.topicId));
    ref.invalidate(learnPracticeProgressListProvider);
  }

  Future<void> _finish() async {
    await _save(
      status: LearnPracticeStatus.completed,
      currentQuestion: widget.questions.length,
    );
    if (!mounted) return;
    context.go(
      '/learn-practice-result?topic=${Uri.encodeQueryComponent(widget.topicId)}'
      '&correct=$_correct&total=${widget.questions.length}',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_restoring) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final theme = Theme.of(context);
    final question = widget.questions[_index];
    final progress = (_index + 1) / widget.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              'Question ${_index + 1} of ${widget.questions.length} · Untimed',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress, minHeight: 5),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(
                  question.text,
                  key: const Key('learn-practice-question'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                for (var i = 0; i < question.options.length; i++) ...[
                  _PracticeOption(
                    index: i,
                    text: question.options[i],
                    selected: _selected == i,
                    correct: _revealed && i == question.correctOptionIndex,
                    incorrect: _revealed &&
                        _selected == i &&
                        i != question.correctOptionIndex,
                    enabled: !_revealed,
                    onTap: () => _choose(i),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (_revealed) ...[
                  const SizedBox(height: AppSpacing.md),
                  _FeedbackCard(
                    correct: _selected == question.correctOptionIndex,
                    explanation: question.explanation,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.md),
        child: FilledButton(
          key: const Key('learn-practice-next'),
          onPressed: _revealed ? _next : null,
          child: Text(
            _index == widget.questions.length - 1
                ? 'View result'
                : 'Next question',
          ),
        ),
      ),
    );
  }
}

class _PracticeOption extends StatelessWidget {
  const _PracticeOption({
    required this.index,
    required this.text,
    required this.selected,
    required this.correct,
    required this.incorrect,
    required this.enabled,
    required this.onTap,
  });

  final int index;
  final String text;
  final bool selected;
  final bool correct;
  final bool incorrect;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color background = theme.colorScheme.surfaceContainerLow;
    Color border = theme.colorScheme.outlineVariant;
    IconData? trailing;
    if (correct) {
      background = theme.colorScheme.secondaryContainer;
      border = theme.colorScheme.secondary;
      trailing = Icons.check_circle_rounded;
    } else if (incorrect) {
      background = theme.colorScheme.errorContainer;
      border = theme.colorScheme.error;
      trailing = Icons.cancel_rounded;
    } else if (selected) {
      background = theme.colorScheme.primaryContainer;
      border = theme.colorScheme.primary;
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: Key('learn-practice-option-$index'),
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 17,
                child: Text(String.fromCharCode(65 + index)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
                ),
              ),
              if (trailing != null) Icon(trailing),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.correct,
    required this.explanation,
  });

  final bool correct;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('learn-practice-feedback'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: correct
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            correct ? 'Correct' : 'Incorrect',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            explanation.isEmpty
                ? 'Explanation will be added by Question Studio.'
                : explanation,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
