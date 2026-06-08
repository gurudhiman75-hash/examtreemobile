import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import 'providers/analytics_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analyticsAsync = ref.watch(userAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: analyticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (analytics) {
          const userName = 'Alex Johnson'; // Mock user info
          const email = 'alex.johnson@example.com';
          final testsAttempted = analytics.totalTestsAttempted;
          final averageScore = analytics.averageScore.toInt();
          final accuracy = analytics.averageAccuracy;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(theme, userName, email),
                const SizedBox(height: AppSpacing.lg),
                _buildStatsRow(theme, testsAttempted, averageScore, accuracy),
                const SizedBox(height: AppSpacing.xl),
                _buildMenuSection(theme, context),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, String name, String email) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                name[0].toUpperCase(),
                style: theme.textTheme.displayMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            name,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            email,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme, int testsAttempted, int avgScore, double accuracy) {
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(theme, '$testsAttempted', 'Tests'),
              Container(width: 1, height: 40, color: theme.colorScheme.outlineVariant),
              _buildStatItem(theme, '$avgScore%', 'Avg Score'),
              Container(width: 1, height: 40, color: theme.colorScheme.outlineVariant),
              _buildStatItem(theme, '$accuracy%', 'Accuracy'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildMenuSection(ThemeData theme, BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          theme: theme,
          icon: Icons.bar_chart,
          title: 'My Results',
          onTap: () {},
        ),
        _buildMenuItem(
          theme: theme,
          icon: Icons.settings_outlined,
          title: 'Settings',
          onTap: () {},
        ),
        _buildMenuItem(
          theme: theme,
          icon: Icons.info_outline,
          title: 'About ExamTree',
          onTap: () {},
        ),
        const Divider(height: AppSpacing.xl),
        _buildMenuItem(
          theme: theme,
          icon: Icons.logout,
          title: 'Logout',
          iconColor: theme.colorScheme.error,
          textColor: theme.colorScheme.error,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: (iconColor ?? theme.colorScheme.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(
          icon,
          color: iconColor ?? theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: textColor ?? theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      onTap: onTap,
    );
  }
}
