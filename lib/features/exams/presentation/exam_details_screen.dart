import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/exam_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../results/presentation/providers/result_providers.dart';
import 'providers/exam_providers.dart';

class ExamDetailsScreen extends ConsumerWidget {
  const ExamDetailsScreen({super.key, required this.examId});

  final String examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examAsync = ref.watch(examDetailsProvider(examId));
    final completedAttemptsAsync = ref.watch(
      completedAttemptCountProvider(examId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Exam Details')),
      body: examAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ExamDetailsError(
          onRetry: () {
            ref.invalidate(examDetailsProvider(examId));
            ref.invalidate(completedAttemptCountProvider(examId));
          },
        ),
        data: (exam) => _ExamDetailsBody(
          exam: exam,
          completedAttemptsAsync: completedAttemptsAsync,
          onStart: () => context.push('/test-attempt', extra: examId),
        ),
      ),
    );
  }
}

class _ExamDetailsBody extends StatelessWidget {
  const _ExamDetailsBody({
    required this.exam,
    required this.completedAttemptsAsync,
    required this.onStart,
  });

  final Exam exam;
  final AsyncValue<int> completedAttemptsAsync;
  final VoidCallback onStart;

  static const instructions = [
    'Keep an internet connection available so progress can sync to your ExamTree account.',
    'Answers, review flags, current position, and remaining time are saved during the test.',
    'An in-progress test can be resumed after signing in on mobile or the ExamTree website.',
    'Follow the rules shown in each question and use only the tools permitted by the exam.',
    'Submit the test before the remaining time reaches zero.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedAttempts = completedAttemptsAsync.when(
      data: (count) => '$count',
      loading: () => '—',
      error: (error, stackTrace) => '—',
    );
    final attemptLimit = exam.maxAttempts >= 99
        ? 'Unlimited'
        : '${exam.maxAttempts}';

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            exam.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          if (exam.description.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              exam.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _InfoGrid(
            items: [
              _InfoItem(
                icon: Icons.timer_outlined,
                label: 'Duration',
                value: '${exam.durationInSeconds ~/ 60} min',
              ),
              _InfoItem(
                icon: Icons.assignment_outlined,
                label: 'Questions',
                value: '${exam.totalQuestions}',
              ),
              _InfoItem(
                icon: Icons.grade_outlined,
                label: 'Total marks',
                value: _formatNumber(exam.totalMarks),
              ),
              _InfoItem(
                icon: Icons.remove_circle_outline,
                label: 'Negative mark',
                value: exam.negativeMarking == 0
                    ? 'None'
                    : '-${_formatNumber(exam.negativeMarking)}',
              ),
              _InfoItem(
                icon: Icons.history,
                label: 'Completed',
                value: completedAttempts,
              ),
              _InfoItem(
                icon: Icons.refresh_outlined,
                label: 'Attempt limit',
                value: attemptLimit,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.sync_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text(
                    'Starting this test resumes your existing in-progress session when one is available.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Instructions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...instructions.map(
            (instruction) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      instruction,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(text: 'Start or Resume Test', onPressed: onStart),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.items});

  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 2.25,
      ),
      itemBuilder: (context, index) => _InfoTile(item: items[index]),
    );
  }
}

class _InfoItem {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.item});

  final _InfoItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              item.icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
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

class _ExamDetailsError extends StatelessWidget {
  const _ExamDetailsError({required this.onRetry});

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
              Icons.description_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Unable to load these exam details.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
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

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(
        RegExp(r'\.$'),
        '',
      );
}
