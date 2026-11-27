import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/result_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/network_failure_view.dart';
import '../../bookmarks/domain/question_bookmark.dart';
import '../../bookmarks/presentation/providers/bookmark_providers.dart';
import 'providers/result_providers.dart';
import 'review_question_filter.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key, required this.resultId});

  final String resultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(resultProvider(resultId));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Answer review'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF10264A),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: resultAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => NetworkFailureView(
          error: error,
          fallbackTitle: 'Unable to load this result',
          onRetry: () => ref.invalidate(resultProvider(resultId)),
        ),
        data: (result) => result.questionReview.isEmpty
            ? _ReviewLoadState(
                message:
                    'Question-level review is unavailable for this attempt.',
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
                color: const Color(0xFFFFD36B),
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
              result: widget.result,
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
    final unanswered = questions
        .where((question) => !question.isAnswered)
        .length;
    final summary = '$correct correct · $incorrect wrong · $unanswered skipped';
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;

    return Container(
      key: const Key('review-overview'),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE4E9F1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.testName.trim().isNotEmpty)
            Text(
              result.testName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                color: const Color(0xFF10264A),
                fontWeight: FontWeight.w800,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            summary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF5F6F82),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: largeText ? 56 : 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ReviewQuestionFilter.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (context, index) {
                final filter = ReviewQuestionFilter.values[index];
                final count = reviewQuestionCount(questions, filter);
                final selected = selectedFilter == filter;
                return ChoiceChip(
                  selected: selected,
                  showCheckmark: false,
                  side: BorderSide(
                    color: selected
                        ? const Color(0xFF0B3A6F)
                        : const Color(0xFFDCE5EF),
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF0B3A6F),
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    color: selected ? Colors.white : const Color(0xFF10264A),
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

class _QuestionReviewPane extends StatelessWidget {
  const _QuestionReviewPane({
    required this.result,
    required this.question,
    required this.originalIndex,
    required this.totalQuestions,
    required this.visiblePosition,
    required this.visibleCount,
    required this.onOpenPalette,
  });

  final Result result;
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
          margin: const EdgeInsets.fromLTRB(10, 0, 10, AppSpacing.sm),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE3E9F1)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10264A).withValues(alpha: .03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
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
                  final bookmark = _BookmarkQuestionButton(
                    result: result,
                    question: question,
                  );
                  if (!stack) {
                    return Row(
                      children: [
                        Expanded(child: title),
                        status,
                        const SizedBox(width: AppSpacing.xs),
                        bookmark,
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
                          bookmark,
                          palette,
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Semantics(
                label:
                    'Review progress: ${visiblePosition + 1} of $visibleCount',
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
              12,
              AppSpacing.xs,
              12,
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
    final (label, background, foreground, icon) = switch ((
      question.isAnswered,
      question.isCorrect,
    )) {
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
  const _OptionReviewTile({required this.optionIndex, required this.question});

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
        : Colors.white;
    final foreground = isCorrect
        ? AppColors.onMintContainer
        : isSelected
        ? AppColors.onRoseContainer
        : const Color(0xFF26384F);
    final border = isCorrect
        ? AppColors.mint.withValues(alpha: .18)
        : isSelected
        ? AppColors.rose.withValues(alpha: .18)
        : const Color(0xFFE3E9F1);

    String? annotation;
    IconData? icon;
    if (isCorrect) {
      annotation = isSelected ? 'Your answer · Correct' : 'Correct answer';
      icon = Icons.check_circle_rounded;
    } else if (isSelected) {
      annotation = 'Your answer';
      icon = Icons.cancel_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
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
              color: foreground.withValues(alpha: .09),
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
                        : FontWeight.w500,
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
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7E8FA)),
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
                  color: Color(0xFF0B5D96),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Explanation',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF164D7E),
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
              color: const Color(0xFF334E68),
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
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return Material(
      color: Colors.white,
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
              final next = FilledButton.icon(
                key: const Key('review-next-finish'),
                onPressed: canGoForward ? onForward : onFinish,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: const Color(0xFF073A6A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
                icon: Icon(
                  canGoForward
                      ? Icons.arrow_forward_rounded
                      : Icons.check_rounded,
                ),
                label: Text(canGoForward ? 'Next' : 'Finish'),
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
                          color: selected
                              ? colors.foreground
                              : colors.background,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${originalIndex + 1}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: selected
                                  ? Colors.white
                                  : colors.foreground,
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
    return (background: AppColors.mintContainer, foreground: AppColors.mint);
  }
  return (background: AppColors.roseContainer, foreground: AppColors.rose);
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


class _BookmarkQuestionButton extends ConsumerWidget {
  const _BookmarkQuestionButton({required this.result, required this.question});

  final Result result;
  final ResultQuestionReview question;

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final router = GoRouter.maybeOf(context);
    // Save the question with all its languages, not just the one on screen.
    var source = question;
    try {
      final raw = await ref.read(rawResultProvider(result.id).future);
      source = raw.questionReview.firstWhere(
        (item) =>
            QuestionBookmark.idFor(item) == QuestionBookmark.idFor(question),
        orElse: () => question,
      );
    } catch (_) {
      // Offline or unavailable: keep the version already on screen.
    }
    try {
      final saved = await ref.read(questionBookmarksProvider.notifier).toggle(
            question: source,
            testName: result.testName,
            attemptId: result.id,
          );
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(saved ? 'Saved to Bookmarks' : 'Removed from Bookmarks'),
            action: saved && router != null
                ? SnackBarAction(
                    label: 'View',
                    onPressed: () => router.push('/profile-bookmarks'),
                  )
                : null,
          ),
        );
    } catch (_) {
      messenger?.showSnackBar(
        const SnackBar(content: Text('Could not save this question. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(
      isQuestionBookmarkedProvider(QuestionBookmark.idFor(question)),
    );
    return IconButton(
      key: const Key('review-bookmark-question'),
      tooltip: saved ? 'Remove bookmark' : 'Bookmark this question',
      isSelected: saved,
      onPressed: () => _toggle(context, ref),
      icon: const Icon(Icons.bookmark_border_rounded),
      selectedIcon: const Icon(Icons.bookmark_rounded, color: Color(0xFF0B3A6F)),
    );
  }
}
