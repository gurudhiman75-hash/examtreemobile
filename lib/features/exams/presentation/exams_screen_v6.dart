import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/exam_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/network_failure_view.dart';
import 'providers/exam_providers.dart';

const _ink = Color(0xFF10264A);
const _navy = Color(0xFF062D5C);
const _blue = Color(0xFF0B5D96);
const _page = Color(0xFFF8FAFD);
const _line = Color(0xFFE3E9F1);

enum ExamFamily {
  ssc('SSC'),
  banking('Banking'),
  insurance('Insurance'),
  punjab('Punjab State'),
  railway('Railway'),
  teaching('Teaching'),
  defence('Defence'),
  statePcs('State PCS'),
  other('Other Exams');

  const ExamFamily(this.label);
  final String label;
}

ExamFamily familyForExam(Exam exam) {
  final source = <String>[
    exam.category,
    exam.title,
    ...exam.tags,
  ].join(' ').toLowerCase();

  if (source.contains('ssc')) return ExamFamily.ssc;
  if (source.contains('insurance') ||
      source.contains('lic ') ||
      source.contains('lic-') ||
      source.contains('niacl') ||
      source.contains('uiic')) {
    return ExamFamily.insurance;
  }
  if (source.contains('bank') ||
      source.contains('ibps') ||
      source.contains('sbi ') ||
      source.contains('rbi ')) {
    return ExamFamily.banking;
  }
  if (source.contains('punjab') ||
      source.contains('psssb') ||
      source.contains('puda') ||
      source.contains('ppsc')) {
    return ExamFamily.punjab;
  }
  if (source.contains('rail') || source.contains('rrb')) {
    return ExamFamily.railway;
  }
  if (source.contains('teach') ||
      source.contains('teacher') ||
      source.contains('ctet') ||
      source.contains(' tet')) {
    return ExamFamily.teaching;
  }
  if (source.contains('defence') ||
      source.contains('defense') ||
      source.contains('army') ||
      source.contains('navy') ||
      source.contains('air force') ||
      source.contains('afcat') ||
      source.contains('nda') ||
      source.contains('cds')) {
    return ExamFamily.defence;
  }
  if (source.contains('pcs') || source.contains('state civil')) {
    return ExamFamily.statePcs;
  }
  return ExamFamily.other;
}

