import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/exam_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_visual_components.dart';
import '../../../shared/widgets/network_failure_view.dart';
import 'exam_catalog_filter.dart';
import 'providers/exam_providers.dart';
import 'widgets/exam_card.dart';

class ExamsScreen extends ConsumerStatefulWidget {
  const ExamsScreen({super.key});

  @override
  ConsumerState<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends ConsumerState<ExamsScreen> {
  late final TextEditingController _searchController;
  String _query = '';
  String? _selectedCategory;
  ExamAccessFilter _access = ExamAccessFilter.all;
  ExamSortOption _sort = ExamSortOption.recommended;

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

  Future<void> _refresh() async {
    ref
      ..invalidate(availableExamsProvider)
      ..invalidate(inProgressExamsProvider);

    Future<void> settle(Future<Object?> request) async {
      try {
        await request;
      } catch (_) {
        // Each catalogue module renders its own recoverable state.
      }
    }

    await Future.wait([
      settle(ref.read(availableExamsProvider.future)),
      settle(ref.read(inProgressExamsProvider.future)),
    ]);
  }

  void _clearFilters() {
    _searchController.clear();
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
      body: SafeArea(
        child: availableAsync.when(
          loading: () => const _CatalogueLoadingView(),
          error: (error, stackTrace) => NetworkFailureView(
            error: error,
            fallbackTitle: 'Unable to load the test catalogue',
            onRetry: () => ref.invalidate(availableExamsProvider),
          ),
          data: (availableTests) => _buildCatalogue(
            context,
            availableTests,
            inProgressAsync.value ?? const <Exam>[],
            inProgressFailed: inProgressAsync.hasError,
          ),
        ),
      ),
    );
  }

  Widget _buildCatalogue(
    BuildContext context,
    List<Exam> availableTests,
    List<Exam> inProgressTests, {
    required bool inProgressFailed,
  }) {
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
                  eyebrow: 'TEST LIBRARY',
                  title: 'Find your next test',
                  subtitle:
                      'Search by exam or subject, continue saved attempts, and filter the catalogue without leaving this screen.',
                  leading: const AppHeaderIcon(
                    icon: Icons.assignment_outlined,
                  ),
                  trailing: _hasActiveFilters
                      ? TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Reset'),
                        )
                      : null,
                  metrics: [
                    AppMetricData(
                      value: '${availableTests.length}',
                      label: 'Available',
                      icon: Icons.library_books_outlined,
                    ),
                    AppMetricData(
                      value: '$freeCount',
                      label: 'Free',
                      icon: Icons.lock_open_rounded,
                    ),
                    AppMetricData(
                      value: inProgressFailed ? '—' : '${inProgressTests.length}',
                      label: 'In progress',
                      semanticLabel: inProgressFailed
                          ? 'In-progress test count unavailable'
                          : 'In progress: ${inProgressTests.length}',
                      icon: Icons.play_circle_outline_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SearchBar(
                  controller: _searchController,
                  hintText: 'Search test, exam or subject',
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
                const SizedBox(height: AppSpacing.sm),
                AppFilterSurface(
                  child: _FilterToolbar(
                    access: _access,
                    sort: _sort,
                    onAccessChanged: (value) {
                      setState(() => _access = value);
                    },
                    onSortChanged: (value) {
                      setState(() => _sort = value);
                    },
                  ),
                ),
                if (inProgressFailed) ...[
                  const SizedBox(height: AppSpacing.md),
                  _InlineNotice(
                    icon: Icons.sync_problem_outlined,
                    message:
                        'Saved attempts could not be checked. The available-test catalogue is still usable.',
                    actionLabel: 'Retry',
                    onAction: () => ref.invalidate(inProgressExamsProvider),
                  ),
                ],
                if (inProgressTests.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  AppSectionHeader(
                    title: 'Continue learning',
                    subtitle: inProgressTests.length == 1
                        ? 'One saved attempt is ready to resume.'
                        : '${inProgressTests.length} saved attempts are ready to resume.',
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
                          onTap: () => context.push(
                            '/test-attempt',
                            extra: test.id,
                          ),
                        ),
                      ),
                ],
                const SizedBox(height: AppSpacing.xl),
                AppSectionHeader(
                  title: 'Available tests',
                  subtitle: filteredTests.length == availableTests.length
                      ? '${availableTests.length} ready to attempt.'
                      : '${filteredTests.length} of ${availableTests.length} shown.',
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
                      onTap: () => context.push(
                        '/exam-details',
                        extra: test.id,
                      ),
                    ),
                  ),
              ],
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
            segments: const [
              ButtonSegment(value: ExamAccessFilter.all, label: Text('All')),
              ButtonSegment(value: ExamAccessFilter.free, label: Text('Free')),
              ButtonSegment(value: ExamAccessFilter.paid, label: Text('Paid')),
            ],
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
                        'Sort tests',
                        style: Theme.of(sheetContext)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...ExamSortOption.values.map(
                        (option) => RadioListTile<ExamSortOption>(
                          value: option,
                          groupValue: sort,
                          title: Text(option.label),
                          onChanged: (selected) {
                            Navigator.pop(sheetContext, selected);
                          },
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

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
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
            hasFilters
                ? 'No tests match these filters'
                : 'No tests available yet',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
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

class _CatalogueLoadingView extends StatelessWidget {
  const _CatalogueLoadingView();

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
          eyebrow: 'TEST LIBRARY',
          title: 'Find your next test',
          subtitle: 'Loading the latest ExamTree test catalogue.',
          leading: AppHeaderIcon(icon: Icons.assignment_outlined),
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
            height: 142,
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
