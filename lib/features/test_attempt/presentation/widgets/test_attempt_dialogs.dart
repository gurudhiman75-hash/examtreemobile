import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/test_attempt_experience.dart';

enum SubmissionDecision { cancel, reviewUnanswered, submit }

class SubmissionSummaryDialog extends StatelessWidget {
  const SubmissionSummaryDialog({
    required this.summary,
    required this.testName,
    super.key,
  });

  final AttemptSubmissionSummary summary;
  final String testName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Submit test?'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                testName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _SummaryRow(
                label: 'Answered',
                value: summary.totalAnswered,
                icon: Icons.check_circle_outline,
              ),
              _SummaryRow(
                label: 'Unanswered',
                value: summary.totalUnanswered,
                icon: Icons.remove_circle_outline,
              ),
              _SummaryRow(
                label: 'Marked for review',
                value: summary.totalMarked,
                icon: Icons.bookmark_border,
              ),
              _SummaryRow(
                label: 'Answered and marked',
                value: summary.answeredAndMarkedForReview,
                icon: Icons.bookmarks_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'After submission, answers cannot be changed.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, SubmissionDecision.cancel),
          child: const Text('Continue test'),
        ),
        if (summary.hasUnanswered)
          OutlinedButton(
            onPressed: () =>
                Navigator.pop(context, SubmissionDecision.reviewUnanswered),
            child: const Text('Review unanswered'),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(context, SubmissionDecision.submit),
          child: const Text('Submit now'),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label)),
          Text(
            '$value',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ExitAttemptDialog extends StatelessWidget {
  const ExitAttemptDialog({
    required this.syncFailed,
    required this.syncing,
    super.key,
  });

  final bool syncFailed;
  final bool syncing;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save and leave test?'),
      content: Text(
        syncFailed
            ? 'Your latest progress is not synced yet. Retry saving before leaving the test.'
            : syncing
                ? 'ExamTree is still saving your latest progress.'
                : 'Your attempt will remain active and can be resumed later.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Stay'),
        ),
        FilledButton(
          onPressed: syncing ? null : () => Navigator.pop(context, true),
          child: Text(syncFailed ? 'Retry save' : 'Save and leave'),
        ),
      ],
    );
  }
}

class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({
    required this.syncing,
    required this.syncFailed,
    required this.lastSavedAt,
    required this.onRetry,
    super.key,
  });

  final bool syncing;
  final bool syncFailed;
  final DateTime? lastSavedAt;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!syncing && !syncFailed) return const SizedBox.shrink();

    final color = syncFailed
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.secondaryContainer;
    final foreground = syncFailed
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onSecondaryContainer;

    return Material(
      color: color,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              if (syncing)
                SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foreground,
                  ),
                )
              else
                Icon(Icons.cloud_off_outlined, size: 20, color: foreground),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  syncing
                      ? 'Saving your progress…'
                      : lastSavedAt == null
                          ? 'Progress is saved on this device and waiting to sync.'
                          : 'Latest changes are saved on this device but not synced to ExamTree yet.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (syncFailed)
                TextButton(
                  onPressed: onRetry,
                  child: Text('Retry', style: TextStyle(color: foreground)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
