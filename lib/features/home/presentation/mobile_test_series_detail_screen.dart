import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/repository_providers.dart';
import '../../store/domain/series_purchase.dart';

final mobileTestSeriesDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, seriesId) async {
  final response =
      await ref.watch(apiClientProvider).dio.get<Map<String, dynamic>>(
            'test-series/${Uri.encodeComponent(seriesId)}',
          );
  return response.data ?? const <String, dynamic>{};
});

enum _SeriesTab { overview, tests, pattern }

class MobileTestSeriesDetailScreen extends ConsumerStatefulWidget {
  const MobileTestSeriesDetailScreen({
    super.key,
    required this.seriesId,
  });

  final String seriesId;

  @override
  ConsumerState<MobileTestSeriesDetailScreen> createState() =>
      _MobileTestSeriesDetailScreenState();
}

class _MobileTestSeriesDetailScreenState
    extends ConsumerState<MobileTestSeriesDetailScreen> {
  _SeriesTab _selectedTab = _SeriesTab.overview;

  Future<void> _refresh() async {
    ref.invalidate(mobileTestSeriesDetailProvider(widget.seriesId));
    try {
      await ref.read(mobileTestSeriesDetailProvider(widget.seriesId).future);
    } catch (_) {}
  }

  void _openTest(_SeriesMember member, _SeriesViewModel vm) {
    if (member.requiresPurchase) {
      _showPurchaseSheet(member, vm);
      return;
    }
    context.push(
      '/exam-details?seriesId=' +
          Uri.encodeQueryComponent(widget.seriesId),
      extra: member.testId,
    );
  }

  Future<void> _showPurchaseSheet(
    _SeriesMember member,
    _SeriesViewModel vm,
  ) async {
    final freeMember = vm.firstFreeOpenMember;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Color(0xFFD97706),
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'This Test is Locked',
                style: TextStyle(
                  color: Color(0xFF10264A),
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                member.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF718096),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              if (vm.commerce.freeTestCount > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8F2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    vm.commerce.freeTestCount.toString() +
                        (vm.commerce.freeTestCount == 1
                            ? ' free test is available in this series.'
                            : ' free tests are available in this series.'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF087653),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (vm.commerce.freeTestCount > 0)
                const SizedBox(height: 12),
              if (freeMember != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _openTest(freeMember, vm);
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text(
                      'Try Free Test',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: vm.commerce.plans.isEmpty
                      ? null
                      : () {
                          Navigator.of(sheetContext).pop();
                          context.push(
                            '/series-plans?seriesId=' +
                                Uri.encodeQueryComponent(widget.seriesId),
                          );
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0B5D96),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    'View Plans & Unlock',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: const Text('Maybe Later'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(
      mobileTestSeriesDetailProvider(widget.seriesId),
    );

    return detail.when(
      loading: () => const _SeriesLoadingScaffold(),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: const Color(0xFFF8FAFD),
        appBar: _appBar(),
        body: _SeriesError(onRetry: _refresh),
      ),
      data: (body) {
        final vm = _SeriesViewModel.fromBody(
          seriesId: widget.seriesId,
          body: body,
        );
        final nextMember = vm.nextMember;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFD),
          appBar: _appBar(),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
              children: [
                _SeriesHero(vm: vm),
                const SizedBox(height: 14),
                _SeriesSummary(vm: vm),
                const SizedBox(height: 14),
                _SeriesTabs(
                  selected: _selectedTab,
                  onChanged: (value) =>
                      setState(() => _selectedTab = value),
                ),
                const SizedBox(height: 16),
                switch (_selectedTab) {
                  _SeriesTab.overview => _OverviewTab(vm: vm),
                  _SeriesTab.tests => _TestsTab(
                      vm: vm,
                      onOpenTest: (member) => _openTest(member, vm),
                    ),
                  _SeriesTab.pattern => _PatternTab(vm: vm),
                },
              ],
            ),
          ),
          bottomNavigationBar: _SeriesBottomBar(
            vm: vm,
            nextMember: nextMember,
            onContinue: nextMember == null
                ? null
                : () => _openTest(nextMember, vm),
            onPurchase: vm.commerce.plans.isEmpty
                ? null
                : () => context.push(
                      '/series-plans?seriesId=' +
                          Uri.encodeQueryComponent(widget.seriesId),
                    ),
            onReviewTests: () =>
                setState(() => _selectedTab = _SeriesTab.tests),
          ),
        );
      },
    );
  }
}

