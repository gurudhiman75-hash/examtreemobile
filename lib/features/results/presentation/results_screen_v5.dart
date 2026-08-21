import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/result_model.dart';
import '../../../core/theme/app_colors.dart';
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
    return SafeArea(
      child: resultsAsync.when(
        loading: () => const _ResultsLoadingView(),
        error: (error, stackTrace) => NetworkFailureView(
          error: error,
          fallbackTitle: 'Unable to load your attempt history',
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
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            sliver: SliverList.list(
              children: [
                if (results.isEmpty)
                  _EmptyResults(onExplore: () => context.go('/exams'))
                else ...[
                  _PerformanceHero(
                    key: const Key('results-performance-snapshot'),
                    summary: summary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _HistoryToolsIntro(
                    hasFilters: _hasFilters,
                    onReset: _resetFilters,
                  ),
                  const SizedBox(height: AppSpacing.sm),
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

class _PerformanceHero extends StatelessWidget {
  const _PerformanceHero({super.key, required this.summary});

  final ResultHistorySummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final average = summary.averageScore.clamp(0, 100).toDouble();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6D4AE8), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR PERFORMANCE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
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
                      color: Colors.white,
                    ),
                    Center(
                      child: Text(
                        '${average.round()}%',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
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
                      'Average score',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${summary.totalAttempts} ${summary.totalAttempts == 1 ? 'attempt' : 'attempts'} completed',
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
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
              final items = [
                _HeroMetric(
                  value: '${summary.bestScore.round()}%',
                  label: 'Best score',
                ),
                _HeroMetric(
                  value: '${summary.averageAccuracy.round()}%',
                  label: 'Accuracy',
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
                'Find an attempt',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Review mistakes before deciding what to retake.',
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
            child: const Text('Reset'),
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
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.25,
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
                    'Sort results',
                    style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final option in ResultSortOption.values)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(option.label),
                      trailing: option == value
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: Theme.of(sheetContext).colorScheme.primary,
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
    final percentage = result.percentageScore.clamp(0, 100).toDouble();
    final canReview = result.questionReview.isNotEmpty;
    final canRetake = result.examId.trim().isNotEmpty;
    final hasMistakes = result.incorrectCount > 0 || result.skippedCount > 0;
    final reviewLabel = hasMistakes ? 'Review mistakes' : 'Review answers';
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(22),
          boxShadow: _softShadow(),
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
                          result.testName.trim().isEmpty
                              ? 'Test result'
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
                              label: _formatDateCompact(result.calculatedAt),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (largeText)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _resultMetadata(result)
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
                  children: _resultMetadata(result)
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
                          icon: const Icon(Icons.replay_rounded),
                          label: const Text('Retake'),
                        )
                      : FilledButton.icon(
                          key: const Key('results-retake-primary'),
                          onPressed: canRetake
                              ? () => context.push(
                                    '/exam-details',
                                    extra: result.examId.trim(),
                                  )
                              : null,
                          icon: const Icon(Icons.replay_rounded),
                          label: const Text('Retake'),
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

  List<(IconData, String, Color)> _resultMetadata(Result result) {
    return [
      (
        Icons.track_changes_rounded,
        '${_formatNumber(result.accuracy)}% accuracy',
        AppColors.mint,
      ),
      (
        Icons.check_circle_outline_rounded,
        '${result.correctCount} correct',
        AppColors.mint,
      ),
      (
        Icons.cancel_outlined,
        '${result.incorrectCount} incorrect',
        AppColors.error,
      ),
      if (result.skippedCount > 0)
        (
          Icons.remove_circle_outline_rounded,
          '${result.skippedCount} skipped',
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
    final good = percentage >= 70;
    return Semantics(
      label: 'Score ${_formatNumber(percentage)} percent',
      child: Container(
        width: 62,
        height: 62,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: good ? AppColors.mintContainer : AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${_formatNumber(percentage)}%',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall?.copyWith(
            color: good
                ? AppColors.onMintContainer
                : AppColors.onPrimaryContainer,
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
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.fact_check_rounded,
              size: 30,
              color: AppColors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No completed attempts yet',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Complete your first test to unlock score history, accuracy and answer review.',
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
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 44),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No attempts match these filters',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
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
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
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

List<BoxShadow> _softShadow() => [
      BoxShadow(
        color: AppColors.shadow.withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 7),
      ),
    ];
