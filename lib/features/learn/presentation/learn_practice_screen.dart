import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../preferences/domain/question_language.dart';
import '../../preferences/presentation/providers/question_language_providers.dart';
import '../data/learn_practice_catalog.dart';
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
    final standaloneTopic = learnPracticeTopicById(topicId);
    final subject = polityLearnSubjectFor(language);
    LearnLesson? lesson;
    if (standaloneTopic == null) {
      for (final candidate in subject.lessons) {
        if (candidate.id == topicId) {
          lesson = candidate;
          break;
        }
      }
    }

    final title = standaloneTopic?.title ?? lesson?.title;
    final target = standaloneTopic?.questionTarget ?? 20;
    final practiceTags =
        standaloneTopic?.practiceTags ?? lesson?.practiceTags ?? const <String>[];

    if (title == null) {
      return const Scaffold(
        body: Center(child: Text('Practice topic unavailable')),
      );
    }

    final request = LearnPracticeRequest(
      topicId: topicId,
      limit: target,
      tagQuery: practiceTags.join(','),
      fresh: fresh,
    );
    final questionsAsync = ref.watch(learnPracticeQuestionsProvider(request));

    return questionsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _PracticeLoadFailure(
        title: title,
        onRetry: () => ref.invalidate(
          learnPracticeQuestionsProvider(request),
        ),
      ),
      data: (questions) {
        if (questions.isEmpty) {
          return _PracticeLoadFailure(
            title: title,
            message:
                'Practice questions are not available for this topic yet.',
            onRetry: () => ref.invalidate(
              learnPracticeQuestionsProvider(request),
            ),
          );
        }
        return _LearnPracticeRunner(
          topicId: topicId,
          title: title,
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
  final _scrollController = ScrollController();

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
    await _save(
      status: LearnPracticeStatus.inProgress,
      currentQuestion: _index < widget.questions.length - 1 ? _index + 1 : _index,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    int? totalQuestions,
  }) async {
    await ref.read(learnPracticeProgressStoreProvider).write(
          LearnPracticeProgress(
            topicId: widget.topicId,
            status: status,
            currentQuestion: currentQuestion,
            totalQuestions: totalQuestions ?? widget.questions.length,
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

  Future<void> _submitEarly() async {
    final answered = _index + (_revealed ? 1 : 0);
    if (answered <= 0) return;

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Submit practice?'),
        content: Text(
          answered == widget.questions.length
              ? 'You have answered all questions. Submit and view your result?'
              : 'You have answered $answered of ${widget.questions.length} questions. Submit now and view your result?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep practicing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (shouldSubmit != true || !mounted) return;
    await _save(
      status: LearnPracticeStatus.completed,
      currentQuestion: answered,
      totalQuestions: answered,
    );
    if (!mounted) return;
    context.go(
      '/learn-practice-result?topic=${Uri.encodeQueryComponent(widget.topicId)}'
      '&correct=$_correct&total=$answered',
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

    Future<void> leavePractice() async {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/learn');
      }
    }

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && context.mounted) {
          context.go('/learn');
        }
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF10264A),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          key: const Key('learn-practice-back'),
          tooltip: 'Back',
          onPressed: leavePractice,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        titleSpacing: 4,
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            color: const Color(0xFF10264A),
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          TextButton(
            key: const Key('learn-practice-submit'),
            onPressed: (_index > 0 || _revealed) ? _submitEarly : null,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF073A6A),
            ),
            child: const Text(
              'Submit',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: const Color(0xFFEAF0F6),
            color: const Color(0xFFD6A63D),
          ),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(
                12,
                AppSpacing.md,
                12,
                AppSpacing.xl,
              ),
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF4FF),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'Question ${_index + 1} of ${widget.questions.length}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF0B5D96),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.timer_off_outlined, size: 17),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Untimed',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE3E9F1)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10264A).withValues(alpha: .04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    question.text,
                    key: const Key('learn-practice-question'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF162A48),
                      fontWeight: FontWeight.w800,
                      height: 1.42,
                      letterSpacing: -.15,
                    ),
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
        minimum: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: FilledButton(
          key: const Key('learn-practice-next'),
          onPressed: _revealed ? _next : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: const Color(0xFF073A6A),
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                const Color(0xFF073A6A).withValues(alpha: .32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w900),
          ),
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
    Color background = Colors.white;
    Color border = const Color(0xFFE3E9F1);
    Color accent = const Color(0xFF52708F);
    IconData? trailing;
    if (correct) {
      background = const Color(0xFFEAF8F1);
      border = const Color(0xFF6FC59A);
      accent = const Color(0xFF237A50);
      trailing = Icons.check_circle_rounded;
    } else if (incorrect) {
      background = const Color(0xFFFFEEF0);
      border = const Color(0xFFE79AA4);
      accent = const Color(0xFFA53B4C);
      trailing = Icons.cancel_rounded;
    } else if (selected) {
      background = const Color(0xFFEAF4FF);
      border = const Color(0xFF8FBCE8);
      accent = const Color(0xFF0B5D96);
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
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .10),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  String.fromCharCode(65 + index),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF334155),
                    height: 1.4,
                    fontWeight:
                        selected || correct || incorrect ? FontWeight.w700 : null,
                  ),
                ),
              ),
              if (trailing != null) Icon(trailing, color: accent),
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
    final foreground =
        correct ? const Color(0xFF237A50) : const Color(0xFFA53B4C);
    return Container(
      key: const Key('learn-practice-feedback'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: correct ? const Color(0xFFEAF8F1) : const Color(0xFFFFEEF0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: foreground.withValues(alpha: .16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .8),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  correct
                      ? Icons.check_rounded
                      : Icons.close_rounded,
                  color: foreground,
                  size: 20,
                ),
              ),
              const SizedBox(width: 9),
              Text(
                correct ? 'Correct' : 'Incorrect',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            explanation.isEmpty
                ? 'Explanation will be added by Question Studio.'
                : explanation,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF334155),
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
    );
  }
}