PreferredSizeWidget _appBar() {
  return AppBar(
    title: const Text(
      'Test Series',
      style: TextStyle(fontWeight: FontWeight.w800),
    ),
    backgroundColor: Colors.white,
    foregroundColor: const Color(0xFF10264A),
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(
        height: 1,
        color: Color(0xFFE4E9F1),
      ),
    ),
  );
}

class _SeriesViewModel {
  const _SeriesViewModel({
    required this.seriesId,
    required this.name,
    required this.examName,
    required this.examFamilyName,
    required this.description,
    required this.iconUrl,
    required this.learnerVisibility,
    required this.learnerMessage,
    required this.progressionMode,
    required this.progressPercent,
    required this.completedCount,
    required this.requiredCount,
    required this.totalCount,
    required this.nextTestId,
    required this.available,
    required this.availabilityReason,
    required this.commerce,
    required this.members,
  });

  final String seriesId;
  final String name;
  final String examName;
  final String examFamilyName;
  final String description;
  final String iconUrl;
  final String learnerVisibility;
  final String learnerMessage;
  final String progressionMode;
  final int progressPercent;
  final int completedCount;
  final int requiredCount;
  final int totalCount;
  final String? nextTestId;
  final bool available;
  final String availabilityReason;
  final SeriesCommerceState commerce;
  final List<_SeriesMember> members;

  int get totalQuestions =>
      members.fold(0, (sum, member) => sum + member.questionCount);

  int get totalDurationSeconds =>
      members.fold(0, (sum, member) => sum + member.durationSeconds);

  double get totalMarks =>
      members.fold(0, (sum, member) => sum + member.totalMarks);

  bool get comingSoon => learnerVisibility == 'coming_soon';

  _SeriesMember? get firstFreeOpenMember {
    for (final member in members) {
      if (member.unlocked &&
          !member.paidAccessRequired &&
          !member.completed) {
        return member;
      }
    }
    for (final member in members) {
      if (member.unlocked && !member.paidAccessRequired) {
        return member;
      }
    }
    return null;
  }

  _SeriesMember? get nextMember {
    final requested = nextTestId?.trim() ?? '';
    if (requested.isNotEmpty) {
      for (final member in members) {
        if (member.testId == requested && member.canOpen) return member;
      }
    }
    for (final member in members) {
      if (member.canOpen && !member.completed) return member;
    }
    for (final member in members) {
      if (member.canOpen) return member;
    }
    return null;
  }

  factory _SeriesViewModel.fromBody({
    required String seriesId,
    required Map<String, dynamic> body,
  }) {
    final series = body['series'] is Map
        ? Map<String, dynamic>.from(body['series'] as Map)
        : const <String, dynamic>{};
    final eligibility = body['eligibility'] is Map
        ? Map<String, dynamic>.from(body['eligibility'] as Map)
        : const <String, dynamic>{};
    final rawMembers = eligibility['members'];
    final members = rawMembers is List
        ? rawMembers
            .whereType<Map>()
            .map(
              (item) => _SeriesMember.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false)
        : const <_SeriesMember>[];

    int number(Object? value) =>
        value is num ? value.toInt() : int.tryParse('$value') ?? 0;

    return _SeriesViewModel(
      seriesId: seriesId,
      name: _text(series['name'], fallback: 'Test Series'),
      examName: _text(series['examName'], fallback: 'Exam'),
      examFamilyName: _text(series['examFamilyName']),
      description: _text(series['description']),
      iconUrl: _text(series['iconUrl']),
      learnerVisibility: _text(series['learnerVisibility'], fallback: 'live'),
      learnerMessage: _text(series['learnerMessage']),
      progressionMode: _text(
        series['progressionMode'],
        fallback: 'open',
      ),
      progressPercent: number(eligibility['progressPercent']).clamp(0, 100),
      completedCount: number(eligibility['completedCount']),
      requiredCount: number(eligibility['requiredCount']),
      totalCount: number(eligibility['totalCount']),
      nextTestId: _nullableText(eligibility['nextTestId']),
      available: eligibility['available'] != false,
      availabilityReason: _text(eligibility['availabilityReason']),
      commerce: SeriesCommerceState.fromBody(body),
      members: members,
    );
  }
}

