import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/exam_model.dart';
import '../../../core/theme/app_spacing.dart';
import 'exam_catalog_filter.dart';
import 'providers/exam_providers.dart';
import 'widgets/exam_card.dart';

class ExamsScreen extends ConsumerStatefulWidget {
  const ExamsScreen({super.key});

  @override
  ConsumerState<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends ConsumerState<ExamsScreen> {
  String _query = '';
  String? _selectedCategory;
  ExamAccessFilter _access = ExamAccessFilter.all;
  ExamSortOption _sort = ExamSortOption.recommended;

  Future<void> _refresh() async {
    await Future.wait([
      ref.refresh(availableExamsProvider.future),
      ref.refresh(inProgressExamsProvider.future),
    ]);
  }

  void _clearFilters() {
    setState(() {
      _query = '';
      _selectedCategory = null;
      _access = ExamAccessFilter.all;
      _sort = ExamSortOption.recommended;
    });
  }

  bool get _hasActiveFilters =>
      _query.trim().isNotEmpty ||
      _selectedCategory != null ||
      _access != ExamAccessFilter.all ||
      _sort != ExamSortOption.recommended;

  @override
  Widget build(BuildContext context) {
    final availableAsync = ref.watch(availableExamsProvider);
    final inProgressAsync = ref.watch(inProgressExamsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Discover tests'),
        actions: [
          if (_hasActiveFilters)
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Reset'),
            ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: availableAsync.when(
          loading: () => const _CatalogueStateView.loading(),
          error: (error, stackTrace) => _CatalogueStateView.error(
            message: 'We could not load the test catalogue.',
            detail: error.toString(),
            onRetry: () => ref.invalidate(availableExamsProvider),
          ),
          data: (availableTests) => _buildCatalogue(
            context,
            availableTests,
            inProgressAsync.value ?? const <Exam>[],
          ),
        ),
      ),
    );
  }

  Widget _buildCatalogue(
    BuildContext context,
    List<Exam> availableTests,
    List<Exam> inProgressTests,
  ) {
    final theme = Theme.of(context);
    final categories = examCategories(availableTests);
    final selectedCategory = categories.contains(_selectedCategory)
        ? _selectedCategory
        : null;
    final filteredTests = filterAndSortExams(
      exams: availableTests,
      query: _query,
      category: selectedCategory,
      access: _access,
      sort: _sort,
    );
    final freeCount = availableTests
        .where((exam) => exam.status.trim().toLowerCase() != 'paid')
        .length;

    return CustomScrollView(
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
              _DiscoveryHero(
                totalTests: availableTests.length,
                freeTests: freeCount,
                inProgressTests: inProgressTests.length,
              ),
              const SizedBox(height: AppSpacing.lg),
              SearchBar(
                hintText: 'Search test, exam or subject',
                leading: const Icon(Icons.search_rounded),
                trailing: [
                  if (_query.isNotEmpty)
                    IconButton(
                      tooltip: 'Clear search',
                      onPressed: () => setState(() => _query = ''),
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
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final category = index == 0 ? null : categories[index - 1];
                      final selected = category == selectedCategory;
                      return ChoiceChip(
                        label: Text(category ?? 'All exams'),
                        selected: selected,
                        onSelected: (_) {
                          setState(() => _selectedCategory = category);
                        },
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              _FilterToolbar(
                access: _access,
                sort: _sort,
                onAccessChanged: (value) => setState(() => _access = value),
                onSortChanged: (value) => setState(() => _sort = value),
              ),
              if (inProgressTests.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                _SectionHeader(
                  title: 'Continue where you left off',
                  subtitle: '${inProgressTests.length} active ${inProgressTests.length == 1 ? 'test' : 'tests'}',
                ),
                const SizedBox(height: AppSpacing.sm),
                ...inProgressTests.take(2).map(
                      (test) => ExamCard(
                        title: test.title,
                        subject: test.category,
                        description: test.description,
                        duration: '${test.durationInSeconds ~/ 60} min',
                        totalQuestions: test.totalQuestions,
                        difficulty: test.difficulty,
                        status: 'In Progress',
                        onTap: () =>
                            context.push('/test-attempt', extra: test.id),
                      ),
                    ),
              ],
              const SizedBox(height: AppSpacing.sm),
              _SectionHeader(
                title: 'Available tests',
                subtitle: filteredTests.length == availableTests.length
                    ? '${availableTests.length} ready to attempt'
                    : '${filteredTests.length} of ${availableTests.length} shown',
                trailing: PopupMenuButton<ExamSortOption>(
                  tooltip: 'Sort tests',
                  initialValue: _sort,
                  onSelected: (value) => setState(() => _sort = value),
                  itemBuilder: (context) => ExamSortOption.values
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
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.swap_vert_rounded, size: 18),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _sort.label,
                          style: theme.textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (filteredTests.isEmpty)
                _EmptyCatalogue(
                  hasFilters: _hasActiveFilters,
                  onReset: _clearFilters,
                )
              else
                ...filteredTests.map(
                  (test) => ExamCard(
                    title: test.title,
                    subject: test.category,
                    description: test.description,
                    duration: '${test.durationInSeconds ~/ 60} min',
                    totalQuestions: test.totalQuestions,
                    difficulty: test.difficulty,
                    status: test.status == 'paid' ? 'Paid' : 'Available',
                    onTap: () =>
                        context.push('/exam-details', extra: test.id),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DiscoveryHero extends StatelessWidget {
  const _DiscoveryHero({
    required this.totalTests,
    required this.freeTests,
    required this.inProgressTests,
  });

  final int totalTests;
  final int freeTests;
  final int inProgressTests;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Practise with purpose',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Choose a focused mock, continue an active test, or find the right paper by exam and difficulty.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.88),
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _HeroMetric(value: '$totalTests', label: 'tests'),
              _HeroMetric(value: '$freeTests', label: 'free'),
              _HeroMetric(value: '$inProgressTests', label: 'active'),
            ],
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
        color: theme.colorScheme.onPrimary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.84),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterToolbar extends StatelessWidget {
  const _FilterToolbar({
    required this.access,
    required this.sort,
    required this.onAccessChanged,
    required this.onSortChanged,
  });

  final ExamAccessFilter access;
  final ExamSortOption sort;
  final ValueChanged<ExamAccessFilter> onAccessChanged;
  final ValueChanged<ExamSortOption> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SegmentedButton<ExamAccessFilter>(
            showSelectedIcon: false,
            segments: ExamAccessFilter.values
                .map(
                  (value) => ButtonSegment(
                    value: value,
                    label: Text(value == ExamAccessFilter.all ? 'All' : value.label),
                  ),
                )
                .toList(),
            selected: {access},
            onSelectionChanged: (values) => onAccessChanged(values.first),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton.filledTonal(
          tooltip: 'Sort: ${sort.label}',
          onPressed: () async {
            final value = await showModalBottomSheet<ExamSortOption>(
              context: context,
              showDragHandle: true,
              builder: (context) => SafeArea(
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
                        'Sort tests',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...ExamSortOption.values.map(
                        (option) => RadioListTile<ExamSortOption>(
                          value: option,
                          groupValue: sort,
                          title: Text(option.label),
                          onChanged: (value) => Navigator.pop(context, value),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            if (value != null) onSortChanged(value);
          },
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

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
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _EmptyCatalogue extends StatelessWidget {
  const _EmptyCatalogue({required this.hasFilters, required this.onReset});

  final bool hasFilters;
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
            hasFilters ? Icons.search_off_rounded : Icons.event_busy_outlined,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            hasFilters ? 'No tests match these filters' : 'No tests available yet',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hasFilters
                ? 'Try another exam, access type or search phrase.'
                : 'Pull down to check again after new tests are published.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (hasFilters) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Reset filters'),
            ),
          ],
        ],
      ),
    );
  }
}

class _CatalogueStateView extends StatelessWidget {
  const _CatalogueStateView.loading()
      : message = null,
        detail = null,
        onRetry = null;

  const _CatalogueStateView.error({
    required this.message,
    required this.detail,
    required this.onRetry,
  });

  final String? message;
  final String? detail;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = message == null;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
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
            message!,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Check your connection and pull down to try again.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (detail != null && detail!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              detail!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ),
        ],
      ],
    );
  }
}
