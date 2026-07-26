import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/analytics_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import 'providers/analytics_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    final analyticsAsync = ref.watch(userAnalyticsProvider);
    final userName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : user?.email?.split('@').first ?? 'Student';
    final email = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), elevation: 0),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userAnalyticsProvider);
          await ref.read(userAnalyticsProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          children: [
            _ProfileHeader(name: userName, email: email),
            analyticsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => _AnalyticsError(
                onRetry: () => ref.invalidate(userAnalyticsProvider),
              ),
              data: (analytics) => _PerformanceSummary(analytics: analytics),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ProfileMenu(
              onResults: () => context.go('/results'),
              onLogout: () => ref.read(authControllerProvider).signOut(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = name.trim().isEmpty ? 'S' : name.trim()[0].toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              initial,
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            name,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PerformanceSummary extends StatelessWidget {
  const _PerformanceSummary({required this.analytics});

  final Analytics analytics;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatsCard(analytics: analytics),
        const SizedBox(height: AppSpacing.md),
        if (analytics.totalTestsAttempted == 0)
          const _NoAttemptsCard()
        else
          _InsightsCard(analytics: analytics),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.analytics});

  final Analytics analytics;

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: _StatItem(
                  value: '${analytics.totalTestsAttempted}',
                  label: 'Tests',
                ),
              ),
              _VerticalDivider(color: theme.colorScheme.outlineVariant),
              Expanded(
                child: _StatItem(
                  value: '${_formatPercent(analytics.averageScore)}%',
                  label: 'Avg score',
                ),
              ),
              _VerticalDivider(color: theme.colorScheme.outlineVariant),
              Expanded(
                child: _StatItem(
                  value: '${_formatPercent(analytics.averageAccuracy)}%',
                  label: 'Accuracy',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 42, color: color);
  }
}

class _NoAttemptsCard extends StatelessWidget {
  const _NoAttemptsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          children: [
            Icon(
              Icons.insights_outlined,
              size: 40,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Complete a test to build your profile analytics.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightsCard extends StatelessWidget {
  const _InsightsCard({required this.analytics});

  final Analytics analytics;

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Performance insights',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _InsightRow(
                icon: Icons.trending_up,
                title: 'Strongest sections',
                value: analytics.strongestTopics.isEmpty
                    ? 'Not enough answered questions'
                    : analytics.strongestTopics.join(', '),
                color: Colors.green,
              ),
              const SizedBox(height: AppSpacing.md),
              _InsightRow(
                icon: Icons.trending_down,
                title: 'Needs attention',
                value: analytics.weakestTopics.isEmpty
                    ? 'Not enough answered questions'
                    : analytics.weakestTopics.join(', '),
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: AppSpacing.md),
              _InsightRow(
                icon: Icons.timer_outlined,
                title: 'Average question time',
                value: analytics.averageTimePerQuestion == 0
                    ? 'Timing data unavailable'
                    : _formatDuration(analytics.averageTimePerQuestion),
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalyticsError extends StatelessWidget {
  const _AnalyticsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Text(
                'Unable to load profile analytics.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({required this.onResults, required this.onLogout});

  final VoidCallback onResults;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        _MenuItem(
          icon: Icons.bar_chart,
          title: 'My Results',
          onTap: onResults,
        ),
        const Divider(height: AppSpacing.xl),
        _MenuItem(
          icon: Icons.logout,
          title: 'Logout',
          iconColor: theme.colorScheme.error,
          textColor: theme.colorScheme.error,
          onTap: onLogout,
          showChevron: false,
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedIconColor = iconColor ?? theme.colorScheme.primary;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: resolvedIconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(icon, color: resolvedIconColor, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: textColor ?? theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: showChevron
          ? Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      onTap: onTap,
    );
  }
}

String _formatPercent(double value) {
  if (!value.isFinite) return '0';
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

String _formatDuration(int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final minutes = safe ~/ 60;
  final remainder = safe % 60;
  if (minutes == 0) return '${remainder}s per question';
  return '${minutes}m ${remainder.toString().padLeft(2, '0')}s per question';
}