class _SeriesMember {
  const _SeriesMember({
    required this.testId,
    required this.title,
    required this.description,
    required this.questionCount,
    required this.durationSeconds,
    required this.totalMarks,
    required this.isRequired,
    required this.completed,
    required this.unlocked,
    required this.attemptCount,
    required this.bestScore,
    required this.lockReason,
    required this.paidAccessRequired,
    required this.entitled,
  });

  final String testId;
  final String title;
  final String description;
  final int questionCount;
  final int durationSeconds;
  final double totalMarks;
  final bool isRequired;
  final bool completed;
  final bool unlocked;
  final int attemptCount;
  final double? bestScore;
  final String lockReason;
  final bool paidAccessRequired;
  final bool entitled;

  bool get requiresPurchase => paidAccessRequired && !entitled;
  bool get canOpen => unlocked && !requiresPurchase;

  int get durationMinutes =>
      durationSeconds <= 0 ? 0 : (durationSeconds / 60).ceil();

  factory _SeriesMember.fromJson(Map<String, dynamic> json) {
    int number(Object? value) =>
        value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    double? decimal(Object? value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return _SeriesMember(
      testId: _text(json['testId']),
      title: _text(json['title'], fallback: 'Untitled test'),
      description: _text(json['description']),
      questionCount: number(json['questionCount']),
      durationSeconds: number(json['durationSeconds']),
      totalMarks: decimal(json['totalMarks']) ?? 0,
      isRequired: json['isRequired'] != false,
      completed: json['completed'] == true,
      unlocked: json['unlocked'] == true,
      attemptCount: number(json['attemptCount']),
      bestScore: decimal(json['bestScore']),
      lockReason: _text(json['lockReason']),
      paidAccessRequired: json['paidAccessRequired'] == true,
      entitled: json['entitled'] == true,
    );
  }
}

String _text(Object? value, {String fallback = ''}) {
  final result = value?.toString().trim() ?? '';
  return result.isEmpty ? fallback : result;
}

String? _nullableText(Object? value) {
  final result = value?.toString().trim() ?? '';
  return result.isEmpty ? null : result;
}

class _SeriesHero extends StatelessWidget {
  const _SeriesHero({required this.vm});

  final _SeriesViewModel vm;

