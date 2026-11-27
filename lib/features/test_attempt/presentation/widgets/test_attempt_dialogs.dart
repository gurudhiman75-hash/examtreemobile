import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/test_attempt_experience.dart';
import '../../../../l10n/l10n.dart';

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
      title: Text(context.l10n.attemptSubmitQuestion),
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
                          ? context.l10n.attemptUnansweredLeft(summary.totalUnanswered)
                          : context.l10n.attemptCannotChange,
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
                label: Text(context.l10n.attemptReviewUnanswered),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, SubmissionDecision.submit),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text(context.l10n.attemptSubmitNow),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: () => Navigator.pop(context, SubmissionDecision.cancel),
              child: Text(context.l10n.attemptContinueTest),
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
        label: context.l10n.attemptAnswered,
        value: summary.totalAnswered,
        icon: Icons.check_circle_outline,
      ),
      _SubmissionMetric(
        label: context.l10n.attemptUnanswered,
        value: summary.totalUnanswered,
        icon: Icons.remove_circle_outline,
      ),
      _SubmissionMetric(
        label: context.l10n.attemptMarkedForReview,
        value: summary.totalMarked,
        icon: Icons.bookmark_border_rounded,
      ),
      _SubmissionMetric(
        label: context.l10n.attemptAnsweredMarked,
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
            context.l10n.attemptSyncNeededTitle,
            context.l10n.attemptSyncNeededBody,
          )
        : syncing
            ? (
                Icons.cloud_sync_outlined,
                context.l10n.attemptSavingTitle,
                context.l10n.attemptSavingBody,
              )
            : (
                Icons.pause_circle_outline_rounded,
                context.l10n.attemptLeaveTitle,
                context.l10n.attemptLeaveBody,
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
              label: Text(
              syncFailed
                  ? context.l10n.attemptRetrySave
                  : context.l10n.attemptSaveLeave,
            ),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.attemptStay),
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
                      ? context.l10n.attemptSavingEllipsis
                      : lastSavedAt == null
                          ? context.l10n.attemptWaitingSync
                          : context.l10n.attemptNotSyncedYet,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (syncFailed)
                TextButton(
                  onPressed: onRetry,
                  child: Text(context.l10n.retry, style: TextStyle(color: foreground)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
