import 'package:flutter/material.dart';

import '../../core/network/network_failure_guidance.dart';
import '../../core/theme/app_spacing.dart';

class NetworkFailureView extends StatelessWidget {
  const NetworkFailureView({
    super.key,
    required this.error,
    required this.fallbackTitle,
    required this.onRetry,
  });

  final Object error;
  final String fallbackTitle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final guidance = networkFailureGuidance(
      error,
      fallbackTitle: fallbackTitle,
    );
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _iconFor(guidance.kind),
                size: 56,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                guidance.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                guidance.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NetworkFailureCard extends StatelessWidget {
  const NetworkFailureCard({
    super.key,
    required this.error,
    required this.fallbackTitle,
    required this.onRetry,
  });

  final Object error;
  final String fallbackTitle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final guidance = networkFailureGuidance(
      error,
      fallbackTitle: fallbackTitle,
    );
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Icon(
                _iconFor(guidance.kind),
                size: 40,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                guidance.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                guidance.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _iconFor(NetworkFailureKind kind) {
  return switch (kind) {
    NetworkFailureKind.offline => Icons.wifi_off_rounded,
    NetworkFailureKind.timeout => Icons.timer_off_outlined,
    NetworkFailureKind.session => Icons.lock_clock_outlined,
    NetworkFailureKind.forbidden => Icons.lock_outline_rounded,
    NetworkFailureKind.rateLimited => Icons.hourglass_top_rounded,
    NetworkFailureKind.server => Icons.cloud_off_outlined,
    NetworkFailureKind.secureConnection => Icons.gpp_maybe_outlined,
    NetworkFailureKind.unknown => Icons.sync_problem_rounded,
  };
}