  @override
  Widget build(BuildContext context) {
    final subtitle = vm.comingSoon && vm.learnerMessage.isNotEmpty
        ? vm.learnerMessage
        : vm.description.isEmpty
            ? 'Structured mock-test practice for ' + vm.examName + '.'
            : vm.description;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF062D5C),
            Color(0xFF0B5D96),
          ],
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
      child: Stack(
        children: [
          Positioned(
            right: -26,
            top: -36,
            child: Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .06),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (vm.iconUrl.isNotEmpty) ...[
                _SeriesNetworkIcon(url: vm.iconUrl),
                const SizedBox(height: 12),
              ],
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _HeroChip(
                    label: vm.examName.toUpperCase(),
                    foreground: const Color(0xFFFFD36B),
                    background: const Color(0x22FFD36B),
                  ),
                  _HeroChip(
                    label: vm.comingSoon
                        ? 'COMING SOON'
                        : vm.available
                            ? 'ACTIVE'
                            : 'UNAVAILABLE',
                    foreground: vm.comingSoon
                        ? const Color(0xFFFFD36B)
                        : vm.available
                            ? const Color(0xFFB7F7D6)
                            : const Color(0xFFFFC7C7),
                    background: Colors.white.withValues(alpha: .10),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                vm.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.4,
                      height: 1.12,
                    ),
              ),
              const SizedBox(height: 7),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: .84),
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      vm.comingSoon
                          ? 'Content in preparation'
                          : vm.progressPercent.toString() + '% complete',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    vm.comingSoon
                        ? 'No questions yet'
                        : vm.completedCount.toString() +
                            '/' +
                            vm.totalCount.toString() +
                            ' tests',
                    style: const TextStyle(
                      color: Color(0xFFD6E3F1),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: vm.comingSoon ? 0 : vm.progressPercent / 100,
                  backgroundColor: Colors.white.withValues(alpha: .16),
                  valueColor: const AlwaysStoppedAnimation(
                    Color(0xFFFFD36B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeriesNetworkIcon extends StatelessWidget {
  const _SeriesNetworkIcon({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withValues(alpha: .55)),
      ),
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.fact_check_rounded,
          color: Color(0xFF0B5D96),
          size: 30,
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: .6,
        ),
      ),
    );
  }
}

class _SeriesSummary extends StatelessWidget {
  const _SeriesSummary({required this.vm});

  final _SeriesViewModel vm;

  @override
  Widget build(BuildContext context) {
    final totalMinutes = (vm.totalDurationSeconds / 60).round();
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 9.0;
        final width = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: width,
              child: _MetricCard(
                icon: Icons.assignment_turned_in_outlined,
                label: 'Tests',
                value: vm.totalCount.toString(),
                tint: const Color(0xFFEAF4FF),
                iconColor: const Color(0xFF176CC0),
              ),
            ),
            SizedBox(
              width: width,
              child: _MetricCard(
                icon: Icons.quiz_outlined,
                label: 'Questions',
                value: vm.totalQuestions.toString(),
                tint: const Color(0xFFEAF8F2),
                iconColor: const Color(0xFF11966F),
              ),
            ),
            SizedBox(
              width: width,
              child: _MetricCard(
                icon: Icons.timer_outlined,
                label: 'Practice time',
                value: totalMinutes <= 0 ? '—' : totalMinutes.toString() + ' min',
                tint: const Color(0xFFFFF4E8),
                iconColor: const Color(0xFFD97706),
              ),
            ),
            SizedBox(
              width: width,
              child: _MetricCard(
                icon: Icons.trending_up_rounded,
                label: 'Progress',
                value: vm.progressPercent.toString() + '%',
                tint: const Color(0xFFF2EEFF),
                iconColor: const Color(0xFF7248E8),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E9F1)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF10264A),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 11,
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

class _SeriesTabs extends StatelessWidget {
  const _SeriesTabs({
    required this.selected,
    required this.onChanged,
  });

