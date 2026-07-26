import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/result_model.dart';
import '../../../core/theme/app_spacing.dart';
import 'providers/result_providers.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(userResultsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Results & Analytics')),
      body: resultsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ResultsError(
          onRetry: () => ref.invalidate(userResultsProvider),
        ),
        data: (results) {
          if (results.isEmpty) {
            return _EmptyResults(
              onRefresh: () async => ref.invalidate(userResultsProvider),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userResultsProvider);
              await ref.read(userResultsProvider.future);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: results.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) => _ResultCard(
                result: results[index],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ResultsError extends StatelessWidget {
  const _ResultsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Unable to load your attempt history.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
          Icon(
            Icons.insights_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No completed attempts yet',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Your submitted tests will appear here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
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
                        result.testName.trim().isEmpty
                            ? 'Test result'
                            : result.testName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (result.category.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          result.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _formatDate(result.calculatedAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _ScoreBadge(percentage: percentage),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _MetricChip(
                  label: 'Correct',
                  value: result.correctCount,
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
                _MetricChip(
                  label: 'Incorrect',
                  value: result.incorrectCount,
                  icon: Icons.cancel_outlined,
                  color: theme.colorScheme.error,
                ),
                _MetricChip(
                  label: 'Unanswered',
                  value: result.skippedCount,
                  icon: Icons.remove_circle_outline,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _SummaryValue(
                    label: 'Raw score',
                    value: _formatNumber(result.rawScore),
                  ),
                ),
                Expanded(
                  child: _SummaryValue(
                    label: 'Accuracy',
                    value: '${_formatNumber(result.accuracy)}%',
                  ),
                ),
                Expanded(
                  child: _SummaryValue(
                    label: 'Questions',
                    value: '${result.totalQuestions}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: result.questionReview.isEmpty
                        ? null
                        : () => context.push(
                              '/review',
                              extra: result.attemptId,
                            ),
                    icon: const Icon(Icons.fact_check_outlined),
                    label: const Text('Review'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: result.examId.isEmpty
                        ? null
                        : () => context.push(
                              '/test-attempt',
                              extra: result.examId,
                            ),
                    icon: const Icon(Icons.replay),
                    label: const Text('Retake'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.percentage});

  final double percentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primaryContainer,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Text(
        '${_formatNumber(percentage)}%',
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$label $value',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

String _formatDate(DateTime value) {
  if (value.millisecondsSinceEpoch == 0) return 'Submission date unavailable';
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
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '${local.day} ${months[local.month - 1]} ${local.year}, '
      '$hour:${local.minute.toString().padLeft(2, '0')} $period';
}
