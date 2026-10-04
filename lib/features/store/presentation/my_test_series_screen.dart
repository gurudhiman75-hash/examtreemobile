import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../home/presentation/mobile_test_series_detail_screen.dart';

class MyTestSeriesScreen extends ConsumerWidget {
  const MyTestSeriesScreen({super.key, this.seriesId});

  final String? seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = seriesId?.trim() ?? '';
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        title: const Text(
          'My Test Series',
          style: TextStyle(
            color: Color(0xFF081847),
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: const Color(0xFFF8FBFF),
        foregroundColor: const Color(0xFF081847),
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Help',
          ),
        ],
      ),
      body: id.isEmpty
          ? const _EmptyState()
          : ref.watch(mobileTestSeriesDetailProvider(id)).when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => _LoadError(
                  onRetry: () =>
                      ref.invalidate(mobileTestSeriesDetailProvider(id)),
                ),
                data: (body) => _PurchasedSeries(
                  seriesId: id,
                  body: body,
                ),
              ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(28, 46, 28, 28),
        children: [
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF4FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fact_check_outlined,
                color: Color(0xFF2E6CE6),
                size: 76,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'You haven’t purchased any Test Series yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF081847),
              fontSize: 25,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Get full-length mock tests, sectional tests, previous year papers and detailed analysis to boost your preparation.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF60759B),
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),
          const Row(
            children: [
              _Benefit(icon: Icons.description_rounded, label: '300+\nTests'),
              _Benefit(icon: Icons.bar_chart_rounded, label: 'Detailed\nAnalysis'),
              _Benefit(icon: Icons.emoji_events_outlined, label: 'All India\nRanking'),
              _Benefit(icon: Icons.translate_rounded, label: 'Bilingual\nContent'),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 56,
            child: FilledButton(
              onPressed: () => context.go('/exams'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF073A6A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Explore Test Series',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ),
          ),
        ],
      );
}

class _PurchasedSeries extends StatelessWidget {
  const _PurchasedSeries({
    required this.seriesId,
    required this.body,
  });

  final String seriesId;
  final Map<String, dynamic> body;

  @override
  Widget build(BuildContext context) {
    final series = body['series'] is Map
        ? Map<String, dynamic>.from(body['series'] as Map)
        : const <String, dynamic>{};
    final eligibility = body['eligibility'] is Map
        ? Map<String, dynamic>.from(body['eligibility'] as Map)
        : const <String, dynamic>{};

    final name = _text(series['name'], 'Complete Test Series');
    final examName = _text(series['examName'], 'Your Exam');
    final totalCount = _int(eligibility['totalCount']);
    final completed = _int(eligibility['completedCount']);
    final progress = _int(eligibility['progressPercent']).clamp(0, 100);
    final nextTestId = _text(eligibility['nextTestId'], '');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        const _TopTabs(),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE4ECF6)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10264A).withValues(alpha: .04),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A43C5), Color(0xFF0B5D96)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          examName,
                          style: const TextStyle(
                            color: Color(0xFF081847),
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Color(0xFF425D89),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F8ED),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        color: Color(0xFF087653),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Text(
                    'Tests Attempted',
                    style: TextStyle(
                      color: Color(0xFF526A92),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$completed / $totalCount',
                    style: const TextStyle(
                      color: Color(0xFF10264A),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress / 100,
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
                backgroundColor: const Color(0xFFE6EDF7),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF1A73E8)),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$progress%',
                  style: const TextStyle(
                    color: Color(0xFF3563D8),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  _MiniStat(
                    icon: Icons.description_rounded,
                    label: 'Mock Tests',
                  ),
                  _MiniStat(
                    icon: Icons.bar_chart_rounded,
                    label: 'Sectional',
                  ),
                  _MiniStat(
                    icon: Icons.emoji_events_outlined,
                    label: 'PYQs',
                  ),
                  _MiniStat(
                    icon: Icons.topic_outlined,
                    label: 'Topic Tests',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.push(
                        '/test-series?id=' +
                            Uri.encodeQueryComponent(seriesId),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: const Color(0xFF073A6A),
                        side: const BorderSide(color: Color(0xFF073A6A)),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: nextTestId.isEmpty
                          ? () => context.push(
                                '/test-series?id=' +
                                    Uri.encodeQueryComponent(seriesId),
                              )
                          : () => context.push(
                                '/exam-details?seriesId=' +
                                    Uri.encodeQueryComponent(seriesId),
                                extra: nextTestId,
                              ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: const Color(0xFF073A6A),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
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

class _TopTabs extends StatelessWidget {
  const _TopTabs();

  @override
  Widget build(BuildContext context) => const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Tab(label: 'My Series', active: true),
          _Tab(label: 'Downloads'),
          _Tab(label: 'Bookmarks'),
          _Tab(label: 'History'),
        ],
      );
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, this.active = false});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color:
                  active ? const Color(0xFF081847) : const Color(0xFF536A94),
              fontWeight: active ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 44,
            height: 2.5,
            color: active ? const Color(0xFF081847) : Colors.transparent,
          ),
        ],
      );
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: const Color(0xFF2374E1)),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF27436E),
                fontSize: 12,
                height: 1.25,
              ),
            ),
          ],
        ),
      );
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF5FF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: const Color(0xFF1A73E8), size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF183766),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 48, color: Color(0xFF6B7FA4)),
              const SizedBox(height: 12),
              const Text(
                'Unable to load your test series.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF10264A),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      );
}

String _text(Object? value, String fallback) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

int _int(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