  final _SeriesTab selected;
  final ValueChanged<_SeriesTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE4E9F1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Overview',
              selected: selected == _SeriesTab.overview,
              onTap: () => onChanged(_SeriesTab.overview),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Tests',
              selected: selected == _SeriesTab.tests,
              onTap: () => onChanged(_SeriesTab.tests),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Pattern',
              selected: selected == _SeriesTab.pattern,
              onTap: () => onChanged(_SeriesTab.pattern),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF0B3A6F) : Colors.transparent,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : const Color(0xFF5F6F82),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.vm});

  final _SeriesViewModel vm;

  @override
  Widget build(BuildContext context) {
    final modeLabel = switch (vm.progressionMode) {
      'sequential' => 'Sequential progression',
      'score_gated' => 'Score-gated progression',
      _ => 'Open progression',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: 'About this series',
          icon: Icons.info_outline_rounded,
          child: Text(
            vm.description.isEmpty
                ? 'This series is organised for structured ' +
                    vm.examName +
                    ' practice.'
                : vm.description,
            style: const TextStyle(
              color: Color(0xFF5F6F82),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'What’s included',
          icon: Icons.inventory_2_outlined,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(
                Icons.assignment_outlined,
                vm.totalCount.toString() + ' tests',
              ),
              _InfoPill(
                Icons.quiz_outlined,
                vm.totalQuestions.toString() + ' questions',
              ),
              _InfoPill(
                Icons.rule_rounded,
                vm.requiredCount.toString() + ' required',
              ),
              _InfoPill(
                Icons.account_tree_outlined,
                modeLabel,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Why choose this series',
          icon: Icons.workspace_premium_outlined,
          child: const Column(
            children: [
              _BenefitRow(
                icon: Icons.track_changes_rounded,
                title: 'Progress tracking',
                body: 'Completed tests and your next eligible test stay visible.',
              ),
              SizedBox(height: 12),
              _BenefitRow(
                icon: Icons.lock_open_rounded,
                title: 'Clear unlock rules',
                body: 'Scheduled and progression-based locks are shown before you open a test.',
              ),
              SizedBox(height: 12),
              _BenefitRow(
                icon: Icons.fact_check_outlined,
                title: 'Instructions before attempt',
                body: 'Each unlocked test opens its details and instructions before the timer starts.',
              ),
            ],
          ),
        ),
        if (!vm.available && vm.availabilityReason.isNotEmpty) ...[
          const SizedBox(height: 12),
          _AvailabilityNotice(message: vm.availabilityReason),
        ],
      ],
    );
  }
}

class _TestsTab extends StatelessWidget {
  const _TestsTab({
    required this.vm,
    required this.onOpenTest,
  });

  final _SeriesViewModel vm;
  final ValueChanged<_SeriesMember> onOpenTest;

