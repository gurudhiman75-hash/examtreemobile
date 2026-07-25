import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import 'providers/result_providers.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key, required this.resultId});

  final String resultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(resultProvider(resultId));

    return Scaffold(
      appBar: AppBar(title: const Text('Attempt Summary')),
      body: resultAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _LoadError(
          message: error.toString(),
          onRetry: () => ref.invalidate(resultProvider(resultId)),
        ),
        data: (result) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Text(
                        '${result.score.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text('Overall score'),
                      const SizedBox(height: AppSpacing.md),
                      LinearProgressIndicator(
                        value: (result.score / result.maxScore).clamp(0, 1),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _MetricCard(
                icon: Icons.track_changes,
                label: 'Accuracy',
                value: '${result.accuracy.toStringAsFixed(1)}%',
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.check_circle_outline,
                      label: 'Correct',
                      value: '${result.correctCount}',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.cancel_outlined,
                      label: 'Incorrect',
                      value: '${result.incorrectCount}',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.remove_circle_outline,
                      label: 'Skipped',
                      value: '${result.skippedCount}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Question-by-question review is not shown until the mobile app consumes the server-authoritative review payload. This prevents mock answers from being presented as real results.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => context.go('/results'),
                child: const Text('View all results'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: result.examId.isEmpty
                    ? null
                    : () => context.push('/test-attempt', extra: result.examId),
                child: const Text('Retake test'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

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
