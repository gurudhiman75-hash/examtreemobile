import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/network_failure_view.dart';
import '../domain/exam_catalog.dart';
import 'providers/exam_catalog_providers.dart';

const _ink = Color(0xFF10264A);
const _navy = Color(0xFF062D5C);
const _blue = Color(0xFF0B5D96);
const _page = Color(0xFFF8FAFD);
const _line = Color(0xFFE3E9F1);
const _muted = Color(0xFF718096);

class ExamsScreen extends ConsumerStatefulWidget {
  const ExamsScreen({super.key});

  @override
  ConsumerState<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends ConsumerState<ExamsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(examCatalogProvider);
    try {
      await ref.read(examCatalogProvider.future);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(examCatalogProvider);
    return SafeArea(
      child: catalog.when(
        loading: () => const _CategoryLoading(),
        error: (error, stack) => RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              NetworkFailureView(
                error: error,
                fallbackTitle: 'Unable to load exam categories',
                onRetry: () => ref.invalidate(examCatalogProvider),
              ),
            ],
          ),
        ),
        data: (snapshot) => RefreshIndicator(
          onRefresh: _refresh,
          child: _CategoryCatalogue(
            snapshot: snapshot,
            searchController: _searchController,
            query: _query,
            onQueryChanged: (value) => setState(() => _query = value),
            onClearSearch: () {
              _searchController.clear();
              setState(() => _query = '');
            },
          ),
        ),
      ),
    );
  }
}

class ExamCategoryScreen extends ConsumerStatefulWidget {
  const ExamCategoryScreen({
    super.key,
    required this.categoryCode,
  });

  final String categoryCode;

  @override
  ConsumerState<ExamCategoryScreen> createState() =>
      _ExamCategoryScreenState();
}