  @override
  Widget build(BuildContext context) {
    if (vm.members.isEmpty) {
      return _EmptySeries(
        message: vm.comingSoon && vm.learnerMessage.isNotEmpty
            ? vm.learnerMessage
            : 'No tests are currently available in this series.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProgressCard(vm: vm),
        const SizedBox(height: 12),
        for (var index = 0; index < vm.members.length; index++) ...[
          _SeriesTestCard(
            index: index + 1,
            member: vm.members[index],
            onOpen: vm.members[index].unlocked
                ? () => onOpenTest(vm.members[index])
                : null,
          ),
          if (index != vm.members.length - 1)
            const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _PatternTab extends StatelessWidget {
  const _PatternTab({required this.vm});

  final _SeriesViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.members.isEmpty) {
      return _EmptySeries(
        message: vm.comingSoon && vm.learnerMessage.isNotEmpty
            ? vm.learnerMessage
            : 'No test pattern is available yet.',
      );
    }

    final totalMinutes = (vm.totalDurationSeconds / 60).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: 'Series pattern',
          icon: Icons.grid_view_rounded,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(
                Icons.assignment_outlined,
                vm.totalCount.toString() + ' tests',
              ),
              _InfoPill(
                Icons.quiz_outlined,
                vm.totalQuestions.toString() + ' questions',
              ),
              _InfoPill(
                Icons.timer_outlined,
                totalMinutes.toString() + ' min total',
              ),
              if (vm.totalMarks > 0)
                _InfoPill(
                  Icons.grade_outlined,
                  _formatMarks(vm.totalMarks) + ' marks',
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Test-wise breakdown',
          icon: Icons.view_list_rounded,
          child: Column(
            children: [
              for (var index = 0; index < vm.members.length; index++) ...[
                _PatternRow(
                  index: index + 1,
                  member: vm.members[index],
                ),
                if (index != vm.members.length - 1)
                  const Divider(height: 22, color: Color(0xFFE8EDF3)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE4E9F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: const Color(0xFF176CC0),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF10264A),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5F6F82),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF8F2),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF11966F),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF10264A),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: const TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.vm});

  final _SeriesViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD6E8FF)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: vm.progressPercent / 100,
                  strokeWidth: 6,
                  backgroundColor: const Color(0xFFD9E8F9),
                  valueColor: const AlwaysStoppedAnimation(
                    Color(0xFF176CC0),
                  ),
                ),
                Center(
                  child: Text(
                    vm.progressPercent.toString() + '%',
                    style: const TextStyle(
                      color: Color(0xFF10264A),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your series progress',
                  style: TextStyle(
                    color: Color(0xFF10264A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vm.completedCount.toString() +
                      ' of ' +
                      vm.totalCount.toString() +
                      ' tests completed',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
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

class _SeriesTestCard extends StatelessWidget {
  const _SeriesTestCard({
    required this.index,
    required this.member,
    required this.onOpen,
  });

  final int index;
  final _SeriesMember member;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final stateLabel = member.completed
        ? 'Completed'
        : member.requiresPurchase
            ? 'Premium'
            : member.unlocked
                ? 'Ready'
                : 'Locked';
    final stateColor = member.completed
        ? const Color(0xFF11966F)
        : member.requiresPurchase
            ? const Color(0xFFD97706)
            : member.unlocked
                ? const Color(0xFF176CC0)
                : const Color(0xFF718096);
    final stateTint = member.completed
        ? const Color(0xFFEAF8F2)
        : member.requiresPurchase
            ? const Color(0xFFFFF4D6)
            : member.unlocked
                ? const Color(0xFFEAF4FF)
                : const Color(0xFFF1F4F8);

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(19),
        side: const BorderSide(color: Color(0xFFE4E9F1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 45,
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: stateTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: member.completed
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: stateColor,
                        size: 23,
                      )
                    : member.requiresPurchase
                        ? Icon(
                            Icons.lock_rounded,
                            color: stateColor,
                            size: 22,
                          )
                        : member.unlocked
                            ? Text(
                                index.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  color: stateColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              )
                            : Icon(
                                Icons.lock_outline_rounded,
                                color: stateColor,
                                size: 22,
                              ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            member.title,
                            style: const TextStyle(
                              color: Color(0xFF10264A),
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: stateTint,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            stateLabel,
                            style: TextStyle(
                              color: stateColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (member.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        member.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        if (member.questionCount > 0)
                          _TinyMeta(
                            Icons.quiz_outlined,
                            member.questionCount.toString() + ' questions',
                          ),
                        if (member.durationMinutes > 0)
                          _TinyMeta(
                            Icons.timer_outlined,
                            member.durationMinutes.toString() + ' min',
                          ),
                        if (member.totalMarks > 0)
                          _TinyMeta(
                            Icons.grade_outlined,
                            _formatMarks(member.totalMarks) + ' marks',
                          ),
                        if (!member.isRequired)
                          const _TinyMeta(
                            Icons.check_box_outline_blank_rounded,
                            'Optional',
                          ),
                      ],
                    ),
                    if (member.completed &&
                        member.bestScore != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Best score: ' + _formatMarks(member.bestScore!),
                        style: const TextStyle(
                          color: Color(0xFF11966F),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    if (!member.unlocked &&
                        member.lockReason.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        member.lockReason,
                        style: const TextStyle(
                          color: Color(0xFF7A8797),
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ],
                    if (member.unlocked) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            member.requiresPurchase
                                ? 'View Plans & Unlock'
                                : member.completed
                                    ? 'Open test again'
                                    : 'View instructions',
                            style: const TextStyle(
                              color: Color(0xFF0B5D96),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 15,
                            color: Color(0xFF0B5D96),
                          ),
                        ],
                      ),
                    ],
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

class _TinyMeta extends StatelessWidget {
  const _TinyMeta(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: const Color(0xFF7A8797),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7889),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PatternRow extends StatelessWidget {
  const _PatternRow({
    required this.index,
    required this.member,
  });

  final int index;
  final _SeriesMember member;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            index.toString(),
            style: const TextStyle(
              color: Color(0xFF10264A),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.title,
                style: const TextStyle(
                  color: Color(0xFF10264A),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Wrap(
                spacing: 10,
                runSpacing: 5,
                children: [
                  if (member.questionCount > 0)
                    Text(
                      member.questionCount.toString() + ' questions',
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 11,
                      ),
                    ),
                  if (member.durationMinutes > 0)
                    Text(
                      member.durationMinutes.toString() + ' min',
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 11,
                      ),
                    ),
                  if (member.totalMarks > 0)
                    Text(
                      _formatMarks(member.totalMarks) + ' marks',
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 11,
                      ),
                    ),
                  Text(
                    member.isRequired ? 'Required' : 'Optional',
                    style: TextStyle(
                      color: member.isRequired
                          ? const Color(0xFF176CC0)
                          : const Color(0xFF718096),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvailabilityNotice extends StatelessWidget {
  const _AvailabilityNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF6D8B2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 19,
            color: Color(0xFFD97706),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF7A5724),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeriesBottomBar extends StatelessWidget {
  const _SeriesBottomBar({
    required this.vm,
    required this.nextMember,
    required this.onContinue,
    required this.onPurchase,
    required this.onReviewTests,
  });

  final _SeriesViewModel vm;
  final _SeriesMember? nextMember;
  final VoidCallback? onContinue;
  final VoidCallback? onPurchase;
  final VoidCallback onReviewTests;

  @override
  Widget build(BuildContext context) {
    if (vm.members.isEmpty) return const SizedBox.shrink();

    final member = nextMember;
    final allCompleted =
        vm.totalCount > 0 && vm.completedCount >= vm.totalCount;
    final purchaseRequired = vm.commerce.accessRequired;
    final plan =
        vm.commerce.plans.isEmpty ? null : vm.commerce.plans.first;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
        decoration: const BoxDecoration(
          color: Color(0xFF062D5C),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(22),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 18,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    purchaseRequired
                        ? 'Unlock premium tests'
                        : allCompleted
                            ? 'Series progress'
                            : member == null
                                ? 'Series status'
                                : 'Up next',
                    style: const TextStyle(
                      color: Color(0xFFAFC5DC),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    purchaseRequired
                        ? plan == null
                            ? 'Premium access required'
                            : 'From ' +
                                _formatSeriesPrice(
                                  plan.salePriceMinor,
                                  plan.currency,
                                )
                        : allCompleted
                            ? 'All tests completed'
                            : member?.title ??
                                (vm.availabilityReason.isEmpty
                                    ? 'No test is available yet'
                                    : vm.availabilityReason),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: purchaseRequired
                  ? onPurchase
                  : allCompleted
                      ? onReviewTests
                      : vm.available
                          ? onContinue
                          : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1687E0),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF33597E),
                minimumSize: const Size(124, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: Text(
                purchaseRequired
                    ? 'View Plans'
                    : allCompleted
                        ? 'Review Tests'
                        : member?.completed == true
                            ? 'Open Test'
                            : 'Continue',
                style: const TextStyle(
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

String _formatSeriesPrice(int minor, String currency) {
  final whole = minor ~/ 100;
  final remainder = minor % 100;
  final amount = remainder == 0
      ? whole.toString()
      : whole.toString() + '.' + remainder.toString().padLeft(2, '0');
  return switch (currency.trim().toUpperCase()) {
    'INR' => '₹' + amount,
    'USD' => '\u0024' + amount,
    'GBP' => '£' + amount,
    'EUR' => '€' + amount,
    _ => currency.toUpperCase() + ' ' + amount,
  };
}

String _formatMarks(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}

class _SeriesError extends StatelessWidget {
  const _SeriesError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4F8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                size: 28,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Test series could not be loaded.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF10264A),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF718096)),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySeries extends StatelessWidget {
  const _EmptySeries({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 32,
        horizontal: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE4E9F1)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_busy_outlined,
            size: 38,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF10264A),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeriesLoadingScaffold extends StatelessWidget {
  const _SeriesLoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: _appBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
        children: [
          Container(
            height: 218,
            decoration: BoxDecoration(
              color: const Color(0xFFE4EAF2),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: List.generate(
              4,
              (_) => Container(
                width: (MediaQuery.sizeOf(context).width - 33) / 2,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE4E9F1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
