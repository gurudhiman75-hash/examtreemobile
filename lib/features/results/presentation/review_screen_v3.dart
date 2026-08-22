import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/result_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/network_failure_view.dart';
import '../../../shared/widgets/primary_button.dart';
import 'providers/result_providers.dart';
import 'review_question_filter.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key, required this.resultId});

  final String resultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(resultProvider(resultId));
    return Scaffold(
      appBar: AppBar(title: const Text('Answer review')),
      body: resultAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => NetworkFailureView(
          error: error,
          fallbackTitle: 'Unable to load this result',
          onRetry: () => ref.invalidate(resultProvider(resultId)),
        ),
        data: (result) => result.questionReview.isEmpty
            ? _ReviewLoadState(
                message: 'Question-level review is unavailable for this attempt.',
                onRetry: () => ref.invalidate(resultProvider(resultId)),
              )
            : _ReviewBody(result: result),
      ),
    );
  }
}

class _ReviewLoadState extends StatelessWidget {
  const _ReviewLoadState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.fact_check_outlined,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewBody extends StatefulWidget {
  const _ReviewBody({required this.result});

  final Result result;

  @override
  State<_ReviewBody> createState() => _ReviewBodyState();
}

class _ReviewBodyState extends State<_ReviewBody> {
  ReviewQuestionFilter _filter = ReviewQuestionFilter.all;
  int _visiblePosition = 0;

  List<ResultQuestionReview> get _questions => widget.result.questionReview;
  List<int> get _visibleIndexes => reviewQuestionIndexes(_questions, _filter);

  void _selectFilter(ReviewQuestionFilter filter) {
    if (_filter == filter) return;
    setState(() {
      _filter = filter;
      _visiblePosition = 0;
    });
  }

  void _move(int difference) {
    final next = _visiblePosition + difference;
    if (next < 0 || next >= _visibleIndexes.length) return;
    setState(() => _visiblePosition = next);
  }

  void _jumpToVisiblePosition(int position) {
    if (position < 0 || position >= _visibleIndexes.length) return;
    setState(() => _visiblePosition = position);
  }

  @override
  Widget build(BuildContext context) {
    final visibleIndexes = _visibleIndexes;
    return Column(
      children: [
        _ReviewOverview(
          result: widget.result,
          questions: _questions,
          selectedFilter: _filter,
          onFilterChanged: _selectFilter,
        ),
        if (visibleIndexes.isEmpty)
          Expanded(
            child: _EmptyFilterState(
              filter: _filter,
              onShowAll: () => _selectFilter(ReviewQuestionFilter.all),
            ),
          )
        else
          Expanded(
            child: _QuestionReviewPane(
              question: _questions[visibleIndexes[_visiblePosition]],
              originalIndex: visibleIndexes[_visiblePosition],
              totalQuestions: _questions.length,
              visiblePosition: _visiblePosition,
              visibleCount: visibleIndexes.length,
              onOpenPalette: () => _showPalette(context),
            ),
          ),
        if (visibleIndexes.isNotEmpty)
          _ReviewNavigation(
            canGoBack: _visiblePosition > 0,
            canGoForward: _visiblePosition < visibleIndexes.length - 1,
            onBack: () => _move(-1),
            onForward: () => _move(1),
            onFinish: () => Navigator.of(context).pop(),
          ),
      ],
    );
  }

  Future<void> _showPalette(BuildContext context) async {
    final position = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _QuestionPalette(
        questions: _questions,
        visibleIndexes: _visibleIndexes,
        selectedPosition: _visiblePosition,
        filter: _filter,
      ),
    );
    if (position != null && mounted) _jumpToVisiblePosition(position);
  }
}

