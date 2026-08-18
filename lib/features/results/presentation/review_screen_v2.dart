import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/result_model.dart';
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
            Icon(
              Icons.fact_check_outlined,
              size: 52,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
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
        const Divider(height: 1),
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
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final correct = questions.where((question) => question.isCorrect).length;
    final incorrect = questions
        .where((question) => question.isAnswered && !question.isCorrect)
        .length;
    final unanswered = questions.where((question) => !question.isAnswered).length;
    final metrics = <_MetricData>[
      _MetricData('$correct', 'Correct', Colors.green),
      _MetricData('$incorrect', 'Incorrect', theme.colorScheme.error),
      _MetricData('$unanswered', 'Unanswered', theme.colorScheme.outline),
      _MetricData('${result.accuracy.round()}%', 'Accuracy', theme.colorScheme.primary),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.testName.trim().isNotEmpty) ...[
            Text(
              result.testName,
              maxLines: textScale >= 1.5 ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = textScale >= 1.5 || constraints.maxWidth < 340;
              if (!compact) {
                return Row(
                  children: [
                    for (final metric in metrics)
                      Expanded(child: _OverviewMetric(data: metric)),
                  ],
                );
              }
              final width = (constraints.maxWidth - AppSpacing.sm) / 2;
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final metric in metrics)
                    SizedBox(width: width, child: _OverviewMetric(data: metric)),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: textScale >= 1.5 ? 58 : 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ReviewQuestionFilter.values.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final filter = ReviewQuestionFilter.values[index];
                final count = reviewQuestionCount(questions, filter);
                return ChoiceChip(
                  selected: selectedFilter == filter,
                  showCheckmark: false,
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

class _MetricData {
  const _MetricData(this.value, this.label, this.color);

  final String value;
  final String label;
  final Color color;
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '${data.label}: ${data.value}',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              data.value,
              style: theme.textTheme.titleMedium?.copyWith(
                color: data.color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
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
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
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
                      fontWeight: FontWeight.w800,
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
                          const SizedBox(width: AppSpacing.sm),
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
                child: LinearProgressIndicator(
                  value: (visiblePosition + 1) / visibleCount,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            key: const Key('review-question-scroll'),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
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
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Q${originalIndex + 1}. ${question.text}',
                  style: theme.textTheme.titleLarge?.copyWith(height: 1.4),
                ),
                const SizedBox(height: AppSpacing.xl),
                ...List.generate(
                  question.options.length,
                  (index) => _OptionReviewTile(
                    optionIndex: index,
                    question: question,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _ExplanationCard(explanation: question.explanation),
                const SizedBox(height: AppSpacing.xxl),
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
    final theme = Theme.of(context);
    final (label, color, icon) = switch (
      (question.isAnswered, question.isCorrect)
    ) {
      (false, _) => (
          'Unanswered',
          theme.colorScheme.outline,
          Icons.remove_circle_outline,
        ),
      (true, true) => ('Correct', Colors.green, Icons.check_circle_outline),
      (true, false) => (
          'Incorrect',
          theme.colorScheme.error,
          Icons.cancel_outlined,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
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
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall,
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

    var background = theme.colorScheme.surface;
    var border = theme.colorScheme.outlineVariant;
    var foreground = theme.colorScheme.onSurface;
    IconData? icon;
    String? annotation;

    if (isCorrect) {
      background = Colors.green.withValues(alpha: 0.1);
      border = Colors.green;
      foreground = Colors.green.shade800;
      icon = Icons.check_circle;
      annotation = isSelected ? 'Your answer · Correct' : 'Correct answer';
    } else if (isSelected) {
      background = theme.colorScheme.errorContainer.withValues(alpha: 0.55);
      border = theme.colorScheme.error;
      foreground = theme.colorScheme.error;
      icon = Icons.cancel;
      annotation = 'Your answer';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(
          color: border,
          width: isCorrect || isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
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
                  fontWeight: FontWeight.w800,
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
                        ? FontWeight.w600
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(icon, color: foreground),
          ],
        ],
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
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Explanation',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            explanation.trim().isEmpty
                ? 'No explanation was stored for this question.'
                : explanation,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
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
            Icon(
              Icons.task_alt_rounded,
              size: 56,
              color: theme.colorScheme.primary,
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
            OutlinedButton.icon(
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
                fontWeight: FontWeight.w800,
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
                  final color = _statusColor(context, question);
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
                          color: selected ? color : color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(
                            color: selected ? theme.colorScheme.primary : color,
                            width: selected ? 3 : 1,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${originalIndex + 1}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: selected ? Colors.white : color,
                              fontWeight: FontWeight.w800,
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

String _statusLabel(ResultQuestionReview question) {
  if (!question.isAnswered) return 'unanswered';
  if (question.isCorrect) return 'correct';
  return 'incorrect';
}

Color _statusColor(BuildContext context, ResultQuestionReview question) {
  if (!question.isAnswered) return Theme.of(context).colorScheme.outline;
  if (question.isCorrect) return Colors.green;
  return Theme.of(context).colorScheme.error;
}

String _formatDuration(int seconds) {
  final safeSeconds = seconds < 0 ? 0 : seconds;
  final minutes = safeSeconds ~/ 60;
  final remainder = safeSeconds % 60;
  if (minutes == 0) return '${remainder}s';
  return '${minutes}m ${remainder.toString().padLeft(2, '0')}s';
}
