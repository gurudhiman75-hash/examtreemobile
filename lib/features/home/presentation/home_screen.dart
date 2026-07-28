import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/analytics_model.dart';
import '../../../core/models/exam_model.dart';
import '../../../core/models/result_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../exams/presentation/providers/exam_providers.dart';
import '../../exams/presentation/widgets/exam_card.dart';
import '../../profile/presentation/providers/analytics_providers.dart';
import '../../results/presentation/providers/result_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refreshAll(WidgetRef ref) async {
    Future<void> settle(Future<Object?> request) async {
      try {
        await request;
      } catch (_) {
        // Each dashboard section renders its own retry state.
      }
    }

    await Future.wait([
      settle(ref.refresh(userAnalyticsProvider.future)),
      settle(ref.refresh(inProgressExamsProvider.future)),
      settle(ref.refresh(availableExamsProvider.future)),
      settle(ref.refresh(userResultsProvider.future)),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(userAnalyticsProvider);
    final inProgressAsync = ref.watch(inProgressExamsProvider);
    final availableAsync = ref.watch(availableExamsProvider);
    final resultsAsync = ref.watch(userResultsProvider);
    final user = ref.watch(authStateChangesProvider).value;
    final userName = _displayName(user?.displayName, user?.email);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refreshAll(ref),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xxl,
                ),
                sliver: SliverList.list(
                  children: [
                    _WelcomeHeader(
                      name: userName,
                      onProfileTap: () => context.go('/profile'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _QuickActions(
                      onBrowseTests: () => context.go('/exams'),
                      onViewResults: () => context.go('/results'),
                      onOpenProfile: () => context.go('/profile'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _SectionHeading(
                      title: 'Your progress',
                      subtitle: 'A quick view of your recent performance',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    analyticsAsync.when(
                      loading: () => const _DashboardSkeleton(height: 150),
                      error: (error, stackTrace) => _SectionErrorCard(
                        title: 'Performance is temporarily unavailable',
                        onRetry: () => ref.invalidate(userAnalyticsProvider),
                      ),
                      data: (analytics) => _PerformanceCard(
                        analytics: analytics,
                        onOpenProfile: () => context.go('/profile'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    inProgressAsync.when(
                      loading: () => const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeading(
                            title: 'Continue learning',
                            subtitle: 'Your active test will appear here',
                          ),
                          SizedBox(height: AppSpacing.sm),
                          _DashboardSkeleton(height: 150),
                        ],
                      ),
                      error: (error, stackTrace) => _SectionErrorCard(
                        title: 'Could not check active tests',
                        onRetry: () => ref.invalidate(inProgressExamsProvider),
                      ),
                      data: (tests) => tests.isEmpty
                          ? const SizedBox.shrink()
                          : _ContinueSection(
                              tests: tests,
                              onOpen: (test) => context.push(
                                '/test-attempt',
                                extra: test.id,
                              ),
                            ),
                    ),
                    resultsAsync.when(
                      loading: () => const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppSpacing.lg),
                          _SectionHeading(
                            title: 'Latest result',
                            subtitle: 'Your most recent completed attempt',
                          ),
                          SizedBox(height: AppSpacing.sm),
                          _DashboardSkeleton(height: 130),
                        ],
                      ),
                      error: (error, stackTrace) => Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.lg),
                        child: _SectionErrorCard(
                          title: 'Could not load your latest result',
                          onRetry: () => ref.invalidate(userResultsProvider),
                        ),
                      ),
                      data: (results) => results.isEmpty
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.lg),
                              child: _LatestResultSection(
                                result: results.first,
                                onOpen: () => context.push(
                                  '/review',
                                  extra: results.first.attemptId,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _SectionHeading(
                      title: 'Recommended tests',
                      subtitle: 'Fresh papers ready for your next attempt',
                      actionLabel: 'View all',
                      onAction: () => context.go('/exams'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    availableAsync.when(
                      loading: () => const Column(
                        children: [
                          _DashboardSkeleton(height: 150),
                          SizedBox(height: AppSpacing.md),
                          _DashboardSkeleton(height: 150),
                        ],
                      ),
                      error: (error, stackTrace) => _SectionErrorCard(
                        title: 'Recommendations could not be loaded',
                        onRetry: () => ref.invalidate(availableExamsProvider),
                      ),
                      data: (tests) => tests.isEmpty
                          ? _NoTestsCard(
                              onBrowse: () => context.go('/exams'),
                            )
                          : Column(
                              children: tests
                                  .take(2)
                                  .map(
                                    (test) => ExamCard(
                                      title: test.title,
                                      subject: test.category,
                                      description: test.description,
                                      duration:
                                          '${test.durationInSeconds ~/ 60} min',
                                      totalQuestions: test.totalQuestions,
                                      difficulty: test.difficulty,
                                      status: test.status == 'paid'
                                          ? 'Paid'
                                          : 'Available',
                                      onTap: () => context.push(
                                        '/exam-details',
                                        extra: test.id,
                                      ),
                                    ),
                                  )
                                  .toList(),
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

String _displayName(String? displayName, String? email) {
  final name = displayName?.trim();
  if (name != null && name.isNotEmpty) return name.split(' ').first;
  final localPart = email?.split('@').first.trim();
  if (localPart != null && localPart.isNotEmpty) return localPart;
  return 'Student';
}

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

String _formatDate(DateTime date) {
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
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.name, required this.onProfileTap});

  final String name;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.76),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Build momentum with one focused test today.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.88),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Semantics(
            button: true,
            label: 'Open profile',
            child: InkWell(
              onTap: onProfileTap,
              customBorder: const CircleBorder(),
              child: CircleAvatar(
                radius: 26,
                backgroundColor:
                    theme.colorScheme.onPrimary.withValues(alpha: 0.16),
                child: Text(
                  name.isEmpty ? 'S' : name[0].toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onBrowseTests,
    required this.onViewResults,
    required this.onOpenProfile,
  });

  final VoidCallback onBrowseTests;
  final VoidCallback onViewResults;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.explore_outlined,
            label: 'Explore',
            onTap: onBrowseTests,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickAction(
            icon: Icons.insights_outlined,
            label: 'Results',
            onTap: onViewResults,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickAction(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            onTap: onOpenProfile,
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({
    required this.analytics,
    required this.onOpenProfile,
  });

  final Analytics analytics;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strongestTopic = analytics.strongestTopics.isEmpty
        ? null
        : analytics.strongestTopics.first;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onOpenProfile,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      icon: Icons.assignment_turned_in_outlined,
                      value: '${analytics.totalTestsAttempted}',
                      label: 'Tests taken',
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      icon: Icons.stars_outlined,
                      value: '${analytics.averageScore.round()}%',
                      label: 'Average score',
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      icon: Icons.track_changes_outlined,
                      value: '${analytics.averageAccuracy.round()}%',
                      label: 'Accuracy',
                    ),
                  ),
                ],
              ),
              if (strongestTopic != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.workspace_premium_outlined,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Strongest area: $strongestTopic',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 22),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ContinueSection extends StatelessWidget {
  const _ContinueSection({required this.tests, required this.onOpen});

  final List<Exam> tests;
  final ValueChanged<Exam> onOpen;

  @override
  Widget build(BuildContext context) {
    final test = tests.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        _SectionHeading(
          title: 'Continue learning',
          subtitle: tests.length == 1
              ? 'One active test is ready to resume'
              : '${tests.length} active tests are ready to resume',
        ),
        const SizedBox(height: AppSpacing.sm),
        ExamCard(
          title: test.title,
          subject: test.category,
          description: test.description,
          duration: '${test.durationInSeconds ~/ 60} min',
          totalQuestions: test.totalQuestions,
          difficulty: test.difficulty,
          status: 'In Progress',
          onTap: () => onOpen(test),
        ),
      ],
    );
  }
}

class _LatestResultSection extends StatelessWidget {
  const _LatestResultSection({required this.result, required this.onOpen});

  final Result result;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          title: 'Latest result',
          subtitle: 'Your most recent completed attempt',
        ),
        const SizedBox(height: AppSpacing.sm),
        _LatestResultCard(result: result, onOpen: onOpen),
      ],
    );
  }
}

class _LatestResultCard extends StatelessWidget {
  const _LatestResultCard({required this.result, required this.onOpen});

  final Result result;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = result.percentageScore.round().clamp(0, 100);
    final title = result.testName.trim().isEmpty
        ? 'Completed test'
        : result.testName;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.42),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: BorderSide(color: theme.colorScheme.secondaryContainer),
      ),
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              SizedBox(
                width: 62,
                height: 62,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 6,
                      backgroundColor:
                          theme.colorScheme.surface.withValues(alpha: 0.6),
                    ),
                    Center(
                      child: Text(
                        '$score%',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSecondaryContainer,
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
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${result.correctCount} correct · ${result.incorrectCount} incorrect',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _formatDate(result.calculatedAt.toLocal()),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.arrow_forward_rounded,
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionErrorCard extends StatelessWidget {
  const _SectionErrorCard({required this.title, required this.onRetry});

  final String title;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.sync_problem_rounded, color: theme.colorScheme.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(strokeWidth: 2.5),
    );
  }
}

class _NoTestsCard extends StatelessWidget {
  const _NoTestsCard({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 44,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No recommendations yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Explore the complete catalogue or pull down to refresh.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onBrowse,
            icon: const Icon(Icons.explore_outlined),
            label: const Text('Explore tests'),
          ),
        ],
      ),
    );
  }
}
