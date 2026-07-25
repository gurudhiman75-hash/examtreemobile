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

    Future<void> refreshResults() async {
      await ref.refresh(userResultsProvider.future);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: resultsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ResultsError(
          message: error.toString(),
          onRetry: () => ref.invalidate(userResultsProvider),
        ),
        data: (results) {
          if (results.isEmpty) {
            return RefreshIndicator(
              onRefresh: refreshResults,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Icon(Icons.assessment_outlined, size: 56),
                  SizedBox(height: AppSpacing.md),
                  Center(child: Text('No completed attempts yet')),
                ],
              ),
            );
          }

          final latest = results.first;
          return RefreshIndicator(
            onRefresh: refreshResults,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(
                  'Latest attempt',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                _LatestResultCard(result: latest),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Attempt history',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...results.map((result) => _AttemptTile(result: result)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LatestResultCard extends StatelessWidget {
  const _LatestResultCard({required this.result});

  final Result result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (result.score / result.maxScore).clamp(0.0, 1.0).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.examId.isEmpty ? 'Completed test' : result.examId,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${result.score.toStringAsFixed(0)}%',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${result.accuracy.toStringAsFixed(1)}% accuracy',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.sm,
              children: [
                _CountLabel(label: 'Correct', value: result.correctCount),
                _CountLabel(label: 'Incorrect', value: result.incorrectCount),
                _CountLabel(label: 'Skipped', value: result.skippedCount),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/review', extra: result.attemptId),
                    child: const Text('Summary'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: result.examId.isEmpty
                        ? null
                        : () => context.push('/test-attempt', extra: result.examId),
                    child: const Text('Retake'),
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

class _AttemptTile extends StatelessWidget {
  const _AttemptTile({required this.result});

  final Result result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text('${result.score.round()}'),
        ),
        title: Text(result.examId.isEmpty ? 'Completed test' : result.examId),
        subtitle: Text(
          '${result.correctCount} correct · ${result.incorrectCount} incorrect · ${result.skippedCount} skipped',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/review', extra: result.attemptId),
      ),
    );
  }
}

class _CountLabel extends StatelessWidget {
  const _CountLabel({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $value',
      style: Theme.of(context).textTheme.labelLarge,
    );
  }
}

class _ResultsError extends StatelessWidget {
  const _ResultsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
