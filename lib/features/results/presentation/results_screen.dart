import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/result_model.dart';
import '../../../core/theme/app_spacing.dart';
import 'providers/result_providers.dart';
import 'result_history_filter.dart';

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
    ref.invalidate(userResultsProvider);
    try {
      await ref.read(userResultsProvider.future);
    } catch (_) {
      // The provider renders the canonical retry state.
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(userResultsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Results'),
        actions: [
          if (_hasFilters)
            TextButton(onPressed: _resetFilters, child: const Text('Reset')),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: resultsAsync.when(
        loading: () => const _ResultsStateView.loading(),
        error: (error, stackTrace) => _ResultsStateView.error(
          onRetry: () => ref.invalidate(userResultsProvider),
        ),
        data: (results) {
          if (results.isEmpty) {
            return _EmptyResults(
              onRefresh: _refresh,
              onExplore: () => context.go('/exams'),
            );
          }
          return _buildHistory(context, results);
        },
      ),
    );
  }

  Widget _buildHistory(BuildContext context, List<Result> results) {
    final theme = Theme.of(context);
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
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            sliver: SliverList.list(
              children: [
                _ResultsSummaryCard(summary: summary),
                const SizedBox(height: AppSpacing.lg),
                SearchBar(
                  controller: _searchController,
                  hintText: 'Search test or exam category',
                  leading: const Icon(Icons.search_rounded),
                  trailing: [
                    if (_query.isNotEmpty)
                      IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                  ],
                  onChanged: (value) => setState(() => _query = value),
                ),
                if (categories.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final category = index == 0 ? null : categories[index - 1];
                        return ChoiceChip(
                          label: Text(category ?? 'All exams'),
                          selected: category == selectedCategory,
                          onSelected: (_) {
                            setState(() => _selectedCategory = category);
                          },
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                _HistoryHeader(
                  visibleCount: filtered.length,
                  totalCount: results.length,
                  sort: _sort,
                  onSortChanged: (value) => setState(() => _sort = value),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (filtered.isEmpty)
                  _FilteredResultsEmpty(onReset: _resetFilters)
                else
                  ...filtered.map((result) => _ResultCard(result: result)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsSummaryCard extends StatelessWidget {
  const _ResultsSummaryCard({required this.summary});

  final ResultHistorySummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.76),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.insights_rounded, color: theme.colorScheme.onPrimary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Performance history',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Use completed attempts to spot progress and choose what to practise next.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.86),
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  value: '${summary.totalAttempts}',
                  label: 'Attempts',
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  value: '${summary.averageScore.round()}%',
                  label: 'Average',
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  value: '${summary.bestScore.round()}%',
                  label: 'Best score',
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  value: '${summary.averageAccuracy.round()}%',
                  label: 'Accuracy',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.78),
          ),
        ),
      ],
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({
    required this.visibleCount,
    required this.totalCount,
    required this.sort,
    required this.onSortChanged,
  });

  final int visibleCount;
  final int totalCount;
  final ResultSortOption sort;
  final ValueChanged<ResultSortOption> onSortChanged;

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
                'Attempt history',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                visibleCount == totalCount
                    ? '$totalCount completed ${totalCount == 1 ? 'attempt' : 'attempts'}'
                    : '$visibleCount of $totalCount shown',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<ResultSortOption>(
          tooltip: 'Sort results',
          initialValue: sort,
          onSelected: onSortChanged,
          itemBuilder: (context) => ResultSortOption.values
              .map(
                (option) => PopupMenuItem(
                  value: option,
                  child: Row(
                    children: [
                      if (sort == option) ...[
                        Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(option.label),
                    ],
                  ),
                ),
              )
              .toList(),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.swap_vert_rounded, size: 18),
                const SizedBox(width: AppSpacing.xs),
                Text(sort.label, style: theme.textTheme.labelLarge),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultsStateView extends StatelessWidget {
  const _ResultsStateView.loading() : onRetry = null;

  const _ResultsStateView.error({required this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = onRetry == null;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else ...[
          Icon(
            Icons.cloud_off_outlined,
            size: 56,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Unable to load your attempt history',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Check your connection and try again.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.onRefresh, required this.onExplore});

  final Future<void> Function() onRefresh;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
          Icon(
            Icons.insights_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No completed attempts yet',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Complete your first test to unlock score history, accuracy and answer review.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: FilledButton.icon(
              onPressed: onExplore,
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Explore tests'),
            ),
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
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No attempts match these filters',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Try another test name, category or sort order.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Reset filters'),
          ),
        ],
      ),
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

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.testName.trim().isEmpty
                            ? 'Test result'
                            : result.testName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (result.category.trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          result.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _formatDate(result.calculatedAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _ScoreBadge(percentage: percentage),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _MetricChip(
                  label: 'Correct',
                  value: result.correctCount,
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
                _MetricChip(
                  label: 'Incorrect',
                  value: result.incorrectCount,
                  icon: Icons.cancel_outlined,
                  color: theme.colorScheme.error,
                ),
                _MetricChip(
                  label: 'Unanswered',
                  value: result.skippedCount,
                  icon: Icons.remove_circle_outline,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _SummaryValue(
                    label: 'Raw score',
                    value: _formatNumber(result.rawScore),
                  ),
                ),
                Expanded(
                  child: _SummaryValue(
                    label: 'Accuracy',
                    value: '${_formatNumber(result.accuracy)}%',
                  ),
                ),
                Expanded(
                  child: _SummaryValue(
                    label: 'Questions',
                    value: '${result.totalQuestions}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: result.questionReview.isEmpty
                        ? null
                        : () => context.push(
                              '/review',
                              extra: result.attemptId,
                            ),
                    icon: const Icon(Icons.fact_check_outlined),
                    label: const Text('Review'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: result.examId.isEmpty
                        ? null
                        : () => context.push(
                              '/test-attempt',
                              extra: result.examId,
                            ),
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Retake'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.percentage});

  final double percentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
          Center(
            child: Text(
              '${_formatNumber(percentage)}%',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$label $value',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

String _formatDate(DateTime value) {
  if (value.millisecondsSinceEpoch == 0) return 'Submission date unavailable';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '${local.day} ${months[local.month - 1]} ${local.year}, '
      '$hour:${local.minute.toString().padLeft(2, '0')} $period';
}