ExamFamily familyFromRoute(String value) {
  final normalized = value.trim().toLowerCase();
  for (final family in ExamFamily.values) {
    if (family.name.toLowerCase() == normalized ||
        family.label.toLowerCase() == normalized) {
      return family;
    }
  }

  if (normalized.contains('ssc')) return ExamFamily.ssc;
  if (normalized.contains('insurance') || normalized.contains('lic')) {
    return ExamFamily.insurance;
  }
  if (normalized.contains('bank')) return ExamFamily.banking;
  if (normalized.contains('punjab')) return ExamFamily.punjab;
  if (normalized.contains('rail')) return ExamFamily.railway;
  if (normalized.contains('teach')) return ExamFamily.teaching;
  if (normalized.contains('defen')) return ExamFamily.defence;
  if (normalized.contains('pcs') || normalized.contains('state')) {
    return ExamFamily.statePcs;
  }
  return ExamFamily.other;
}

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

  @override
  Widget build(BuildContext context) {
    final examsAsync = ref.watch(availableExamsProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(availableExamsProvider);
          await ref.read(availableExamsProvider.future);
        },
        child: examsAsync.when(
          loading: () => const _CategoryLoading(),
          error: (error, stackTrace) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              NetworkFailureView(
                error: error,
                fallbackTitle: 'Unable to load exam categories',
                onRetry: () => ref.invalidate(availableExamsProvider),
              ),
            ],
          ),
          data: (exams) => _categoryCatalogue(context, exams),
        ),
      ),
    );
  }

  Widget _categoryCatalogue(BuildContext context, List<Exam> exams) {
    final counts = <ExamFamily, int>{};
    final freeCounts = <ExamFamily, int>{};
    for (final exam in exams) {
      final family = familyForExam(exam);
      counts[family] = (counts[family] ?? 0) + 1;
      if (exam.status.trim().toLowerCase() != 'paid') {
        freeCounts[family] = (freeCounts[family] ?? 0) + 1;
      }
    }

    final preferred = <ExamFamily>[
      ExamFamily.ssc,
      ExamFamily.banking,
      ExamFamily.insurance,
      ExamFamily.punjab,
      ExamFamily.railway,
      ExamFamily.teaching,
      ExamFamily.defence,
      ExamFamily.statePcs,
      ExamFamily.other,
    ];
    var visible = preferred.where((family) => (counts[family] ?? 0) > 0).toList();
    final query = _query.trim().toLowerCase();
    if (query.isNotEmpty) {
      visible = visible
          .where((family) => family.label.toLowerCase().contains(query))
          .toList();
    }

    return ListView(
      key: const Key('exam-category-catalogue'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 112),
      children: [
        _CategoryHero(
          totalExams: exams.length,
          categoryCount: counts.keys.length,
        ),
        const SizedBox(height: 16),
        SearchBar(
          key: const Key('exam-category-search'),
          controller: _searchController,
          hintText: 'Search exam categories',
          leading: const Icon(Icons.search_rounded),
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: const WidgetStatePropertyAll(Colors.white),
          side: const WidgetStatePropertyAll(BorderSide(color: _line)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
          ),
          trailing: [
            if (_query.isNotEmpty)
              IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
                icon: const Icon(Icons.close_rounded),
              ),
          ],
          onChanged: (value) => setState(() => _query = value),
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
          'Choose a category to see its exams and test series.',
          style: TextStyle(color: Color(0xFF718096), fontSize: 13),
        ),
        const SizedBox(height: 12),
        if (visible.isEmpty)
          exams.isEmpty ? const _EmptyCatalogue() : const _NoCategoryMatch()
        else
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 10.0;
              final width = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final family in visible)
                    SizedBox(
                      width: width,
                      child: _CategoryCard(
                        family: family,
                        count: counts[family] ?? 0,
                        freeCount: freeCounts[family] ?? 0,
                        onTap: () => context.push(
                          '/exam-category?family=' +
                              Uri.encodeQueryComponent(family.name),
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

class ExamCategoryScreen extends ConsumerStatefulWidget {
  const ExamCategoryScreen({
    super.key,
    required this.family,
  });

  final ExamFamily family;

  @override
  ConsumerState<ExamCategoryScreen> createState() => _ExamCategoryScreenState();
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
    final examsAsync = ref.watch(availableExamsProvider);
    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        title: Text(widget.family.label),
        backgroundColor: Colors.white,
        foregroundColor: _ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _line),
        ),
      ),
      body: SafeArea(
        top: false,
        child: examsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => NetworkFailureView(
            error: error,
            fallbackTitle: 'Unable to load ' + widget.family.label + ' exams',
            onRetry: () => ref.invalidate(availableExamsProvider),
          ),
          data: (allExams) {
            final familyExams = allExams
                .where((exam) => familyForExam(exam) == widget.family)
                .toList()
              ..sort(
                (left, right) =>
                    left.title.toLowerCase().compareTo(right.title.toLowerCase()),
              );

            final q = _query.trim().toLowerCase();
            final filtered = q.isEmpty
                ? familyExams
                : familyExams.where((exam) {
                    final searchable = <String>[
                      exam.title,
                      exam.description,
                      exam.category,
                      ...exam.tags,
                    ].join(' ').toLowerCase();
                    return searchable.contains(q);
                  }).toList();

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(availableExamsProvider);
                await ref.read(availableExamsProvider.future);
              },
              child: ListView(
                key: const Key('exam-category-list'),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
                children: [
                  _FamilyHeader(
                    family: widget.family,
                    count: familyExams.length,
                    freeCount: familyExams
                        .where((exam) =>
                            exam.status.trim().toLowerCase() != 'paid')
                        .length,
                  ),
                  const SizedBox(height: 14),
                  SearchBar(
                    controller: _searchController,
                    hintText: 'Search ' + widget.family.label + ' exams',
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
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.family.label + ' Exams',
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    filtered.length.toString() +
                        (filtered.length == 1 ? ' exam' : ' exams') +
                        ' available',
                    style: const TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (familyExams.isEmpty)
                    _EmptyFamily(family: widget.family)
                  else if (filtered.isEmpty)
                    const _NoExamMatch()
                  else
                    for (final exam in filtered) ...[
                      _ExamListCard(
                        exam: exam,
                        onTap: () => context.push(
                          '/exam-details?id=' + Uri.encodeQueryComponent(exam.id),
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

class _CategoryHero extends StatelessWidget {
  const _CategoryHero({
    required this.totalExams,
    required this.categoryCount,
  });

  final int totalExams;
  final int categoryCount;

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
            'Find mock tests, previous papers and practice for the exam you are targeting.',
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
                icon: Icons.assignment_outlined,
                text: totalExams.toString() + ' exams',
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
    required this.family,
    required this.count,
    required this.freeCount,
    required this.onTap,
  });

  final ExamFamily family;
  final int count;
  final int freeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = _familyVisual(family);
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
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: visual.$2,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(visual.$1, color: visual.$3, size: 25),
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
                family.label,
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
                count.toString() + (count == 1 ? ' exam' : ' exams'),
                style: const TextStyle(
                  color: Color(0xFF6F7E92),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (freeCount > 0) ...[
                const SizedBox(height: 5),
                Text(
                  freeCount.toString() + ' free to start',
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
    required this.family,
    required this.count,
    required this.freeCount,
  });

  final ExamFamily family;
  final int count;
  final int freeCount;

  @override
  Widget build(BuildContext context) {
    final visual = _familyVisual(family);
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
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(visual.$1, color: visual.$3, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  family.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  count.toString() +
                      (count == 1 ? ' exam' : ' exams') +
                      (freeCount > 0
                          ? ' • ' + freeCount.toString() + ' free'
                          : ''),
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

  final Exam exam;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final paid = exam.status.trim().toLowerCase() == 'paid';
    final acronym = _acronym(exam.title);
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
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: paid
                      ? const Color(0xFFF3EEFF)
                      : const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  acronym,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: paid
                        ? const Color(0xFF6D4BC3)
                        : const Color(0xFF176CC0),
                    fontSize: acronym.length > 3 ? 11 : 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        height: 1.22,
                      ),
                    ),
                    if (exam.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        exam.description.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        _MetaChip(
                          Icons.help_outline_rounded,
                          exam.totalQuestions.toString() + ' questions',
                        ),
                        _MetaChip(
                          Icons.timer_outlined,
                          (exam.durationInSeconds ~/ 60).toString() + ' min',
                        ),
                        _StatusChip(paid: paid),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.paid});
  final bool paid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: paid
            ? AppColors.tertiaryContainer
            : AppColors.mintContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        paid ? 'PREMIUM' : 'FREE',
        style: TextStyle(
          color: paid
              ? AppColors.onTertiaryContainer
              : AppColors.onMintContainer,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: .3,
        ),
      ),
    );
  }
}

(IconData, Color, Color) _familyVisual(ExamFamily family) {
  return switch (family) {
    ExamFamily.ssc => (
        Icons.workspace_premium_rounded,
        const Color(0xFFEAF8F2),
        const Color(0xFF11966F),
      ),
    ExamFamily.banking => (
        Icons.account_balance_rounded,
        const Color(0xFFECF4FF),
        const Color(0xFF1672E8),
      ),
    ExamFamily.insurance => (
        Icons.health_and_safety_rounded,
        const Color(0xFFFFF4E8),
        const Color(0xFFD97706),
      ),
    ExamFamily.punjab => (
        Icons.location_on_rounded,
        const Color(0xFFFFEFEF),
        const Color(0xFFF04452),
      ),
    ExamFamily.railway => (
        Icons.train_rounded,
        const Color(0xFFF3EEFF),
        const Color(0xFF7248E8),
      ),
    ExamFamily.teaching => (
        Icons.school_rounded,
        const Color(0xFFFFF5E8),
        const Color(0xFFF28A19),
      ),
    ExamFamily.defence => (
        Icons.shield_rounded,
        const Color(0xFFEAF8F2),
        const Color(0xFF159D73),
      ),
    ExamFamily.statePcs => (
        Icons.apartment_rounded,
        const Color(0xFFFFEEEE),
        const Color(0xFFF04452),
      ),
    ExamFamily.other => (
        Icons.grid_view_rounded,
        const Color(0xFFF1F4F8),
        const Color(0xFF718096),
      ),
  };
}

String _acronym(String value) {
  final words = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) return 'EX';
  final initials = words
      .take(4)
      .map((word) => word.characters.first.toUpperCase())
      .join();
  if (initials.length >= 2) return initials;
  final clean = value.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
  return clean.length <= 4 ? clean : clean.substring(0, 4);
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
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Icon(Icons.event_busy_outlined, size: 42, color: Color(0xFF94A3B8)),
          SizedBox(height: 10),
          Text(
            'No exam categories are published yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Pull down to check again.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _NoCategoryMatch extends StatelessWidget {
  const _NoCategoryMatch();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 42, color: Color(0xFF94A3B8)),
          SizedBox(height: 10),
          Text(
            'No exam category matches your search.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _NoExamMatch extends StatelessWidget {
  const _NoExamMatch();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 42, color: Color(0xFF94A3B8)),
          SizedBox(height: 10),
          Text(
            'No exams match this search.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _EmptyFamily extends StatelessWidget {
  const _EmptyFamily({required this.family});
  final ExamFamily family;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_busy_outlined,
            size: 40,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 10),
          Text(
            'No ' + family.label + ' exams are published yet.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
