import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/exam_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/network_failure_view.dart';
import 'exam_catalog_filter.dart';
import 'providers/exam_providers.dart';

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
        // Catalogue and saved-attempt states recover independently.
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
            inProgressLoading: inProgressAsync.isLoading,
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
    required bool inProgressLoading,
    required bool inProgressFailed,
  }) {
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
                _CatalogueHeader(
                  availableCount: availableTests.length,
                  freeCount: freeCount,
                  inProgressCount: inProgressFailed ? null : inProgressTests.length,
                  hasActiveFilters: _hasActiveFilters,
                  onReset: _clearFilters,
                ),
                const SizedBox(height: AppSpacing.md),
                SearchBar(
                  key: const Key('tests-search'),
                  controller: _searchController,
                  hintText: 'Search tests, exams or subjects',
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
                    onChanged: (category) {
                      setState(() => _selectedCategory = category);
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                _FilterToolbar(
                  access: _access,
                  sort: _sort,
                  onAccessChanged: (value) => setState(() => _access = value),
                  onSortChanged: (value) => setState(() => _sort = value),
                ),
                if (inProgressFailed) ...[
                  const SizedBox(height: AppSpacing.md),
                  _InlineNotice(
                    message:
                        'Saved attempts could not be checked. The test catalogue is still available.',
                    onRetry: () => ref.invalidate(inProgressExamsProvider),
                  ),
                ],
                if (inProgressLoading && inProgressTests.isEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionHeader(
                    title: 'Continue learning',
                    subtitle: 'Checking your saved attempts…',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const _ResumeSkeleton(),
                ] else if (inProgressTests.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  _SectionHeader(
                    title: 'Continue learning',
                    subtitle: inProgressTests.length == 1
                        ? 'One saved attempt is ready.'
                        : '${inProgressTests.length} saved attempts are ready.',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ResumeRail(
                    tests: inProgressTests,
                    onOpen: (test) => context.push(
                      '/test-attempt',
                      extra: test.id,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                _SectionHeader(
                  title: 'Available tests',
                  subtitle: filteredTests.length == availableTests.length
                      ? '${availableTests.length} ready to attempt.'
                      : '${filteredTests.length} of ${availableTests.length} shown.',
                  trailing: _SortButton(
                    value: _sort,
                    onChanged: (value) => setState(() => _sort = value),
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
                    (test) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _CatalogueExamCard(
                        exam: test,
                        onTap: () => context.push(
                          '/exam-details',
                          extra: test.id,
                        ),
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

class _CatalogueHeader extends StatelessWidget {
  const _CatalogueHeader({
    required this.availableCount,
    required this.freeCount,
    required this.inProgressCount,
    required this.hasActiveFilters,
    required this.onReset,
  });

  final int availableCount;
  final int freeCount;
  final int? inProgressCount;
  final bool hasActiveFilters;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      container: true,
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.assignment_outlined,
                  color: scheme.onPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tests',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.35,
                      ),
                    ),
                    Text(
                      'Choose, filter, or resume a test.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasActiveFilters)
                TextButton(
                  key: const Key('tests-reset'),
                  onPressed: onReset,
                  child: const Text('Reset'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _CountPill(
                icon: Icons.library_books_outlined,
                value: '$availableCount',
                label: 'available',
              ),
              _CountPill(
                icon: Icons.lock_open_rounded,
                value: '$freeCount',
                label: 'free',
              ),
              _CountPill(
                icon: Icons.play_circle_outline_rounded,
                value: inProgressCount == null ? '—' : '$inProgressCount',
                label: 'in progress',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: scheme.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '$value $label',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
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
        key: const Key('tests-category-rail'),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<ExamAccessFilter>(
              key: const Key('tests-access-filter'),
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
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            key: const Key('tests-sort-button'),
            tooltip: 'Sort: ${sort.label}',
            onPressed: () => _showSortSheet(context, sort, onSortChanged),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
    );
  }
}

Future<void> _showSortSheet(
  BuildContext context,
  ExamSortOption current,
  ValueChanged<ExamSortOption> onChanged,
) async {
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
              style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...ExamSortOption.values.map(
              (option) => RadioListTile<ExamSortOption>(
                value: option,
                groupValue: current,
                title: Text(option.label),
                onChanged: (selected) => Navigator.pop(sheetContext, selected),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  if (value != null) onChanged(value);
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.value, required this.onChanged});

  final ExamSortOption value;
  final ValueChanged<ExamSortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _showSortSheet(context, value, onChanged),
      icon: const Icon(Icons.swap_vert_rounded, size: 18),
      label: Text(value.label),
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
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final stack = constraints.maxWidth < 320 || textScale > 1.5;
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

class _ResumeRail extends StatelessWidget {
  const _ResumeRail({required this.tests, required this.onOpen});

  final List<Exam> tests;
  final ValueChanged<Exam> onOpen;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final itemWidth = (width * 0.77).clamp(260.0, 320.0).toDouble();
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return SizedBox(
      height: textScale > 1.5 ? 186 : 154,
      child: ListView.separated(
        key: const Key('tests-resume-rail'),
        scrollDirection: Axis.horizontal,
        itemCount: tests.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) => SizedBox(
          width: itemWidth,
          child: _ResumeCard(
            exam: tests[index],
            onTap: () => onOpen(tests[index]),
          ),
        ),
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({required this.exam, required this.onTap});

  final Exam exam;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: scheme.secondaryContainer.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: scheme.secondary.withValues(alpha: 0.22)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.play_circle_fill_rounded,
                      color: scheme.secondary,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'RESUME',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSecondaryContainer,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: scheme.onSecondaryContainer,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  exam.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSecondaryContainer,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const Spacer(),
                _MetadataLine(
                  exam: exam,
                  color: scheme.onSecondaryContainer.withValues(alpha: 0.78),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CatalogueExamCard extends StatelessWidget {
  const _CatalogueExamCard({required this.exam, required this.onTap});

  final Exam exam;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final paid = exam.status.trim().toLowerCase() == 'paid';

    return Semantics(
      button: true,
      label:
          '${exam.title}. ${exam.category}. ${exam.totalQuestions} questions. ${exam.durationInSeconds ~/ 60} minutes. ${paid ? 'Paid' : 'Free'}.',
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.description_outlined,
                          size: 21,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exam.category.trim().isEmpty ? 'General' : exam.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              exam.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _AccessBadge(paid: paid),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _MetadataLine(exam: exam, color: scheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccessBadge extends StatelessWidget {
  const _AccessBadge({required this.paid});

  final bool paid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final background = paid ? scheme.tertiaryContainer : scheme.secondaryContainer;
    final foreground = paid ? scheme.onTertiaryContainer : scheme.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Text(
        paid ? 'Paid' : 'Free',
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MetadataLine extends StatelessWidget {
  const _MetadataLine({required this.exam, required this.color});

  final Exam exam;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        _Meta(icon: Icons.timer_outlined, label: '${exam.durationInSeconds ~/ 60} min', color: color),
        _Meta(icon: Icons.help_outline_rounded, label: '${exam.totalQuestions} questions', color: color),
        if (exam.difficulty.trim().isNotEmpty)
          _Meta(icon: Icons.signal_cellular_alt_rounded, label: exam.difficulty, color: color),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Icon(Icons.sync_problem_outlined, color: scheme.onSecondaryContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
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
          Icon(
            hasFilters ? Icons.search_off_rounded : Icons.event_busy_outlined,
            size: 44,
            color: scheme.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            hasFilters ? 'No tests match these filters' : 'No tests available yet',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hasFilters
                ? 'Try another exam, access type or search phrase.'
                : 'Pull down to check again after new tests are published.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
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

class _ResumeSkeleton extends StatelessWidget {
  const _ResumeSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
      ),
    );
  }
}

class _CatalogueLoadingView extends StatelessWidget {
  const _CatalogueLoadingView();

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
        block(86),
        const SizedBox(height: AppSpacing.md),
        block(56),
        const SizedBox(height: AppSpacing.sm),
        block(46),
        const SizedBox(height: AppSpacing.xl),
        block(112),
        const SizedBox(height: AppSpacing.sm),
        block(112),
        const SizedBox(height: AppSpacing.sm),
        block(112),
      ],
    );
  }
}
