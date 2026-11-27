import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/result_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/network_failure_view.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../promotions/domain/promotion_campaign.dart';
import '../../promotions/presentation/providers/promotion_providers.dart';
import '../../promotions/presentation/widgets/promotion_carousel.dart';
import 'providers/result_providers.dart';
import 'result_history_filter.dart';
import '../../../l10n/l10n.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  late final TextEditingController _searchController;
  String _query = '';
  String? _selectedCategory;
  ResultSortOption _sort = ResultSortOption.newest;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      _query.trim().isNotEmpty ||
      _selectedCategory != null ||
      _sort != ResultSortOption.newest;

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedCategory = null;
      _sort = ResultSortOption.newest;
    });
  }

  Future<void> _refresh() async {
    ref
      ..invalidate(userResultsProvider)
      ..invalidate(promotionsForPlacementProvider(PromotionPlacement.results));
    try {
      await ref.read(userResultsProvider.future);
    } catch (_) {
      // The provider owns its recoverable error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(userResultsProvider);
    return SafeArea(
      child: resultsAsync.when(
        loading: () => const _ResultsLoadingView(),
        error: (error, stackTrace) => NetworkFailureView(
          error: error,
          fallbackTitle: context.l10n.resultsHistoryLoadFailed,
          onRetry: () => ref.invalidate(userResultsProvider),
        ),
        data: (results) => _buildHistory(context, results),
      ),
    );
  }

  Widget _buildHistory(BuildContext context, List<Result> results) {
    final categories = resultCategories(results);
    final selectedCategory = categories.contains(_selectedCategory)
        ? _selectedCategory
        : null;
    final filtered = filterAndSortResults(
      results: results,
      query: _query,
      category: selectedCategory,
      sort: _sort,
    );
    final summary = ResultHistorySummary.fromResults(results);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              10,
              AppSpacing.sm,
              10,
              AppSpacing.xxl,
            ),
            sliver: SliverList.list(
              children: [
                if (results.isEmpty) ...[
                  _EmptyResults(onExplore: () => context.go('/exams')),
                  const SizedBox(height: AppSpacing.md),
                  const PromotionPlacementView(
                    placement: PromotionPlacement.results,
                    compact: true,
                  ),
                ] else ...[
                  _PerformanceHero(
                    key: const Key('results-performance-snapshot'),
                    summary: summary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const PromotionPlacementView(
                    placement: PromotionPlacement.results,
                    compact: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _HistoryToolsIntro(
                    hasFilters: _hasFilters,
                    onReset: _resetFilters,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Theme(
                    data: Theme.of(context).copyWith(
                      searchBarTheme: SearchBarThemeData(
                        elevation: const WidgetStatePropertyAll(0),
                        backgroundColor:
                            const WidgetStatePropertyAll(Colors.white),
                        side: const WidgetStatePropertyAll(
                          BorderSide(color: Color(0xFFDCE5EF)),
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                    child: SearchBar(
                    key: const Key('results-search'),
                    controller: _searchController,
                    hintText: context.l10n.resultsSearchHint,
                    leading: const Icon(Icons.search_rounded),
                    trailing: [
                      if (_query.isNotEmpty)
                        IconButton(
                          tooltip: context.l10n.clearSearch,
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                    ],
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  ),
                  if (categories.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _CategoryRail(
                      categories: categories,
                      selectedCategory: selectedCategory,
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  _SectionHeader(
                    title: context.l10n.resultsAttemptHistory,
                    subtitle: filtered.length == results.length
                        ? '${results.length} completed ${results.length == 1 ? 'attempt' : 'attempts'}.'
                        : '${filtered.length} of ${results.length} shown.',
                    trailing: _SortButton(
                      value: _sort,
                      onChanged: (value) => setState(() => _sort = value),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (filtered.isEmpty)
                    _FilteredResultsEmpty(onReset: _resetFilters)
                  else
                    ...filtered.map(
                      (result) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _ResultCard(result: result),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceHero extends StatelessWidget {
  const _PerformanceHero({super.key, required this.summary});

  final ResultHistorySummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final average = summary.averageScore.clamp(0, 100).toDouble();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF031B3A),
            Color(0xFF063A70),
            Color(0xFF0B5D96),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF062D5C).withValues(alpha: .14),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR PERFORMANCE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFFFFD36B),
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 82,
                height: 82,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: average / 100,
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      color: const Color(0xFFFFD36B),
                    ),
                    Center(
                      child: Text(
                        '${average.round()}%',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: const Color(0xFFFFD36B),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.resultsAverageScore,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.l10n.resultsAttemptsCompleted(summary.totalAttempts),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
              final items = [
                _HeroMetric(
                  value: '${summary.bestScore.round()}%',
                  label: context.l10n.resultsBestScore,
                ),
                _HeroMetric(
                  value: '${summary.averageAccuracy.round()}%',
                  label: context.l10n.resultAccuracy,
                ),
              ];
              if (largeText) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    items[0],
                    const SizedBox(height: AppSpacing.sm),
                    items[1],
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: items[0]),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: items[1]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.78),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryToolsIntro extends StatelessWidget {
  const _HistoryToolsIntro({
    required this.hasFilters,
    required this.onReset,
  });

  final bool hasFilters;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.resultsFindAttempt,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF10264A),
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.3,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                context.l10n.resultsFindHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (hasFilters)
          TextButton(
            key: const Key('results-reset'),
            onPressed: onReset,
            child: Text(context.l10n.reset),
          ),
      ],
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  });

  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    return SizedBox(
      height: largeText ? 58 : 42,
      child: ListView.separated(
        key: const Key('results-category-rail'),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = index == 0 ? null : categories[index - 1];
          final selected = category == selectedCategory;
          return ChoiceChip(
            label: Text(category ?? context.l10n.resultsAllExams),
            selected: selected,
            selectedColor: const Color(0xFF0B3A6F),
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected
                  ? const Color(0xFF0B3A6F)
                  : const Color(0xFFDCE5EF),
            ),
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF526274),
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
            onSelected: (_) => onChanged(category),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: const Color(0xFF10264A),
            fontWeight: FontWeight.w900,
            letterSpacing: -.3,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
    if (trailing == null) return copy;
    if (MediaQuery.textScalerOf(context).scale(1) > 1.5) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [copy, const SizedBox(height: AppSpacing.xs), trailing!],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: copy),
        const SizedBox(width: AppSpacing.sm),
        trailing!,
      ],
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.value, required this.onChanged});

  final ResultSortOption value;
  final ValueChanged<ResultSortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      key: const Key('results-sort'),
      onPressed: () async {
        final selected = await showModalBottomSheet<ResultSortOption>(
          context: context,
          showDragHandle: true,
          builder: (sheetContext) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.resultsSort,
                    style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final option in ResultSortOption.values)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_sortLabel(context, option)),
                      trailing: option == value
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: const Color(0xFF0B3A6F),
                            )
                          : null,
                      onTap: () => Navigator.pop(sheetContext, option),
                    ),
                ],
              ),
            ),
          ),
        );
        if (selected != null) onChanged(selected);
      },
      icon: const Icon(Icons.swap_vert_rounded, size: 18),
      label: Text(_sortLabel(context, value)),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final Result result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = result.percentageScore.clamp(0, 100).toDouble();
    final canReview = result.questionReview.isNotEmpty;
    final canRetake = result.examId.trim().isNotEmpty;
    final hasMistakes = result.incorrectCount > 0 || result.skippedCount > 0;
    final reviewLabel = hasMistakes
        ? context.l10n.resultsReviewMistakes
        : context.l10n.resultsReviewAnswers;
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE3E9F1)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10264A).withValues(alpha: .035),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                key: const Key('results-open-summary'),
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.push(
                  '/result-summary',
                  extra: result.attemptId,
                ),
                child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ScoreBadge(percentage: percentage),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.testName.trim().isEmpty
                              ? context.l10n.resultTestResult
                              : result.testName,
                          maxLines: largeText ? 4 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.22,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: [
                            if (result.category.trim().isNotEmpty)
                              _TextTag(label: result.category),
                            _TextTag(
                              label: _formatDateCompact(context, result.calculatedAt),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (largeText)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _resultMetadata(context, result)
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: _ResultMeta(
                            icon: item.$1,
                            label: item.$2,
                            color: item.$3,
                          ),
                        ),
                      )
                      .toList(growable: false),
                )
              else
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.xs,
                  children: _resultMetadata(context, result)
                      .map(
                        (item) => _ResultMeta(
                          icon: item.$1,
                          label: item.$2,
                          color: item.$3,
                        ),
                      )
                      .toList(growable: false),
                ),
              const SizedBox(height: AppSpacing.md),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stack = constraints.maxWidth < 290 || largeText;
                  final review = FilledButton.icon(
                    key: const Key('results-review-primary'),
                    onPressed: canReview
                        ? () => context.push('/review', extra: result.attemptId)
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF073A6A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    icon: const Icon(Icons.fact_check_outlined),
                    label: Text(reviewLabel),
                  );
                  final retake = canReview
                      ? OutlinedButton.icon(
                          key: const Key('results-retake-secondary'),
                          onPressed: canRetake
                              ? () => context.push(
                                    '/exam-details',
                                    extra: result.examId.trim(),
                                  )
                              : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF173A61),
                            side: const BorderSide(color: Color(0xFFD8E1EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          icon: const Icon(Icons.replay_rounded),
                          label: Text(context.l10n.resultsRetake),
                        )
                      : FilledButton.icon(
                          key: const Key('results-retake-primary'),
                          onPressed: canRetake
                              ? () => context.push(
                                    '/exam-details',
                                    extra: result.examId.trim(),
                                  )
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF073A6A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          icon: const Icon(Icons.replay_rounded),
                          label: Text(context.l10n.resultsRetake),
                        );
                  if (stack) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (canReview) ...[
                          review,
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        retake,
                      ],
                    );
                  }
                  if (!canReview) return retake;
                  return Row(
                    children: [
                      Expanded(child: review),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: retake),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<(IconData, String, Color)> _resultMetadata(
    BuildContext context,
    Result result,
  ) {
    return [
      (
        Icons.track_changes_rounded,
        context.l10n.resultsAccuracyPct(_formatNumber(result.accuracy)),
        AppColors.mint,
      ),
      (
        Icons.check_circle_outline_rounded,
        context.l10n.resultsCorrectCount(result.correctCount),
        AppColors.mint,
      ),
      (
        Icons.cancel_outlined,
        context.l10n.resultsIncorrectCount(result.incorrectCount),
        AppColors.error,
      ),
      if (result.skippedCount > 0)
        (
          Icons.remove_circle_outline_rounded,
          context.l10n.resultsSkippedCount(result.skippedCount),
          AppColors.onSurfaceVariant,
        ),
    ];
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.percentage});

  final double percentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: context.l10n.resultsScorePercentA11y(_formatNumber(percentage)),
      child: Container(
        width: 62,
        height: 62,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2FB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${_formatNumber(percentage)}%',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall?.copyWith(
            color: const Color(0xFF0B3A6F),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _TextTag extends StatelessWidget {
  const _TextTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _ResultMeta extends StatelessWidget {
  const _ResultMeta({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EDF3)),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.fact_check_rounded,
              size: 30,
              color: const Color(0xFF0B3A6F),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.resultsEmptyTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.resultsEmptyBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onExplore,
            icon: const Icon(Icons.assignment_outlined),
            label: Text(context.l10n.resultsExploreTests),
          ),
        ],
      ),
    );
  }
}

