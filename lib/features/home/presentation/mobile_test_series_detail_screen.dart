import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_spacing.dart';

final mobileTestSeriesDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, seriesId) async {
  final response = await ref.watch(apiClientProvider).dio.get<Map<String, dynamic>>(
        'test-series/${Uri.encodeComponent(seriesId)}',
      );
  return response.data ?? const <String, dynamic>{};
});

class MobileTestSeriesDetailScreen extends ConsumerWidget {
  const MobileTestSeriesDetailScreen({super.key, required this.seriesId});

  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(mobileTestSeriesDetailProvider(seriesId));
    return Scaffold(
      backgroundColor: const Color(0xFFFBFCFE),
      appBar: AppBar(
        title: const Text('Test Series'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF10264A),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: detail.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _SeriesError(
            onRetry: () => ref.invalidate(mobileTestSeriesDetailProvider(seriesId)),
          ),
          data: (body) {
            final series = body['series'] is Map
                ? Map<String, dynamic>.from(body['series'] as Map)
                : const <String, dynamic>{};
            final eligibility = body['eligibility'] is Map
                ? Map<String, dynamic>.from(body['eligibility'] as Map)
                : const <String, dynamic>{};
            final members = eligibility['members'] is List
                ? (eligibility['members'] as List)
                    .whereType<Map>()
                    .map((item) => Map<String, dynamic>.from(item))
                    .toList(growable: false)
                : const <Map<String, dynamic>>[];
            final name = series['name']?.toString().trim() ?? '';
            final examName = series['examName']?.toString().trim() ?? '';
            final description = series['description']?.toString().trim() ?? '';
            final progress = int.tryParse(
                  eligibility['progressPercent']?.toString() ?? '',
                ) ??
                0;
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(mobileTestSeriesDetailProvider(seriesId));
                await ref.read(mobileTestSeriesDetailProvider(seriesId).future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF031B3A), Color(0xFF075A98)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          examName.isEmpty ? 'TEST SERIES' : examName.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: const Color(0xFFFFD36B),
                                fontWeight: FontWeight.w900,
                                letterSpacing: .7,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name.isEmpty ? 'Test Series' : name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: .82),
                                  height: 1.4,
                                ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          '$progress% complete',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 7),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: progress.clamp(0, 100) / 100,
                            backgroundColor: Colors.white.withValues(alpha: .18),
                            valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD36B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Tests',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF10264A),
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 10),
                  if (members.isEmpty)
                    const _EmptySeries()
                  else
                    for (final member in members) ...[
                      _SeriesTestCard(member: member),
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

class _SeriesTestCard extends StatelessWidget {
  const _SeriesTestCard({required this.member});

  final Map<String, dynamic> member;

  @override
  Widget build(BuildContext context) {
    final title = member['title']?.toString().trim() ?? 'Untitled test';
    final unlocked = member['unlocked'] == true;
    final completed = member['completed'] == true;
    final lockReason = member['lockReason']?.toString().trim() ?? '';
    final questionCount = int.tryParse(member['questionCount']?.toString() ?? '') ?? 0;
    final durationSeconds =
        int.tryParse(member['durationSeconds']?.toString() ?? '') ?? 0;
    final durationMinutes = durationSeconds <= 0 ? 0 : (durationSeconds / 60).ceil();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E9F1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: completed
                  ? const Color(0xFFEAF8F2)
                  : unlocked
                      ? const Color(0xFFEAF4FF)
                      : const Color(0xFFF1F4F8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              completed
                  ? Icons.check_circle_rounded
                  : unlocked
                      ? Icons.quiz_rounded
                      : Icons.lock_outline_rounded,
              color: completed
                  ? const Color(0xFF11966F)
                  : unlocked
                      ? const Color(0xFF1672E8)
                      : const Color(0xFF718096),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF10264A),
                      ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    if (questionCount > 0)
                      Text('$questionCount questions',
                          style: Theme.of(context).textTheme.bodySmall),
                    if (durationMinutes > 0)
                      Text('$durationMinutes min',
                          style: Theme.of(context).textTheme.bodySmall),
                    if (completed)
                      Text('Completed',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF11966F),
                                fontWeight: FontWeight.w800,
                              )),
                  ],
                ),
                if (!unlocked && lockReason.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    lockReason,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF718096),
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

class _SeriesError extends StatelessWidget {
  const _SeriesError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42),
            const SizedBox(height: 12),
            const Text('Test series could not be loaded.'),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _EmptySeries extends StatelessWidget {
  const _EmptySeries();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 28),
      child: Center(child: Text('No tests are currently available in this series.')),
    );
  }
}
