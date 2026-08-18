import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/network_failure_view.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../domain/performance_analytics.dart';
import 'providers/analytics_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(performanceAnalyticsProvider)
      ..invalidate(userAnalyticsProvider);
    try {
      await ref.read(performanceAnalyticsProvider.future);
    } catch (_) {
      // The performance module renders its own recoverable state.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;
    final analyticsAsync = ref.watch(performanceAnalyticsProvider);
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : user?.email?.split('@').first ?? 'Student';
    final email = user?.email ?? '';
    final initial = name.trim().isEmpty ? 'S' : name.trim()[0].toUpperCase();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            children: [
              _ProfileHeader(name: name, email: email, initial: initial),
              const SizedBox(height: AppSpacing.xl),
              analyticsAsync.when(
                loading: () => const _ProfileLoadingState(),
                error: (error, stackTrace) => NetworkFailureCard(
                  error: error,
                  fallbackTitle: 'Unable to load your performance',
                  onRetry: () => ref.invalidate(performanceAnalyticsProvider),
                ),
                data: (analytics) => _PerformanceProfile(
                  analytics: analytics,
                  onOpenResults: () => context.go('/results'),
                  onBrowseTests: () => context.go('/exams'),
                  onReviewLatest: analytics.latestAttemptId == null
                      ? null
                      : () => context.push(
                            '/review',
                            extra: analytics.latestAttemptId,
                          ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _SectionTitle(
                title: 'Account',
                subtitle: 'Your history and this device session.',
              ),
              const SizedBox(height: AppSpacing.sm),
              _AccountMenu(
                onResults: () => context.go('/results'),
                onLogout: () => ref.read(authControllerProvider).signOut(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.initial,
  });

  final String name;
  final String email;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      container: true,
      label: email.isEmpty ? 'Profile for $name' : 'Profile for $name, $email',
      child: Row(
        children: [
          CircleAvatar(
            radius: 29,
            backgroundColor: scheme.primary,
            child: Text(
              initial,
              style: theme.textTheme.titleLarge?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your profile',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.35,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceProfile extends StatelessWidget {
  const _PerformanceProfile({
    required this.analytics,
    required this.onOpenResults,
    required this.onBrowseTests,
    required this.onReviewLatest,
  });

  final PerformanceAnalytics analytics;
  final VoidCallback onOpenResults;
  final VoidCallback onBrowseTests;
  final VoidCallback? onReviewLatest;

  @override
  Widget build(BuildContext context) {
    if (analytics.totalTestsAttempted == 0) {
      return _EmptyPerformance(onBrowseTests: onBrowseTests);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Performance',
          subtitle: 'Your completed-test signals at a glance.',
          trailing: TextButton(
            onPressed: onOpenResults,
            child: const Text('Full history'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _PerformanceSnapshot(analytics: analytics),
        const SizedBox(height: AppSpacing.md),
        _FocusCard(
          analytics: analytics,
          onOpenResults: onOpenResults,
          onReviewLatest: onReviewLatest,
        ),
        if (analytics.scoreTrend.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          const _SectionTitle(
            title: 'Recent trend',
            subtitle: 'Your latest completed tests.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _RecentTrend(analytics: analytics),
        ],
      ],
    );
  }
}

class _PerformanceSnapshot extends StatelessWidget {
  const _PerformanceSnapshot({required this.analytics});

  final PerformanceAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricData(
        value: '${analytics.totalTestsAttempted}',
        label: 'Tests',
        icon: Icons.assignment_turned_in_outlined,
      ),
      _MetricData(
        value: '${_formatPercent(analytics.averageScore)}%',
        label: 'Avg score',
        icon: Icons.score_outlined,
      ),
      _MetricData(
        value: '${_formatPercent(analytics.averageAccuracy)}%',
        label: 'Accuracy',
        icon: Icons.track_changes_outlined,
      ),
      _MetricData(
        value: analytics.hasTimingData
            ? _formatDuration(analytics.averageTimePerQuestion)
            : '—',
        label: 'Avg time',
        icon: Icons.timer_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.sm;
        final width = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final metric in metrics)
              SizedBox(width: width, child: _MetricTile(metric: metric)),
          ],
        );
      },
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});

  final _MetricData metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      label: '${metric.label}: ${metric.value}',
      excludeSemantics: true,
      child: Material(
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(metric.icon, size: 20, color: scheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      metric.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({
    required this.analytics,
    required this.onOpenResults,
    required this.onReviewLatest,
  });

  final PerformanceAnalytics analytics;
  final VoidCallback onOpenResults;
  final VoidCallback? onReviewLatest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strongest = analytics.strongestSection;
    final weakest = analytics.weakestSection;

    return Material(
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.insights_rounded, color: scheme.secondary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'What to focus on',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (analytics.latestScoreChange != null)
                  _ChangeBadge(change: analytics.latestScoreChange!),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (strongest == null && weakest == null)
              Text(
                'Section detail will appear after reviewed questions are available.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              )
            else ...[
              if (strongest != null)
                _SectionSignal(
                  label: 'Strongest',
                  section: strongest,
                  icon: Icons.trending_up_rounded,
                  accent: scheme.secondary,
                ),
              if (strongest != null && weakest != null)
                const SizedBox(height: AppSpacing.sm),
              if (weakest != null)
                _SectionSignal(
                  label: 'Needs attention',
                  section: weakest,
                  icon: Icons.flag_outlined,
                  accent: scheme.tertiary,
                ),
            ],
            const SizedBox(height: AppSpacing.md),
            if (onReviewLatest != null) ...[
              FilledButton.icon(
                key: const Key('profile-review-latest'),
                onPressed: onReviewLatest,
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Review latest'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            OutlinedButton.icon(
              onPressed: onOpenResults,
              icon: const Icon(Icons.history_rounded),
              label: const Text('Results'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionSignal extends StatelessWidget {
  const _SectionSignal({
    required this.label,
    required this.section,
    required this.icon,
    required this.accent,
  });

  final String label;
  final SectionPerformance section;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  section.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${_formatPercent(section.accuracy)}% accuracy',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({required this.change});

  final double change;

  @override
  Widget build(BuildContext context) {
    final positive = change >= 0;
    final theme = Theme.of(context);
    final color = positive ? theme.colorScheme.secondary : theme.colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Text(
        '${positive ? '+' : '−'}${_formatPercent(change.abs())} pts',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RecentTrend extends StatelessWidget {
  const _RecentTrend({required this.analytics});

  final PerformanceAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final points = analytics.scoreTrend.length <= 4
        ? analytics.scoreTrend
        : analytics.scoreTrend.sublist(analytics.scoreTrend.length - 4);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          for (var index = 0; index < points.length; index++) ...[
            _TrendRow(point: points[index]),
            if (index != points.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _TrendRow extends StatelessWidget {
  const _TrendRow({required this.point});

  final PerformanceTrendPoint point;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = point.percentageScore.clamp(0, 100).toDouble();
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(value: score / 100, strokeWidth: 4),
                Center(
                  child: Text(
                    '${score.round()}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.testName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${_formatPercent(point.accuracy)}% accuracy · ${_formatDate(point.completedAt)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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

class _EmptyPerformance extends StatelessWidget {
  const _EmptyPerformance({required this.onBrowseTests});

  final VoidCallback onBrowseTests;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(
              Icons.insights_outlined,
              size: 44,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Your performance starts with your first test',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Complete a test to build score, accuracy, section and trend insights here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onBrowseTests,
              icon: const Icon(Icons.assignment_outlined),
              label: const Text('Browse tests'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
    if (trailing == null) return copy;
    if (textScale > 1.5) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [copy, const SizedBox(height: AppSpacing.xs), trailing!],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: copy),
        const SizedBox(width: AppSpacing.sm),
        trailing!,
      ],
    );
  }
}

class _AccountMenu extends StatelessWidget {
  const _AccountMenu({required this.onResults, required this.onLogout});

  final VoidCallback onResults;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.history_rounded,
            title: 'My results',
            subtitle: 'Search and review completed attempts',
            onTap: onResults,
          ),
          const Divider(height: 1),
          _MenuItem(
            icon: Icons.logout_rounded,
            title: 'Sign out',
            subtitle: 'End this device session',
            onTap: onLogout,
            destructive: true,
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = destructive
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    return ListTile(
      minTileHeight: 64,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: destructive ? theme.colorScheme.error : null,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: destructive ? null : const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _ProfileLoadingState extends StatelessWidget {
  const _ProfileLoadingState();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHigh;
    return Column(
      children: [
        for (var index = 0; index < 3; index++) ...[
          Container(
            height: index == 0 ? 170 : 110,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
          ),
          if (index != 2) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

String _formatPercent(double value) {
  final safe = value.clamp(0, 100).toDouble();
  if (safe == safe.roundToDouble()) return safe.toInt().toString();
  return safe.toStringAsFixed(1);
}

String _formatDuration(int seconds) {
  if (seconds < 60) return '${seconds}s';
  final minutes = seconds ~/ 60;
  final remainder = seconds % 60;
  return remainder == 0 ? '${minutes}m' : '${minutes}m ${remainder}s';
}

String _formatDate(DateTime value) {
  if (value.millisecondsSinceEpoch == 0) return 'Date unavailable';
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
  return '${local.day} ${months[local.month - 1]}';
}
