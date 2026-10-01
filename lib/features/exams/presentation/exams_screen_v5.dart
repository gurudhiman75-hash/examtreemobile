import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/exam_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/network_failure_view.dart';
import '../../promotions/domain/promotion_campaign.dart';
import '../../promotions/presentation/providers/promotion_providers.dart';
import '../../promotions/presentation/widgets/promotion_carousel.dart';
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

  bool get _hasActiveFilters =>
      _query.trim().isNotEmpty ||
      _selectedCategory != null ||
      _access != ExamAccessFilter.all ||
      _sort != ExamSortOption.recommended;

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedCategory = null;
      _access = ExamAccessFilter.all;
      _sort = ExamSortOption.recommended;
    });
  }

  Future<void> _refresh() async {
    ref
      ..invalidate(availableExamsProvider)
      ..invalidate(inProgressExamsProvider)
      ..invalidate(promotionsForPlacementProvider(PromotionPlacement.tests));

    Future<void> settle(Future<Object?> request) async {
      try {
        await request;
      } catch (_) {
        // Catalogue and saved attempts keep independent recovery states.
      }
    }

    await Future.wait([
      settle(ref.read(availableExamsProvider.future)),
      settle(ref.read(inProgressExamsProvider.future)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final availableAsync = ref.watch(availableExamsProvider);
    final inProgressAsync = ref.watch(inProgressExamsProvider);

    return SafeArea(
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
              10,
              AppSpacing.sm,
              10,
              AppSpacing.xxl,
            ),
            sliver: SliverList.list(
              children: [
                _DiscoveryIntro(
                  availableCount: availableTests.length,
                  freeCount: freeCount,
                  inProgressCount:
                      inProgressFailed ? null : inProgressTests.length,
                  hasActiveFilters: _hasActiveFilters,
                  onReset: _clearFilters,
                ),
                const SizedBox(height: AppSpacing.md),
                const PromotionPlacementView(
                  placement: PromotionPlacement.tests,
                  compact: true,
                ),
                const SizedBox(height: AppSpacing.md),
                Theme(
                  data: Theme.of(context).copyWith(
                    searchBarTheme: SearchBarThemeData(
                      elevation: const WidgetStatePropertyAll(0),
                      backgroundColor:
                          const WidgetStatePropertyAll(Color(0xFFFFFFFF)),
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
                ),
                if (categories.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _CategoryGrid(
                    categories: categories,
                    selectedCategory: selectedCategory,
                    onChanged: (category) {
                      setState(() => _selectedCategory = category);
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                _AccessAndSortBar(
                  access: _access,
                  sort: _sort,
                  onAccessChanged: (value) => setState(() => _access = value),
                  onSortChanged: (value) => setState(() => _sort = value),
                ),
                if (inProgressFailed) ...[
                  const SizedBox(height: AppSpacing.md),
                  _InlineNotice(
                    message:
                        'Saved attempts could not be checked. The catalogue is still available.',
                    onRetry: () => ref.invalidate(inProgressExamsProvider),
                  ),
                ],
                if (inProgressLoading && inProgressTests.isEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionHeading(title: 'Continue Tests'),
                  const SizedBox(height: AppSpacing.sm),
                  const _ResumeSkeleton(),
                ] else if (inProgressTests.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionHeading(title: 'Continue Tests'),
                  const SizedBox(height: AppSpacing.sm),
                  _ResumeRail(
                    tests: inProgressTests,
                    onOpen: (exam) => context.push(
                      '/test-attempt',
                      extra: exam.id,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                _SectionHeading(
                  title: 'Available tests',
                  subtitle: filteredTests.length == availableTests.length
                      ? '${availableTests.length} ready to attempt.'
                      : '${filteredTests.length} of ${availableTests.length} shown.',
                ),
                const SizedBox(height: AppSpacing.sm),
                if (filteredTests.isEmpty)
                  _EmptyCatalogue(
                    hasFilters: _hasActiveFilters,
                    onReset: _clearFilters,
                  )
                else
                  ...filteredTests.map(
                    (exam) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _TestRow(
                        exam: exam,
                        onTap: () => context.push(
                          '/exam-details',
                          extra: exam.id,
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

class _DiscoveryIntro extends StatelessWidget {
  const _DiscoveryIntro({
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
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        textScale > 1.4 ? 14 : 15,
        16,
        textScale > 1.4 ? 14 : 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF031B3A),
            Color(0xFF063A70),
            Color(0xFF0B5D96),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF062D5C).withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -34,
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Column(
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
                          'TESTS',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFFFFD36B),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Find your next test',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontSize: textScale > 1.4 ? 21 : 23,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Practice by exam, access or format.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.74),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasActiveFilters)
                    TextButton(
                      key: const Key('tests-reset'),
                      onPressed: onReset,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.10),
                      ),
                      child: const Text('Reset'),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _HeroStat(
                    icon: Icons.library_books_rounded,
                    value: '$availableCount',
                    label: 'Available',
                  ),
                  _HeroStat(
                    icon: Icons.lock_open_rounded,
                    value: '$freeCount',
                    label: 'Free',
                  ),
                  _HeroStat(
                    icon: Icons.play_circle_outline_rounded,
                    value: inProgressCount == null ? '—' : '$inProgressCount',
                    label: 'In progress',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
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
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    return Container(
      constraints: largeText
          ? const BoxConstraints(minWidth: 96, maxWidth: 150)
          : const BoxConstraints(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: largeText
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 17, color: const Color(0xFFFFD36B)),
                    const SizedBox(width: 7),
                    Text(
                      value,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 17, color: const Color(0xFFFFD36B)),
                const SizedBox(width: 7),
                Text(
                  value,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  });

  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <String?>[null, ...categories];
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        const columns = 3;
        final tileWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        final tileHeight = textScale > 1.35 ? 124.0 : 108.0;

        return Wrap(
          key: const Key('tests-category-grid'),
          spacing: gap,
          runSpacing: gap,
          children: items.map((category) {
            final selected = category == selectedCategory;
            final visual = _examCategoryVisual(category);

            return SizedBox(
              width: tileWidth,
              height: tileHeight,
              child: _ExamCategoryFilterTile(
                label: category ?? 'All exams',
                icon: visual.$1,
                background: visual.$2,
                foreground: visual.$3,
                selected: selected,
                onTap: () => onChanged(category),
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }
}

class _ExamCategoryFilterTile extends StatelessWidget {
  const _ExamCategoryFilterTile({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(18);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFEAF2FF) : background,
        borderRadius: radius,
        border: Border.all(
          color: selected
              ? const Color(0xFF0B3A6F)
              : foreground.withValues(alpha: .20),
          width: selected ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: selected
                ? const Color(0xFF0B3A6F).withValues(alpha: .12)
                : foreground.withValues(alpha: .09),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: const Color(0xFF10264A).withValues(alpha: .03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF0B3A6F)
                        : foreground.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: selected ? Colors.white : foreground,
                    size: 25,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF10264A),
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -.05,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

(IconData, Color, Color) _examCategoryVisual(String? category) {
  if (category == null) {
    return (
      Icons.apps_rounded,
      const Color(0xFFF1F4F8),
      const Color(0xFF526274),
    );
  }

  final key = category.toLowerCase();

  if (key.contains('bank') || key.contains('insurance')) {
    return (
      Icons.account_balance_rounded,
      const Color(0xFFFFF5DD),
      const Color(0xFFB77900),
    );
  }
  if (key.contains('ssc') || key.contains('government')) {
    return (
      Icons.account_balance_rounded,
      const Color(0xFFFFF1E2),
      const Color(0xFFB46616),
    );
  }
  if (key.contains('rail')) {
    return (
      Icons.train_rounded,
      const Color(0xFFE9F4FF),
      const Color(0xFF2563A8),
    );
  }
  if (key.contains('teach') || key.contains('education')) {
    return (
      Icons.school_rounded,
      const Color(0xFFEAF8EE),
      const Color(0xFF2B7B4B),
    );
  }
  if (key.contains('defence') ||
      key.contains('defense') ||
      key.contains('army')) {
    return (
      Icons.shield_rounded,
      const Color(0xFFFFF1E2),
      const Color(0xFF9A5C15),
    );
  }
  if (key.contains('police')) {
    return (
      Icons.local_police_rounded,
      const Color(0xFFF0EEFF),
      const Color(0xFF6154A8),
    );
  }
  if (key.contains('medical') || key.contains('neet')) {
    return (
      Icons.medical_services_rounded,
      const Color(0xFFFFEEF2),
      const Color(0xFFC54667),
    );
  }
  if (key.contains('engineer') ||
      key.contains('jee') ||
      key.contains('gate')) {
    return (
      Icons.engineering_rounded,
      const Color(0xFFE9F4FF),
      const Color(0xFF2563A8),
    );
  }
  if (key.contains('punjab')) {
    return (
      Icons.location_on_rounded,
      const Color(0xFFFFF5DD),
      const Color(0xFFB77900),
    );
  }
  if (key.contains('state') || key.contains('pcs')) {
    return (
      Icons.apartment_rounded,
      const Color(0xFFFFEEEE),
      const Color(0xFFF04452),
    );
  }

  return (
    Icons.grid_view_rounded,
    const Color(0xFFF1F4F8),
    const Color(0xFF718096),
  );
}

class _AccessAndSortBar extends StatelessWidget {
  const _AccessAndSortBar({
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
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final accessRail = SizedBox(
      height: textScale > 1.5 ? 56 : 42,
      child: ListView.separated(
        key: const Key('tests-access-filter'),
        scrollDirection: Axis.horizontal,
        itemCount: ExamAccessFilter.values.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final option = ExamAccessFilter.values[index];
          final selected = access == option;
          return ChoiceChip(
            label: Text(option.label),
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
            onSelected: (_) => onAccessChanged(option),
          );
        },
      ),
    );
    final sortButton = TextButton.icon(
      key: const Key('tests-sort-button'),
      onPressed: () => _showSortSheet(context, sort, onSortChanged),
      icon: const Icon(Icons.swap_vert_rounded, size: 18),
      label: Text(sort.label),
    );

    if (textScale > 1.5) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          accessRail,
          const SizedBox(height: AppSpacing.xs),
          Align(alignment: Alignment.centerLeft, child: sortButton),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: accessRail),
        const SizedBox(width: AppSpacing.xs),
        sortButton,
      ],
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
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final option in ExamSortOption.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(option.label),
                trailing: option == current
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
  if (value != null) onChanged(value);
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
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
  }
}

class _ResumeRail extends StatelessWidget {
  const _ResumeRail({required this.tests, required this.onOpen});

  final List<Exam> tests;
  final ValueChanged<Exam> onOpen;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final itemWidth = (width * 0.78).clamp(270.0, 330.0).toDouble();
    final railHeight = textScale > 1.5 ? 336.0 : 180.0;
    return SizedBox(
      height: railHeight,
      child: ListView.separated(
        key: const Key('tests-resume-rail'),
        scrollDirection: Axis.horizontal,
        itemCount: tests.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final exam = tests[index];
          return SizedBox(
            width: itemWidth,
            child: _ResumeCard(
              exam: exam,
              onTap: () => onOpen(exam),
            ),
          );
        },
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
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF062D5C), Color(0xFF0A4B82)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: _softShadow(),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD36B),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'RESUME',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFFFD36B),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  exam.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.22,
                  ),
                ),
                const Spacer(),
                Theme(
                  data: theme.copyWith(
                    colorScheme: theme.colorScheme.copyWith(
                      onSurfaceVariant: Colors.white70,
                    ),
                  ),
                  child: _MetadataLine(exam: exam),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TestRow extends StatelessWidget {
  const _TestRow({required this.exam, required this.onTap});

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
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: paid
                          ? AppColors.tertiaryContainer
                          : AppColors.skyContainer,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.description_rounded,
                      color: paid
                          ? AppColors.onTertiaryContainer
                          : AppColors.onSkyContainer,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                exam.category.trim().isEmpty
                                    ? 'General'
                                    : exam.category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _AccessBadge(paid: paid),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          exam.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.22,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _MetadataLine(exam: exam),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.outline,
                  ),
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
    final background =
        paid ? AppColors.tertiaryContainer : AppColors.mintContainer;
    final foreground =
        paid ? AppColors.onTertiaryContainer : AppColors.onMintContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        paid ? 'PREMIUM' : 'FREE',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.45,
            ),
      ),
    );
  }
}

class _MetadataLine extends StatelessWidget {
  const _MetadataLine({required this.exam});

  final Exam exam;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    final items = <Widget>[
      _Meta(
        icon: Icons.timer_outlined,
        label: '${exam.durationInSeconds ~/ 60} min',
        color: color,
      ),
      _Meta(
        icon: Icons.help_outline_rounded,
        label: '${exam.totalQuestions} questions',
        color: color,
      ),
      if (exam.difficulty.trim().isNotEmpty)
        _Meta(
          icon: Icons.signal_cellular_alt_rounded,
          label: exam.difficulty,
          color: color,
        ),
    ];
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    if (textScale > 1.5) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < items.length; index++) ...[
            items[index],
            if (index != items.length - 1)
              const SizedBox(height: AppSpacing.xs),
          ],
        ],
      );
    }
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: items,
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
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final labelWidget = Text(
      label,
      maxLines: largeText ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
    );
    return Row(
      mainAxisSize: largeText ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: AppSpacing.xxs),
        if (largeText) Expanded(child: labelWidget) else labelWidget,
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.mintContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.sync_problem_outlined,
            color: AppColors.onMintContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.onMintContainer,
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.skyContainer,
              borderRadius: BorderRadius.circular(19),
            ),
            child: Icon(
              hasFilters ? Icons.search_off_rounded : Icons.event_busy_outlined,
              color: AppColors.onSkyContainer,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            hasFilters
                ? 'No tests match these filters'
                : 'No tests available yet',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
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

class _ResumeSkeleton extends StatelessWidget {
  const _ResumeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
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
            borderRadius: BorderRadius.circular(20),
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
        block(92),
        const SizedBox(height: AppSpacing.md),
        block(56),
        const SizedBox(height: AppSpacing.sm),
        block(42),
        const SizedBox(height: AppSpacing.xl),
        block(180),
        const SizedBox(height: AppSpacing.sm),
        block(126),
        const SizedBox(height: AppSpacing.sm),
        block(126),
      ],
    );
  }
}

List<BoxShadow> _softShadow() => [
      BoxShadow(
        color: AppColors.shadow.withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 7),
      ),
    ];
