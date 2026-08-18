import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/result_model.dart';
import '../../../core/theme/app_spacing.dart';
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
      // The provider owns its recoverable error state.
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
                _ResultsHeader(
                  hasFilters: _hasFilters,
                  onReset: _resetFilters,
                ),
                if (results.isEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _EmptyResults(onExplore: () => context.go('/exams')),
                ] else ...[
                  const SizedBox(height: AppSpacing.md),
                  _PerformanceSnapshot(summary: summary),
                  const SizedBox(height: AppSpacing.md),
                  SearchBar(
                    key: const Key('results-search'),
                    controller: _searchController,
                    hintText: 'Search tests or exam categories',
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
                    title: 'Attempt history',
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

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.hasFilters, required this.onReset});

  final bool hasFilters;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.insights_rounded, color: scheme.onPrimary, size: 22),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Results',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.35,
                ),
              ),
              Text(
                'Review attempts and act on what changed.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (hasFilters)
          TextButton(
            key: const Key('results-reset'),
            onPressed: onReset,
            child: const Text('Reset'),
          ),
      ],
    );
  }
}

class _PerformanceSnapshot extends StatelessWidget {
  const _PerformanceSnapshot({required this.summary});

  final ResultHistorySummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final metrics = [
      ('${summary.totalAttempts}', 'Attempts', Icons.assignment_turned_in_outlined),
      ('${summary.averageScore.round()}%', 'Average', Icons.insights_rounded),
      ('${summary.bestScore.round()}%', 'Best', Icons.emoji_events_outlined),
      ('${summary.averageAccuracy.round()}%', 'Accuracy', Icons.track_changes_rounded),
    ];

    return Container(
      key: const Key('results-performance-snapshot'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          final columns = constraints.maxWidth >= 520 && textScale <= 1.5 ? 4 : 2;
          const gap = AppSpacing.sm;
          final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: metrics
                .map(
                  (metric) => SizedBox(
                    width: width,
                    child: _SummaryMetric(
                      value: metric.$1,
                      label: metric.$2,
                      icon: metric.$3,
                    ),
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.value, required this.label, required this.icon});

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: scheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
    return SizedBox(
      height: 42,
      child: ListView.separated(
        key: const Key('results-category-rail'),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = index == 0 ? null : categories[index - 1];
          return ChoiceChip(
            label: Text(category ?? 'All exams'),
            selected: category == selectedCategory,
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
    final scheme = theme.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < 320 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.5;
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        );
        if (trailing == null) return copy;
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              copy,
              const SizedBox(height: AppSpacing.xs),
              trailing!,
            ],
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
      },
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
                    'Sort results',
                    style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...ResultSortOption.values.map(
                    (option) => RadioListTile<ResultSortOption>(
                      value: option,
                      groupValue: value,
                      title: Text(option.label),
                      onChanged: (option) => Navigator.pop(sheetContext, option),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        if (selected != null) onChanged(selected);
      },
      icon: const Icon(Icons.swap_vert_rounded, size: 18),
      label: Text(value.label),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final Result result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final percentage = result.percentageScore.clamp(0, 100).toDouble();
    final canReview = result.questionReview.isNotEmpty;
    final canRetake = result.examId.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScoreBadge(percentage: percentage),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.testName.trim().isEmpty ? 'Test result' : result.testName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          if (result.category.trim().isNotEmpty)
                            _TextTag(label: result.category),
                          _TextTag(label: _formatDateCompact(result.calculatedAt)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              children: [
                _ResultMeta(
                  icon: Icons.track_changes_rounded,
                  label: '${_formatNumber(result.accuracy)}% accuracy',
                  color: scheme.secondary,
                ),
                _ResultMeta(
                  icon: Icons.check_circle_outline_rounded,
                  label: '${result.correctCount} correct',
                  color: scheme.secondary,
                ),
                _ResultMeta(
                  icon: Icons.cancel_outlined,
                  label: '${result.incorrectCount} incorrect',
                  color: scheme.error,
                ),
                if (result.skippedCount > 0)
                  _ResultMeta(
                    icon: Icons.remove_circle_outline_rounded,
                    label: '${result.skippedCount} skipped',
                    color: scheme.onSurfaceVariant,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final textScale = MediaQuery.textScalerOf(context).scale(1);
                final stack = constraints.maxWidth < 290 || textScale > 1.5;
                final review = OutlinedButton.icon(
                  onPressed: canReview
                      ? () => context.push('/review', extra: result.attemptId)
                      : null,
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Review'),
                );
                final retake = FilledButton.icon(
                  onPressed: canRetake
                      ? () => context.push('/exam-details', extra: result.examId.trim())
                      : null,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Retake'),
                );
                if (stack) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      review,
                      const SizedBox(height: AppSpacing.sm),
                      retake,
                    ],
                  );
                }
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
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.percentage});

  final double percentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      label: 'Score ${_formatNumber(percentage)} percent',
      child: Container(
        width: 58,
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Text(
          '${_formatNumber(percentage)}%',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall?.copyWith(
            color: scheme.onPrimaryContainer,
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Text(
      label,
      style: theme.textTheme.labelSmall?.copyWith(
        color: scheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
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
    final theme = Theme.of(context);
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
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.fact_check_outlined, size: 46, color: scheme.outline),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No completed attempts yet',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Complete your first test to unlock score history, accuracy and answer review.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
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
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 44, color: scheme.outline),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No attempts match these filters',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Try another test name, category or sort order.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
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

class _ResultsLoadingView extends StatelessWidget {
  const _ResultsLoadingView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget block(double height) => Container(
          height: height,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        );
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        block(54),
        const SizedBox(height: AppSpacing.md),
        block(154),
        const SizedBox(height: AppSpacing.md),
        block(56),
        const SizedBox(height: AppSpacing.xl),
        block(190),
        const SizedBox(height: AppSpacing.sm),
        block(190),
      ],
    );
  }
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

String _formatDateCompact(DateTime value) {
  if (value.millisecondsSinceEpoch == 0) return 'Date unavailable';
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
  return '${local.day} ${months[local.month - 1]} ${local.year}';
}
