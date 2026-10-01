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
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE3E9F1)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10264A).withValues(alpha: .04),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    _iconFor(guidance.kind),
                    size: 29,
                    color: const Color(0xFF0B5D96),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  guidance.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF10264A),
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  guidance.message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF718096),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: const Color(0xFF073A6A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                ),
              ],
            ),
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
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE3E9F1)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10264A).withValues(alpha: .03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _iconFor(guidance.kind),
                size: 23,
                color: const Color(0xFF0B5D96),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              guidance.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF10264A),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              guidance.message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF718096),
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF073A6A),
                side: const BorderSide(color: Color(0xFFB7C8DA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
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