class _FilteredResultsEmpty extends StatelessWidget {
  const _FilteredResultsEmpty({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 44),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.resultsNoMatchTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.resultsNoMatchBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.restart_alt_rounded),
            label: Text(context.l10n.resultsResetFilters),
          ),
        ],
      ),
    );
  }
}

class _ResultsLoadingView extends StatelessWidget {
  const _ResultsLoadingView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget block(double height) => Container(
          height: height,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(22),
          ),
        );
    return SkeletonShimmer(
      child: ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        block(260),
        const SizedBox(height: AppSpacing.lg),
        block(56),
        const SizedBox(height: AppSpacing.xl),
        block(210),
        const SizedBox(height: AppSpacing.sm),
        block(210),
      ],
    ),
    );
  }
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

String _formatDateCompact(BuildContext context, DateTime value) {
  if (value.millisecondsSinceEpoch == 0) return context.l10n.dateUnavailable;
  return formatDayMonth(context, value.toLocal());
}

String _sortLabel(BuildContext context, ResultSortOption option) {
  final l10n = context.l10n;
  return switch (option) {
    ResultSortOption.newest => l10n.resultsSortNewest,
    ResultSortOption.highestScore => l10n.resultsSortHighestScore,
    ResultSortOption.highestAccuracy => l10n.resultsSortHighestAccuracy,
  };
}