class _ExamCategoryScreenState extends ConsumerState<ExamCategoryScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(examCatalogProvider);
    return Scaffold(
      backgroundColor: _page,
      appBar: _appBar('Exams'),
      body: SafeArea(
        top: false,
        child: catalog.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => NetworkFailureView(
            error: error,
            fallbackTitle: 'Unable to load exams',
            onRetry: () => ref.invalidate(examCatalogProvider),
          ),
          data: (snapshot) {
            final category = snapshot.findCategory(widget.categoryCode);
            if (category == null) return const _MissingCategory();

            final exams = snapshot.examsForCategory(category.code);
            final normalized = _query.trim().toLowerCase();
            final filtered = normalized.isEmpty
                ? exams
                : exams.where((exam) {
                    final searchable = <String>[
                      exam.name,
                      exam.description,
                      exam.familyName,
                      ...exam.languages,
                    ].join(' ').toLowerCase();
                    return searchable.contains(normalized);
                  }).toList(growable: false);

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(examCatalogProvider);
                try {
                  await ref.read(examCatalogProvider.future);
                } catch (_) {}
              },
              child: ListView(
                key: const Key('exam-category-list'),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
                children: [
                  _FamilyHeader(
                    category: category,
                    examCount: exams.length,
                  ),
                  const SizedBox(height: 14),
                  SearchBar(
                    controller: _searchController,
                    hintText: 'Search ' + category.name + ' exams',
                    leading: const Icon(Icons.search_rounded),
                    elevation: const WidgetStatePropertyAll(0),
                    backgroundColor:
                        const WidgetStatePropertyAll(Colors.white),
                    side: const WidgetStatePropertyAll(
                      BorderSide(color: _line),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
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
                  const SizedBox(height: 18),
                  Text(
                    category.name + ' Exams',
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    filtered.length.toString() +
                        (filtered.length == 1 ? ' exam available' : ' exams available'),
                    style: const TextStyle(color: _muted, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  if (exams.isEmpty)
                    _EmptyFamily(categoryName: category.name)
                  else if (filtered.isEmpty)
                    const _NoExamMatch()
                  else
                    for (final exam in filtered) ...[
                      _ExamListCard(
                        exam: exam,
                        onTap: () => context.push(
                          '/exam-series?exam=' +
                              Uri.encodeQueryComponent(exam.code),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ExamSeriesScreen extends ConsumerWidget {
  const ExamSeriesScreen({
    super.key,
    required this.examCode,
  });

  final String examCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(examCatalogProvider);
    return Scaffold(
      backgroundColor: _page,
      appBar: _appBar('Test Series'),
      body: SafeArea(
        top: false,
        child: catalog.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => NetworkFailureView(
            error: error,
            fallbackTitle: 'Unable to load test series',
            onRetry: () => ref.invalidate(examCatalogProvider),
          ),
          data: (snapshot) {
            final exam = snapshot.findExam(examCode);
            if (exam == null) return const _MissingExam();
            final series = snapshot.seriesForExam(exam.code);

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(examCatalogProvider);
                try {
                  await ref.read(examCatalogProvider.future);
                } catch (_) {}
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
                children: [
                  _ExamHero(exam: exam, series: series),
                  const SizedBox(height: 18),
                  const Text(
                    'Available Test Series',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    series.isEmpty
                        ? 'No active test series yet'
                        : series.length.toString() +
                            (series.length == 1
                                ? ' series available'
                                : ' series available'),
                    style: const TextStyle(color: _muted, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  if (series.isEmpty)
                    const _EmptySeries()
                  else
                    for (final item in series) ...[
                      _SeriesCard(
                        series: item,
                        onTap: () => context.push(
                          '/test-series?id=' +
                              Uri.encodeQueryComponent(item.id),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

PreferredSizeWidget _appBar(String title) {
  return AppBar(
    title: Text(title),
    backgroundColor: Colors.white,
    foregroundColor: _ink,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, color: _line),
    ),
  );
}

class _CategoryCatalogue extends StatelessWidget {
  const _CategoryCatalogue({
    required this.snapshot,
    required this.searchController,
    required this.query,
    required this.onQueryChanged,
    required this.onClearSearch,
  });

  final ExamCatalogSnapshot snapshot;
  final TextEditingController searchController;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final normalized = query.trim().toLowerCase();
    final visible = normalized.isEmpty
        ? snapshot.categories
        : snapshot.categories.where((category) {
            return category.name.toLowerCase().contains(normalized) ||
                category.description.toLowerCase().contains(normalized);
          }).toList(growable: false);

    return ListView(
      key: const Key('exam-category-catalogue'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 112),
      children: [
        _CategoryHero(
          totalExams: snapshot.exams.length,
          categoryCount: snapshot.categories.length,
          seriesCount: snapshot.series.length,
        ),
        const SizedBox(height: 16),
        SearchBar(
          key: const Key('exam-category-search'),
          controller: searchController,
          hintText: 'Search exam categories',
          leading: const Icon(Icons.search_rounded),
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: const WidgetStatePropertyAll(Colors.white),
          side: const WidgetStatePropertyAll(BorderSide(color: _line)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
          ),
          trailing: [
            if (query.isNotEmpty)
              IconButton(
                tooltip: 'Clear search',
                onPressed: onClearSearch,
                icon: const Icon(Icons.close_rounded),
              ),
          ],
          onChanged: onQueryChanged,
        ),
        const SizedBox(height: 20),
        const Text(
          'Exam Categories',
          style: TextStyle(
            color: _ink,
            fontSize: 21,
            fontWeight: FontWeight.w900,
            letterSpacing: -.3,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Choose a category to find the exam you are preparing for.',
          style: TextStyle(color: _muted, fontSize: 13),
        ),
        const SizedBox(height: 12),
        if (visible.isEmpty)
          snapshot.categories.isEmpty
              ? const _EmptyCatalogue()
              : const _NoCategoryMatch()
        else
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 10.0;
              final width = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final category in visible)
                    SizedBox(
                      width: width,
                      child: _CategoryCard(
                        category: category,
                        examCount:
                            snapshot.examsForCategory(category.code).length,
                        onTap: () => context.push(
                          '/exam-category?family=' +
                              Uri.encodeQueryComponent(category.code),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _CategoryHero extends StatelessWidget {
  const _CategoryHero({
    required this.totalExams,
    required this.categoryCount,
    required this.seriesCount,
  });

  final int totalExams;
  final int categoryCount;
  final int seriesCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, _blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18062D5C),
            blurRadius: 22,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PREPARE BY EXAM',
            style: TextStyle(
              color: Color(0xFFFFD36B),
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Choose your exam path',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              height: 1.12,
              fontWeight: FontWeight.w900,
              letterSpacing: -.4,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Open a category, choose your exam and continue to its test series.',
            style: TextStyle(color: Color(0xFFD8E6F5), height: 1.4),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroPill(
                icon: Icons.grid_view_rounded,
                text: categoryCount.toString() + ' categories',
              ),
              _HeroPill(
                icon: Icons.school_outlined,
                text: totalExams.toString() + ' exams',
              ),
              _HeroPill(
                icon: Icons.library_books_outlined,
                text: seriesCount.toString() + ' series',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFFFD36B)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.examCount,
    required this.onTap,
  });

  final ExamCatalogCategory category;
  final int examCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = _visualFor(category.name);
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _OfficialIcon(
                    imageUrl: category.iconUrl,
                    fallbackIcon: visual.$1,
                    background: visual.$2,
                    foreground: visual.$3,
                    size: 46,
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_outward_rounded,
                    size: 19,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                examCount.toString() +
                    (examCount == 1 ? ' exam' : ' exams'),
                style: const TextStyle(
                  color: Color(0xFF6F7E92),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (category.testCount > 0) ...[
                const SizedBox(height: 5),
                Text(
                  category.testCount.toString() + ' live tests',
                  style: const TextStyle(
                    color: Color(0xFF11966F),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FamilyHeader extends StatelessWidget {
  const _FamilyHeader({
    required this.category,
    required this.examCount,
  });

  final ExamCatalogCategory category;
  final int examCount;

  @override
  Widget build(BuildContext context) {
    final visual = _visualFor(category.name);
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, _blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        children: [
          _OfficialIcon(
            imageUrl: category.iconUrl,
            fallbackIcon: visual.$1,
            background: Colors.white,
            foreground: visual.$3,
            size: 60,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  examCount.toString() +
                      (examCount == 1 ? ' exam' : ' exams') +
                      ' • ' +
                      category.testCount.toString() +
                      ' live tests',
                  style: const TextStyle(
                    color: Color(0xFFD8E6F5),
                    fontWeight: FontWeight.w600,
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

class _ExamListCard extends StatelessWidget {
  const _ExamListCard({
    required this.exam,
    required this.onTap,
  });

  final ExamCatalogExam exam;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = _visualFor(exam.familyName);
    final languageLabel = _languageLabel(exam.languages);
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(19),
        side: const BorderSide(color: _line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OfficialIcon(
                imageUrl: exam.iconUrl,
                fallbackIcon: Icons.workspace_premium_rounded,
                background: visual.$2,
                foreground: visual.$3,
                size: 56,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    if (exam.description.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        exam.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        _MetaChip(
                          Icons.library_books_outlined,
                          exam.seriesCount.toString() + ' series',
                        ),
                        _MetaChip(
                          Icons.assignment_outlined,
                          exam.testCount.toString() + ' tests',
                        ),
                        if (languageLabel.isNotEmpty)
                          _MetaChip(
                            Icons.translate_rounded,
                            languageLabel,
                          ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    FilledButton.icon(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(
                        backgroundColor: _navy,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 38),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 17,
                      ),
                      label: const Text(
                        'View Test Series',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamHero extends StatelessWidget {
  const _ExamHero({
    required this.exam,
    required this.series,
  });

  final ExamCatalogExam exam;
  final List<ExamSeriesSummary> series;

  @override
  Widget build(BuildContext context) {
    final visual = _visualFor(exam.familyName);
    final liveTests =
        series.fold<int>(0, (sum, item) => sum + item.liveTestCount);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, _blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OfficialIcon(
            imageUrl: exam.iconUrl,
            fallbackIcon: Icons.workspace_premium_rounded,
            background: Colors.white,
            foreground: visual.$3,
            size: 64,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.familyName.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFFFD36B),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  exam.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  series.length.toString() +
                      ' test series • ' +
                      liveTests.toString() +
                      ' live tests',
                  style: const TextStyle(
                    color: Color(0xFFD8E6F5),
                    fontWeight: FontWeight.w600,
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

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({
    required this.series,
    required this.onTap,
  });

  final ExamSeriesSummary series;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final averageMinutes = series.liveTestCount == 0
        ? 0
        : (series.durationSeconds / series.liveTestCount / 60).round();

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(19),
        side: const BorderSide(color: _line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _OfficialIcon(
                    imageUrl: '',
                    fallbackIcon: Icons.fact_check_rounded,
                    background: Color(0xFFEAF4FF),
                    foreground: Color(0xFF176CC0),
                    size: 48,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          series.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        if (series.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            series.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Wrap(
                spacing: 7,
                runSpacing: 6,
                children: [
                  _MetaChip(
                    Icons.assignment_outlined,
                    series.liveTestCount.toString() + ' tests',
                  ),
                  if (series.fullLengthTestCount > 0)
                    _MetaChip(
                      Icons.description_outlined,
                      series.fullLengthTestCount.toString() + ' full mocks',
                    ),
                  if (averageMinutes > 0)
                    _MetaChip(
                      Icons.timer_outlined,
                      '~' + averageMinutes.toString() + ' min/test',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(43),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text(
                    'View Series',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfficialIcon extends StatelessWidget {
  const _OfficialIcon({
    required this.imageUrl,
    required this.fallbackIcon,
    required this.background,
    required this.foreground,
    required this.size,
  });

  final String imageUrl;
  final IconData fallbackIcon;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(size * .3),
          ),
          child: Icon(
            fallbackIcon,
            color: foreground,
            size: size * .5,
          ),
        );

    final url = imageUrl.trim();
    if (url.isEmpty || url.toLowerCase().endsWith('.svg')) {
      return fallback();
    }

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * .10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * .3),
        border: Border.all(color: const Color(0xFFE8EDF4)),
      ),
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => fallback(),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

(IconData, Color, Color) _visualFor(String value) {
  final key = value.toLowerCase();
  if (key.contains('ssc')) {
    return (
      Icons.workspace_premium_rounded,
      const Color(0xFFEAF8F2),
      const Color(0xFF11966F),
    );
  }
  if (key.contains('bank')) {
    return (
      Icons.account_balance_rounded,
      const Color(0xFFECF4FF),
      const Color(0xFF1672E8),
    );
  }
  if (key.contains('insurance')) {
    return (
      Icons.health_and_safety_rounded,
      const Color(0xFFFFF4E8),
      const Color(0xFFD97706),
    );
  }
  if (key.contains('punjab')) {
    return (
      Icons.location_on_rounded,
      const Color(0xFFFFEFEF),
      const Color(0xFFF04452),
    );
  }
  if (key.contains('rail')) {
    return (
      Icons.train_rounded,
      const Color(0xFFF3EEFF),
      const Color(0xFF7248E8),
    );
  }
  if (key.contains('teach')) {
    return (
      Icons.school_rounded,
      const Color(0xFFFFF5E8),
      const Color(0xFFF28A19),
    );
  }
  if (key.contains('defen')) {
    return (
      Icons.shield_rounded,
      const Color(0xFFEAF8F2),
      const Color(0xFF159D73),
    );
  }
  if (key.contains('pcs') || key.contains('state')) {
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

String _languageLabel(List<String> languages) {
  if (languages.isEmpty) return '';
  final normalized = languages
      .map((item) => item.trim().toLowerCase())
      .where((item) => item.isNotEmpty)
      .toSet();

  final labels = <String>[];
  if (normalized.contains('en') || normalized.contains('english')) {
    labels.add('EN');
  }
  if (normalized.contains('hi') || normalized.contains('hindi')) {
    labels.add('HI');
  }
  if (normalized.contains('pa') ||
      normalized.contains('pb') ||
      normalized.contains('punjabi')) {
    labels.add('PA');
  }
  if (labels.isEmpty) {
    labels.addAll(normalized.take(3).map((item) => item.toUpperCase()));
  }
  return labels.join(' • ');
}

class _CategoryLoading extends StatelessWidget {
  const _CategoryLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 112),
      children: [
        Container(
          height: 190,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEF6),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Exam Categories',
          style: TextStyle(
            color: _ink,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(
            6,
            (_) => Container(
              width: (MediaQuery.sizeOf(context).width - 34) / 2,
              height: 142,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _line),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyCatalogue extends StatelessWidget {
  const _EmptyCatalogue();

  @override
  Widget build(BuildContext context) {
    return const _CentredMessage(
      icon: Icons.event_busy_outlined,
      title: 'No exam categories are published yet.',
      body: 'Pull down to check again.',
    );
  }
}

class _NoCategoryMatch extends StatelessWidget {
  const _NoCategoryMatch();

  @override
  Widget build(BuildContext context) {
    return const _CentredMessage(
      icon: Icons.search_off_rounded,
      title: 'No exam category matches your search.',
      body: 'Try another exam family or clear the search.',
    );
  }
}

class _NoExamMatch extends StatelessWidget {
  const _NoExamMatch();

  @override
  Widget build(BuildContext context) {
    return const _CentredMessage(
      icon: Icons.search_off_rounded,
      title: 'No exams match this search.',
      body: 'Try a shorter exam name or clear the search.',
    );
  }
}

class _MissingCategory extends StatelessWidget {
  const _MissingCategory();

  @override
  Widget build(BuildContext context) {
    return const _CentredMessage(
      icon: Icons.folder_off_outlined,
      title: 'Exam category unavailable',
      body: 'Open the category again from the Exams page.',
    );
  }
}

class _MissingExam extends StatelessWidget {
  const _MissingExam();

  @override
  Widget build(BuildContext context) {
    return const _CentredMessage(
      icon: Icons.school_outlined,
      title: 'Exam unavailable',
      body: 'Open the exam again from its category.',
    );
  }
}

class _EmptyFamily extends StatelessWidget {
  const _EmptyFamily({required this.categoryName});

  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return _CentredMessage(
      icon: Icons.event_busy_outlined,
      title: 'No ' + categoryName + ' exams are published yet.',
      body: 'New exams will appear here automatically when published.',
    );
  }
}

class _EmptySeries extends StatelessWidget {
  const _EmptySeries();

  @override
  Widget build(BuildContext context) {
    return const _CentredMessage(
      icon: Icons.library_books_outlined,
      title: 'No test series available yet',
      body: 'Published test series for this exam will appear here automatically.',
    );
  }
}

class _CentredMessage extends StatelessWidget {
  const _CentredMessage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 18),
      child: Column(
        children: [
          Icon(icon, size: 42, color: const Color(0xFF94A3B8)),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
