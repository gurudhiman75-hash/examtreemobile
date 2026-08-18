import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/result_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_visual_components.dart';
import '../../../shared/widgets/network_failure_view.dart';
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
      body: SafeArea(
        child: resultsAsync.when(
          loading: () => const _ResultsLoadingView(),
          error: (error, stackTrace) => NetworkFailureView(
            error: error,
            fallbackTitle: 'Unable to load your attempt history',
            onRetry: () => ref.invalidate(userResultsProvider),
          ),
          data: (results) => _buildHistory(context, results),
        ),
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
                AppPageHeader(
                  eyebrow: 'PERFORMANCE',
                  title: 'Results',
                  subtitle: results.isEmpty
                      ? 'Completed attempts will collect here with score, accuracy and review access.'
                      : 'Use your real attempt history to review mistakes and see how performance is moving.',
                  leading: const AppHeaderIcon(icon: Icons.insights_outlined),
                  trailing: _hasFilters
                      ? TextButton(
                          onPressed: _resetFilters,
                          child: const Text('Reset'),
                        )
                      : null,
                  metrics: results.isEmpty
                      ? const <AppMetricData>[]
                      : [
                          AppMetricData(
                            value: '${summary.totalAttempts}',
                            label: 'Attempts',
                            icon: Icons.assignment_turned_in_outlined,
                          ),
                          AppMetricData(
                            value: '${summary.averageScore.round()}%',
                            label: 'Average score',
                            icon: Icons.score_outlined,
                          ),
                          AppMetricData(
                            value: '${summary.bestScore.round()}%',
                            label: 'Best score',
                            icon: Icons.emoji_events_outlined,
                          ),
                          AppMetricData(
                            value: '${summary.averageAccuracy.round()}%',
                            label: 'Accuracy',
                            icon: Icons.track_changes_outlined,
                          ),
                        ],
                ),
                if (results.isEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _EmptyResults(onExplore: () => context.go('/exams')),
                ] else ...[
                  const SizedBox(height: AppSpacing.md),
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
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length + 1,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final category =
                              index == 0 ? null : categories[index - 1];
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
                  const SizedBox(height: AppSpacing.xl),
                  AppSectionHeader(
                    title: 'Attempt history',
                    subtitle: filtered.length == results.length
                        ? '${results.length} completed ${results.length == 1 ? 'attempt' : 'attempts'}.'
                        : '${filtered.length} of ${results.length} shown.',
                    trailing: PopupMenuButton<ResultSortOption>(
                      tooltip: 'Sort results',
                      initialValue: _sort,
                      onSelected: (value) => setState(() => _sort = value),
                      itemBuilder: (context) => ResultSortOption.values
                          .map(
                            (option) => PopupMenuItem(
                              value: option,
                              child: Row(
                                children: [
                                  if (_sort == option) ...[
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.swap_vert_rounded, size: 18),
                            const SizedBox(width: AppSpacing.xs),
                            Text(_sort.label, style: theme.textTheme.labelLarge),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (filtered.isEmpty)
                    _FilteredResultsEmpty(onReset: _resetFilters)
                  else
                    ...filtered.map((result) => _ResultCard(result: result)),
                ],
              ],
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
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fact_check_outlined,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No completed attempts yet',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Complete your first test to unlock score history, accuracy and answer review.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: onExplore,
            icon: const Icon(Icons.assignment_outlined),
            label: const Text('Explore tests'),
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
              fontWeight: FontWeight.w800,
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
                            fontWeight: FontWeight.w700,
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
                  color: const Color(0xFF2E7D32),
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
                    onPressed: result.examId.trim().isEmpty
                        ? null
                        : () => context.push(
                              '/exam-details',
                              extra: result.examId.trim(),
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
    return Semantics(
      label: 'Score ${_formatNumber(percentage)} percent',
      child: SizedBox(
        width: 68,
        height: 68,
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
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
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
    return Semantics(
      label: '$label: $value',
      child: Container(
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
    return Semantics(
      label: '$label: $value',
      child: Column(
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
      ),
    );
  }
}

class _ResultsLoadingView extends StatelessWidget {
  const _ResultsLoadingView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        const AppPageHeader(
          eyebrow: 'PERFORMANCE',
          title: 'Results',
          subtitle: 'Loading your completed ExamTree attempts.',
          leading: AppHeaderIcon(icon: Icons.insights_outlined),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (var index = 0; index < 3; index++) ...[
          Container(
            height: 210,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
          ),
          if (index != 2) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

String _formatDate(DateTime value) {
  if (value.millisecondsSinceEpoch == 0) {
    return 'Submission date unavailable';
  }
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
