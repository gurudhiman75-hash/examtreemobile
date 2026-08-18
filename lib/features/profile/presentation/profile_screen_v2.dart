import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_visual_components.dart';
import '../../../shared/widgets/network_failure_view.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import 'providers/analytics_providers.dart';
import 'widgets/performance_dashboard.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(performanceAnalyticsProvider)
      ..invalidate(userAnalyticsProvider);
    try {
      await ref.read(performanceAnalyticsProvider.future);
    } catch (_) {
      // The analytics module renders its own recoverable error state.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    final analyticsAsync = ref.watch(performanceAnalyticsProvider);
    final userName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : user?.email?.split('@').first ?? 'Student';
    final email = user?.email ?? '';
    final initial = userName.trim().isEmpty
        ? 'S'
        : userName.trim()[0].toUpperCase();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  0,
                ),
                child: AppPageHeader(
                  eyebrow: 'ACCOUNT',
                  title: userName,
                  subtitle: email.isEmpty
                      ? 'Your ExamTree learner profile and performance.'
                      : email,
                  leading: _ProfileAvatar(initial: initial),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: AppSectionHeader(
                  title: 'My progress',
                  subtitle:
                      'Performance from your completed tests and reviewed attempts.',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              analyticsAsync.when(
                loading: () => const _PerformanceLoadingState(),
                error: (error, stackTrace) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: NetworkFailureCard(
                    error: error,
                    fallbackTitle: 'Unable to load your performance',
                    onRetry: () =>
                        ref.invalidate(performanceAnalyticsProvider),
                  ),
                ),
                data: (analytics) => PerformanceDashboard(
                  analytics: analytics,
                  onOpenResults: () => context.go('/results'),
                  onReviewLatest: analytics.latestAttemptId == null
                      ? null
                      : () => context.push(
                            '/review',
                            extra: analytics.latestAttemptId,
                          ),
                  onBrowseTests: () => context.go('/exams'),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: AppSectionHeader(
                  title: 'Account',
                  subtitle: 'Results history and this device session.',
                ),
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Profile avatar',
      child: CircleAvatar(
        radius: 24,
        backgroundColor: theme.colorScheme.primary,
        child: Text(
          initial,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _PerformanceLoadingState extends StatelessWidget {
  const _PerformanceLoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          for (var index = 0; index < 3; index++) ...[
            Container(
              height: index == 0 ? 220 : 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
            ),
            if (index != 2) const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            _MenuItem(
              icon: Icons.bar_chart_outlined,
              title: 'My results',
              subtitle: 'Search, sort and review completed attempts',
              onTap: onResults,
            ),
            const Divider(height: 1),
            _MenuItem(
              icon: Icons.logout_rounded,
              title: 'Sign out',
              subtitle: 'End this device session',
              iconColor: theme.colorScheme.error,
              textColor: theme.colorScheme.error,
              onTap: onLogout,
              showChevron: false,
            ),
          ],
        ),
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
    this.iconColor,
    this.textColor,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedIconColor = iconColor ?? theme.colorScheme.primary;

    return ListTile(
      minTileHeight: 64,
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: resolvedIconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Icon(icon, color: resolvedIconColor, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: textColor ?? theme.colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: showChevron
          ? Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      onTap: onTap,
    );
  }
}
