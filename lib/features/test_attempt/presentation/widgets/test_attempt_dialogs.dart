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
    final hasUnanswered = summary.hasUnanswered;

    return AlertDialog(
      scrollable: true,
      title: const Text('Submit test?'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              testName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _SubmissionSummaryGrid(summary: summary),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: hasUnanswered
                    ? theme.colorScheme.tertiaryContainer
                    : theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    hasUnanswered
                        ? Icons.warning_amber_rounded
                        : Icons.lock_outline_rounded,
                    size: 20,
                    color: hasUnanswered
                        ? theme.colorScheme.onTertiaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      hasUnanswered
                          ? '${summary.totalUnanswered} unanswered ${summary.totalUnanswered == 1 ? 'question is' : 'questions are'} still left. You can review them before submitting.'
                          : 'After submission, answers cannot be changed.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: hasUnanswered
                            ? theme.colorScheme.onTertiaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (hasUnanswered) ...[
              FilledButton.tonalIcon(
                onPressed: () => Navigator.pop(
                  context,
                  SubmissionDecision.reviewUnanswered,
                ),
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Review unanswered'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, SubmissionDecision.submit),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Submit now'),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: () => Navigator.pop(context, SubmissionDecision.cancel),
              child: const Text('Continue test'),
            ),
          ],
        ),
      ),
      actions: const [],
    );
  }
}

class _SubmissionSummaryGrid extends StatelessWidget {
  const _SubmissionSummaryGrid({required this.summary});

  final AttemptSubmissionSummary summary;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _SubmissionMetric(
        label: 'Answered',
        value: summary.totalAnswered,
        icon: Icons.check_circle_outline,
      ),
      _SubmissionMetric(
        label: 'Unanswered',
        value: summary.totalUnanswered,
        icon: Icons.remove_circle_outline,
      ),
      _SubmissionMetric(
        label: 'Marked for review',
        value: summary.totalMarked,
        icon: Icons.bookmark_border_rounded,
      ),
      _SubmissionMetric(
        label: 'Answered + marked',
        value: summary.answeredAndMarkedForReview,
        icon: Icons.bookmarks_outlined,
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < metrics.length; index++) ...[
          metrics[index],
          if (index != metrics.length - 1)
            const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _SubmissionMetric extends StatelessWidget {
  const _SubmissionMetric({
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
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$value',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
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
    final theme = Theme.of(context);
    final (icon, title, message) = syncFailed
        ? (
            Icons.cloud_off_outlined,
            'Progress still needs to sync',
            'Your latest answers are safe on this device, but they have not reached ExamTree yet. Retry saving before leaving.',
          )
        : syncing
            ? (
                Icons.cloud_sync_outlined,
                'Saving your progress',
                'ExamTree is still saving your latest changes. Keep the test open until this save finishes.',
              )
            : (
                Icons.pause_circle_outline_rounded,
                'Save and leave test?',
                'Your attempt will stay active and can be resumed later from this device or the ExamTree website.',
              );

    return AlertDialog(
      scrollable: true,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: syncFailed
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(title)),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: syncing ? null : () => Navigator.pop(context, true),
              icon: Icon(
                syncFailed ? Icons.sync_rounded : Icons.save_outlined,
              ),
              label: Text(syncFailed ? 'Retry save' : 'Save and leave'),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Stay'),
            ),
          ],
        ),
      ),
      actions: const [],
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
                      ? 'Saving progress…'
                      : lastSavedAt == null
                          ? 'Saved on this device. Waiting to sync with ExamTree.'
                          : 'Latest changes are safe on this device but not synced yet.',
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