class _ReviewOverview extends StatelessWidget {
  const _ReviewOverview({
    required this.result,
    required this.questions,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final Result result;
  final List<ResultQuestionReview> questions;
  final ReviewQuestionFilter selectedFilter;
  final ValueChanged<ReviewQuestionFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final correct = questions.where((question) => question.isCorrect).length;
    final incorrect = questions
        .where((question) => question.isAnswered && !question.isCorrect)
        .length;
    final unanswered = questions.where((question) => !question.isAnswered).length;

    return Container(
      key: const Key('review-overview'),
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ATTEMPT REVIEW',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          if (result.testName.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              result.testName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.onPrimaryContainer,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(context).scale(1);
              final compact = textScale >= 1.5 || constraints.maxWidth < 340;
              final metrics = [
                _OverviewMetric(
                  value: '$correct',
                  label: 'Correct',
                  background: AppColors.mintContainer,
                  foreground: AppColors.onMintContainer,
                ),
                _OverviewMetric(
                  value: '$incorrect',
                  label: 'Incorrect',
                  background: AppColors.roseContainer,
                  foreground: AppColors.onRoseContainer,
                ),
                _OverviewMetric(
                  value: '$unanswered',
                  label: 'Unanswered',
                  background: Colors.white.withValues(alpha: 0.75),
                  foreground: theme.colorScheme.onSurfaceVariant,
                ),
                _OverviewMetric(
                  value: '${result.accuracy.round()}%',
                  label: 'Accuracy',
                  background: AppColors.skyContainer,
                  foreground: AppColors.onSkyContainer,
                ),
              ];
              if (!compact) {
                return Row(
                  children: [
                    for (var index = 0; index < metrics.length; index++) ...[
                      if (index > 0) const SizedBox(width: AppSpacing.xs),
                      Expanded(child: metrics[index]),
                    ],
                  ],
                );
              }
              final width = (constraints.maxWidth - AppSpacing.sm) / 2;
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final metric in metrics)
                    SizedBox(width: width, child: metric),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: MediaQuery.textScalerOf(context).scale(1) >= 1.5 ? 58 : 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ReviewQuestionFilter.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (context, index) {
                final filter = ReviewQuestionFilter.values[index];
                final count = reviewQuestionCount(questions, filter);
                return ChoiceChip(
                  selected: selectedFilter == filter,
                  showCheckmark: false,
                  side: BorderSide.none,
                  backgroundColor: Colors.white.withValues(alpha: 0.72),
                  selectedColor: AppColors.primary,
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    color: selectedFilter == filter
                        ? Colors.white
                        : AppColors.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                  label: Text('${filter.label} $count'),
                  onSelected: (_) => onFilterChanged(filter),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.value,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String value;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 62),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionReviewPane extends StatelessWidget {
  const _QuestionReviewPane({
    required this.question,
    required this.originalIndex,
    required this.totalQuestions,
    required this.visiblePosition,
    required this.visibleCount,
    required this.onOpenPalette,
  });

  final ResultQuestionReview question;
  final int originalIndex;
  final int totalQuestions;
  final int visiblePosition;
  final int visibleCount;
  final VoidCallback onOpenPalette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final stack = textScale >= 1.45 || constraints.maxWidth < 340;
                  final title = Text(
                    'Question ${originalIndex + 1} of $totalQuestions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  );
                  final status = _QuestionStatusBadge(question: question);
                  final palette = IconButton.filledTonal(
                    key: const Key('review-open-palette'),
                    tooltip: 'Open question palette',
                    onPressed: onOpenPalette,
                    icon: const Icon(Icons.grid_view_rounded),
                  );
                  if (!stack) {
                    return Row(
                      children: [
                        Expanded(child: title),
                        status,
                        const SizedBox(width: AppSpacing.sm),
                        palette,
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: status,
                            ),
                          ),
                          palette,
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Semantics(
                label: 'Review progress: ${visiblePosition + 1} of $visibleCount',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (visiblePosition + 1) / visibleCount,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            key: const Key('review-question-scroll'),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _MetaChip(
                      icon: Icons.folder_outlined,
                      label: question.section,
                    ),
                    if (question.flagged)
                      const _MetaChip(
                        icon: Icons.flag_outlined,
                        label: 'Flagged',
                      ),
                    if (question.timeTakenSeconds != null)
                      _MetaChip(
                        icon: Icons.timer_outlined,
                        label: _formatDuration(question.timeTakenSeconds!),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Q${originalIndex + 1}. ${question.text}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ...List.generate(
                  question.options.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _OptionReviewTile(
                      optionIndex: index,
                      question: question,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _ExplanationCard(explanation: question.explanation),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionStatusBadge extends StatelessWidget {
  const _QuestionStatusBadge({required this.question});

  final ResultQuestionReview question;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground, icon) = switch (
      (question.isAnswered, question.isCorrect)
    ) {
      (false, _) => (
          'Unanswered',
          Theme.of(context).colorScheme.surfaceContainerHigh,
          Theme.of(context).colorScheme.onSurfaceVariant,
          Icons.remove_circle_outline,
        ),
      (true, true) => (
          'Correct',
          AppColors.mintContainer,
          AppColors.onMintContainer,
          Icons.check_circle_outline,
        ),
      (true, false) => (
          'Incorrect',
          AppColors.roseContainer,
          AppColors.onRoseContainer,
          Icons.cancel_outlined,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 30),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionReviewTile extends StatelessWidget {
  const _OptionReviewTile({
    required this.optionIndex,
    required this.question,
  });

  final int optionIndex;
  final ResultQuestionReview question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCorrect = optionIndex == question.correct;
    final isSelected = optionIndex == question.selected;
    final optionKey = optionIndex < question.optionKeys.length
        ? question.optionKeys[optionIndex]
        : String.fromCharCode(65 + optionIndex);

    final background = isCorrect
        ? AppColors.mintContainer
        : isSelected
            ? AppColors.roseContainer
            : theme.colorScheme.surfaceContainerLowest;
    final foreground = isCorrect
        ? AppColors.onMintContainer
        : isSelected
            ? AppColors.onRoseContainer
            : theme.colorScheme.onSurface;

    String? annotation;
    IconData? icon;
    if (isCorrect) {
      annotation = isSelected ? 'Your answer · Correct' : 'Correct answer';
      icon = Icons.check_circle_rounded;
    } else if (isSelected) {
      annotation = 'Your answer';
      icon = Icons.cancel_rounded;
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: foreground.withValues(alpha: 0.1),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  optionKey,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.options[optionIndex],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: foreground,
                      fontWeight: isCorrect || isSelected
                          ? FontWeight.w700
                          : FontWeight.normal,
                      height: 1.4,
                    ),
                  ),
                  if (annotation != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      annotation,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(icon, color: foreground),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({required this.explanation});

  final String explanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('review-explanation'),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 19,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Explanation',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            explanation.trim().isEmpty
                ? 'No explanation was stored for this question.'
                : explanation,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onPrimaryContainer,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewNavigation extends StatelessWidget {
  const _ReviewNavigation({
    required this.canGoBack,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
    required this.onFinish,
  });

  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 8,
      shadowColor: AppColors.shadow.withValues(alpha: 0.08),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stack = textScale >= 1.5 || constraints.maxWidth < 340;
              final previous = OutlinedButton.icon(
                key: const Key('review-previous'),
                onPressed: canGoBack ? onBack : null,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Previous'),
              );
              final next = PrimaryButton(
                key: const Key('review-next-finish'),
                text: canGoForward ? 'Next' : 'Finish',
                onPressed: canGoForward ? onForward : onFinish,
              );
              if (stack) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    next,
                    const SizedBox(height: AppSpacing.sm),
                    previous,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: previous),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: next),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyFilterState extends StatelessWidget {
  const _EmptyFilterState({required this.filter, required this.onShowAll});

  final ReviewQuestionFilter filter;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.mintContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 32,
                color: AppColors.mint,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No ${filter.label.toLowerCase()} questions',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Choose another filter to continue reviewing this attempt.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.tonalIcon(
              onPressed: onShowAll,
              icon: const Icon(Icons.list_alt_rounded),
              label: const Text('Show all questions'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionPalette extends StatelessWidget {
  const _QuestionPalette({
    required this.questions,
    required this.visibleIndexes,
    required this.selectedPosition,
    required this.filter,
  });

  final List<ResultQuestionReview> questions;
  final List<int> visibleIndexes;
  final int selectedPosition;
  final ReviewQuestionFilter filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requestedHeight = MediaQuery.sizeOf(context).height * 0.72;
    final height = requestedHeight.clamp(360.0, 620.0).toDouble();
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${filter.label} questions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${visibleIndexes.length} shown · tap a number to jump directly.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: GridView.builder(
                key: const Key('review-palette-grid'),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 68,
                  mainAxisExtent: 54,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                ),
                itemCount: visibleIndexes.length,
                itemBuilder: (context, position) {
                  final originalIndex = visibleIndexes[position];
                  final question = questions[originalIndex];
                  final colors = _statusColors(context, question);
                  final selected = position == selectedPosition;
                  return Semantics(
                    button: true,
                    selected: selected,
                    label:
                        'Question ${originalIndex + 1}, ${_statusLabel(question)}${selected ? ', current question' : ''}',
                    child: InkWell(
                      onTap: () => Navigator.pop(context, position),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected ? colors.foreground : colors.background,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${originalIndex + 1}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: selected ? Colors.white : colors.foreground,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

({Color background, Color foreground}) _statusColors(
  BuildContext context,
  ResultQuestionReview question,
) {
  if (!question.isAnswered) {
    return (
      background: Theme.of(context).colorScheme.surfaceContainerHigh,
      foreground: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
  if (question.isCorrect) {
    return (
      background: AppColors.mintContainer,
      foreground: AppColors.mint,
    );
  }
  return (
    background: AppColors.roseContainer,
    foreground: AppColors.rose,
  );
}

String _statusLabel(ResultQuestionReview question) {
  if (!question.isAnswered) return 'unanswered';
  if (question.isCorrect) return 'correct';
  return 'incorrect';
}

String _formatDuration(int seconds) {
  final safeSeconds = seconds < 0 ? 0 : seconds;
  final minutes = safeSeconds ~/ 60;
  final remainder = safeSeconds % 60;
  if (minutes == 0) return '${remainder}s';
  return '${minutes}m ${remainder.toString().padLeft(2, '0')}s';
}
