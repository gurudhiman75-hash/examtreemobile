import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/analytics_model.dart';
import '../../../core/models/exam_model.dart';
import '../../../core/models/result_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../exams/presentation/providers/exam_providers.dart';
import '../../profile/presentation/providers/analytics_providers.dart';
import '../../results/presentation/providers/result_providers.dart';
import 'home_primary_action.dart';
import 'widgets/home_visual_components.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.now});

  final DateTime Function()? now;

  Future<void> _refreshAll(WidgetRef ref) async {
    ref
      ..invalidate(userAnalyticsProvider)
      ..invalidate(inProgressExamsProvider)
      ..invalidate(availableExamsProvider)
      ..invalidate(userResultsProvider);

    Future<void> settle(Future<Object?> request) async {
      try {
        await request;
      } catch (_) {
        // Home modules recover independently.
      }
    }

    await Future.wait([
      settle(ref.read(userAnalyticsProvider.future)),
      settle(ref.read(inProgressExamsProvider.future)),
      settle(ref.read(availableExamsProvider.future)),
      settle(ref.read(userResultsProvider.future)),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(userAnalyticsProvider);
    final activeAsync = ref.watch(inProgressExamsProvider);
    final availableAsync = ref.watch(availableExamsProvider);
    final resultsAsync = ref.watch(userResultsProvider);
    final user = ref.watch(authStateChangesProvider).value;
    final currentTime = now?.call() ?? DateTime.now();

    final activeTests = activeAsync.value ?? const <Exam>[];
    final availableTests = availableAsync.value ?? const <Exam>[];
    final results = resultsAsync.value ?? const <Result>[];
    final actionState = _resolveActionState(
      activeAsync: activeAsync,
      resultsAsync: resultsAsync,
      availableAsync: availableAsync,
      now: currentTime,
      activeTests: activeTests,
      results: results,
      availableTests: availableTests,
    );

    final primaryExamId = actionState.action?.exam?.id;
    final activeIds = activeTests.map((test) => test.id).toSet();
    final recommendations = availableTests
        .where((test) => test.id != primaryExamId && !activeIds.contains(test.id))
        .take(6)
        .toList(growable: false);
    final remainingActive = actionState.action?.kind == HomePrimaryActionKind.resumeTest
        ? activeTests.skip(1).toList(growable: false)
        : activeTests;
    final latestResult = results.isEmpty ? null : _latestResult(results);

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
                    _CommandHeader(
                      name: _displayName(user?.displayName, user?.email),
                      greeting: _greeting(currentTime),
                      todayLabel: _todayLabel(currentTime),
                      onSearch: () => context.go('/exams'),
                      onProfile: () => context.go('/profile'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PrimaryActionStateView(
                      state: actionState,
                      onOpen: (action) => _openAction(context, action),
                      onBrowse: () => context.go('/exams'),
                      onRetry: () {
                        ref
                          ..invalidate(inProgressExamsProvider)
                          ..invalidate(userResultsProvider)
                          ..invalidate(availableExamsProvider);
                      },
                    ),
                    if (remainingActive.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xl),
                      HomeSectionHeader(
                        title: 'Continue learning',
                        subtitle: remainingActive.length == 1
                            ? 'One more saved attempt is ready.'
                            : '${remainingActive.length} more saved attempts are ready.',
                        actionLabel: 'All tests',
                        onAction: () => context.go('/exams'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _ExamRail(
                        tests: remainingActive,
                        badge: 'RESUME',
                        semanticLabel: 'Saved test attempts',
                        onOpen: (exam) => context.push('/test-attempt', extra: exam.id),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    HomeSectionHeader(
                      title: 'Performance pulse',
                      subtitle: 'Only the signals you need for your next session.',
                      actionLabel: 'Details',
                      onAction: () => context.go('/profile'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    analyticsAsync.when(
                      loading: () => const HomeSkeleton(
                        height: 154,
                        variant: HomeSkeletonVariant.metrics,
                      ),
                      error: (error, stackTrace) => _ErrorCard(
                        title: 'Progress is temporarily unavailable',
                        onRetry: () => ref.invalidate(userAnalyticsProvider),
                      ),
                      data: (analytics) => _PerformancePulse(
                        analytics: analytics,
                        onOpen: () => context.go('/profile'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ContextActions(
                      onTests: () => context.go('/exams'),
                      onResults: () => context.go('/results'),
                    ),
                    if (latestResult != null &&
                        actionState.action?.kind != HomePrimaryActionKind.reviewResult) ...[
                      const SizedBox(height: AppSpacing.xl),
                      const HomeSectionHeader(
                        title: 'Recent result',
                        subtitle: 'Turn the latest attempt into a concrete review action.',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _RecentResultCard(
                        result: latestResult,
                        onOpen: () => context.push('/review', extra: latestResult.attemptId),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    HomeSectionHeader(
                      title: 'Discover your next test',
                      subtitle: 'Available mocks and focused practice papers.',
                      actionLabel: 'View all',
                      onAction: () => context.go('/exams'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    availableAsync.when(
                      loading: () => const HomeSkeleton(
                        height: 198,
                        variant: HomeSkeletonVariant.rail,
                      ),
                      error: (error, stackTrace) => _ErrorCard(
                        title: 'The test catalogue could not be loaded',
                        onRetry: () => ref.invalidate(availableExamsProvider),
                      ),
                      data: (tests) => recommendations.isEmpty
                          ? _CatalogueEmpty(
                              catalogueIsEmpty: tests.isEmpty,
                              onBrowse: () => context.go('/exams'),
                            )
                          : _ExamRail(
                              key: const Key('home-recommendations'),
                              tests: recommendations,
                              semanticLabel: 'Recommended tests',
                              onOpen: (exam) => context.push(
                                '/exam-details',
                                extra: exam.id,
                              ),
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

class _ActionState {
  const _ActionState({this.action, this.loading = false, this.error = false});

  final HomePrimaryAction? action;
  final bool loading;
  final bool error;
}

_ActionState _resolveActionState({
  required AsyncValue<List<Exam>> activeAsync,
  required AsyncValue<List<Result>> resultsAsync,
  required AsyncValue<List<Exam>> availableAsync,
  required DateTime now,
  required List<Exam> activeTests,
  required List<Result> results,
  required List<Exam> availableTests,
}) {
  if (activeAsync.isLoading && activeTests.isEmpty) {
    return const _ActionState(loading: true);
  }
  if (activeTests.isNotEmpty) {
    return _ActionState(
      action: resolveHomePrimaryAction(
        activeTests: activeTests,
        results: results,
        availableTests: availableTests,
        now: now,
      ),
    );
  }
  if (resultsAsync.isLoading && results.isEmpty) {
    return const _ActionState(loading: true);
  }

  final provisional = resolveHomePrimaryAction(
    activeTests: activeTests,
    results: results,
    availableTests: availableTests,
    now: now,
  );
  if (provisional.kind == HomePrimaryActionKind.reviewResult) {
    return _ActionState(action: provisional);
  }
  if (availableAsync.isLoading && availableTests.isEmpty) {
    return const _ActionState(loading: true);
  }
  if (activeAsync.hasError && resultsAsync.hasError && availableAsync.hasError) {
    return const _ActionState(error: true);
  }
  return _ActionState(
    action: resolveHomePrimaryAction(
      activeTests: activeTests,
      results: results,
      availableTests: availableTests,
      now: now,
    ),
  );
}

class _CommandHeader extends StatelessWidget {
  const _CommandHeader({
    required this.name,
    required this.greeting,
    required this.todayLabel,
    required this.onSearch,
    required this.onProfile,
  });

  final String name;
  final String greeting;
  final String todayLabel;
  final VoidCallback onSearch;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      container: true,
      label: '$greeting, $name. $todayLabel.',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.account_tree_rounded,
                color: scheme.onPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, $name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    todayLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Search tests',
              onPressed: onSearch,
              icon: const Icon(Icons.search_rounded),
            ),
            const SizedBox(width: AppSpacing.xxs),
            Semantics(
              button: true,
              label: 'Open profile',
              child: InkWell(
                onTap: onProfile,
                customBorder: const CircleBorder(),
                child: CircleAvatar(
                  radius: 21,
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  child: Text(
                    name.isEmpty ? 'S' : name[0].toUpperCase(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryActionStateView extends StatelessWidget {
  const _PrimaryActionStateView({
    required this.state,
    required this.onOpen,
    required this.onBrowse,
    required this.onRetry,
  });

  final _ActionState state;
  final ValueChanged<HomePrimaryAction> onOpen;
  final VoidCallback onBrowse;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.loading) {
      return const HomeSkeleton(
        height: 236,
        variant: HomeSkeletonVariant.action,
      );
    }
    if (state.error) {
      return _ErrorCard(
        title: 'Your next learning action could not be prepared',
        onRetry: onRetry,
      );
    }

    final action = state.action!;
    return LearningActionCard(
      key: const Key('home-primary-action'),
      icon: _actionIcon(action.kind),
      eyebrow: action.eyebrow,
      title: action.title,
      description: action.description,
      actionLabel: action.actionLabel,
      metadata: _actionMetadata(action),
      onAction: () => onOpen(action),
      secondaryIcon: action.kind == HomePrimaryActionKind.browseTests
          ? null
          : Icons.grid_view_rounded,
      secondaryTooltip: 'Browse all tests',
      onSecondaryAction: action.kind == HomePrimaryActionKind.browseTests
          ? null
          : onBrowse,
    );
  }
}

class _PerformancePulse extends StatelessWidget {
  const _PerformancePulse({required this.analytics, required this.onOpen});

  final Analytics analytics;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final focus = analytics.weakestTopics.isEmpty ? null : analytics.weakestTopics.first;

    return HomeModuleShell(
      key: const Key('home-progress-overview'),
      onTap: onOpen,
      semanticLabel:
          'Performance pulse. ${analytics.totalTestsAttempted} tests. ${analytics.averageScore.round()} percent average score. ${analytics.averageAccuracy.round()} percent accuracy.',
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CompactMetric(
                  value: '${analytics.totalTestsAttempted}',
                  label: 'Tests',
                  icon: Icons.assignment_turned_in_outlined,
                ),
              ),
              Expanded(
                child: CompactMetric(
                  value: '${analytics.averageScore.round()}%',
                  label: 'Average',
                  icon: Icons.insights_rounded,
                ),
              ),
              Expanded(
                child: CompactMetric(
                  value: '${analytics.averageAccuracy.round()}%',
                  label: 'Accuracy',
                  icon: Icons.track_changes_rounded,
                ),
              ),
            ],
          ),
          if (focus != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: scheme.tertiaryContainer.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.adjust_rounded,
                    size: 18,
                    color: scheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Focus next: $focus',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onTertiaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: scheme.onTertiaryContainer,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContextActions extends StatelessWidget {
  const _ContextActions({required this.onTests, required this.onResults});

  final VoidCallback onTests;
  final VoidCallback onResults;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final stack = constraints.maxWidth < 330 || textScale > 1.5;
        final tests = _QuickAction(
          key: const Key('home-context-tests'),
          icon: Icons.explore_rounded,
          title: 'Tests',
          subtitle: 'Find a paper',
          onTap: onTests,
        );
        final results = _QuickAction(
          key: const Key('home-context-results'),
          icon: Icons.fact_check_outlined,
          title: 'Results',
          subtitle: 'Review attempts',
          onTap: onResults,
        );

        if (stack) {
          return Column(
            children: [
              tests,
              const SizedBox(height: AppSpacing.sm),
              results,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: tests),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: results),
          ],
        );
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return HomeModuleShell(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      borderRadius: AppSpacing.radiusLg,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: scheme.onPrimaryContainer, size: 21),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _ExamRail extends StatelessWidget {
  const _ExamRail({
    super.key,
    required this.tests,
    required this.semanticLabel,
    required this.onOpen,
    this.badge,
  });

  final List<Exam> tests;
  final String semanticLabel;
  final ValueChanged<Exam> onOpen;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return HorizontalContentRail(
      height: 190,
      semanticLabel: semanticLabel,
      children: tests
          .map(
            (exam) => _ExamCard(
              exam: exam,
              badge: badge,
              onTap: () => onOpen(exam),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam, required this.onTap, this.badge});

  final Exam exam;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return HomeModuleShell(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      semanticLabel:
          '${exam.title}. ${exam.totalQuestions} questions. ${exam.durationInSeconds ~/ 60} minutes.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: badge != null
                      ? scheme.secondaryContainer
                      : scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  badge ?? (exam.category.trim().isEmpty ? 'TEST' : exam.category.toUpperCase()),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: badge != null
                        ? scheme.onSecondaryContainer
                        : scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_outward_rounded, size: 18, color: scheme.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            exam.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.18,
            ),
          ),
          const Spacer(),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _MiniMeta(
                icon: Icons.timer_outlined,
                label: '${exam.durationInSeconds ~/ 60} min',
              ),
              _MiniMeta(
                icon: Icons.help_outline_rounded,
                label: '${exam.totalQuestions} Qs',
              ),
              if (exam.difficulty.trim().isNotEmpty)
                _MiniMeta(
                  icon: Icons.signal_cellular_alt_rounded,
                  label: exam.difficulty,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMeta extends StatelessWidget {
  const _MiniMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RecentResultCard extends StatelessWidget {
  const _RecentResultCard({required this.result, required this.onOpen});

  final Result result;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return HomeModuleShell(
      onTap: onOpen,
      semanticLabel:
          '${result.testName}. ${result.percentageScore.round()} percent score. ${result.accuracy.round()} percent accuracy.',
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            alignment: Alignment.center,
            child: Text(
              '${result.percentageScore.round().clamp(0, 100)}%',
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.onSecondaryContainer,
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
                  result.testName.trim().isEmpty ? 'Latest result' : result.testName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${result.accuracy.round().clamp(0, 100)}% accuracy · ${result.correctCount} correct',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(Icons.arrow_forward_rounded, color: scheme.primary),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.title, required this.onRetry});

  final String title;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HomeModuleShell(
      borderColor: theme.colorScheme.error.withValues(alpha: 0.28),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: theme.colorScheme.error),
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

class _CatalogueEmpty extends StatelessWidget {
  const _CatalogueEmpty({required this.catalogueIsEmpty, required this.onBrowse});

  final bool catalogueIsEmpty;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HomeModuleShell(
      child: Row(
        children: [
          Icon(
            catalogueIsEmpty ? Icons.inventory_2_outlined : Icons.check_circle_outline_rounded,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              catalogueIsEmpty
                  ? 'No tests are available right now.'
                  : 'You have already surfaced the most relevant available tests.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (!catalogueIsEmpty)
            TextButton(onPressed: onBrowse, child: const Text('Browse')),
        ],
      ),
    );
  }
}

List<HomeActionMetadata> _actionMetadata(HomePrimaryAction action) {
  final exam = action.exam;
  final result = action.result;
  if (exam != null) {
    return [
      HomeActionMetadata(
        icon: Icons.timer_outlined,
        label: '${exam.durationInSeconds ~/ 60} min',
      ),
      HomeActionMetadata(
        icon: Icons.help_outline_rounded,
        label: '${exam.totalQuestions} questions',
      ),
      if (exam.difficulty.trim().isNotEmpty)
        HomeActionMetadata(
          icon: Icons.signal_cellular_alt_rounded,
          label: exam.difficulty,
        ),
    ];
  }
  if (result != null) {
    return [
      HomeActionMetadata(
        icon: Icons.stars_rounded,
        label: '${result.percentageScore.round().clamp(0, 100)}% score',
      ),
      HomeActionMetadata(
        icon: Icons.track_changes_rounded,
        label: '${result.accuracy.round().clamp(0, 100)}% accuracy',
      ),
      HomeActionMetadata(
        icon: Icons.check_circle_outline_rounded,
        label: '${result.correctCount} correct',
      ),
    ];
  }
  return const [
    HomeActionMetadata(
      icon: Icons.auto_awesome_rounded,
      label: 'Live test catalogue',
    ),
  ];
}

IconData _actionIcon(HomePrimaryActionKind kind) {
  return switch (kind) {
    HomePrimaryActionKind.resumeTest => Icons.play_arrow_rounded,
    HomePrimaryActionKind.reviewResult => Icons.fact_check_rounded,
    HomePrimaryActionKind.startTest => Icons.rocket_launch_rounded,
    HomePrimaryActionKind.browseTests => Icons.explore_rounded,
  };
}

void _openAction(BuildContext context, HomePrimaryAction action) {
  switch (action.kind) {
    case HomePrimaryActionKind.resumeTest:
      context.push('/test-attempt', extra: action.exam!.id);
      return;
    case HomePrimaryActionKind.reviewResult:
      context.push('/review', extra: action.result!.attemptId);
      return;
    case HomePrimaryActionKind.startTest:
      context.push('/exam-details', extra: action.exam!.id);
      return;
    case HomePrimaryActionKind.browseTests:
      context.go('/exams');
      return;
  }
}

Result _latestResult(List<Result> results) {
  final sorted = [...results]
    ..sort((left, right) => right.calculatedAt.compareTo(left.calculatedAt));
  return sorted.first;
}

String _displayName(String? displayName, String? email) {
  final name = displayName?.trim();
  if (name != null && name.isNotEmpty) return name.split(' ').first;
  final localPart = email?.split('@').first.trim();
  if (localPart != null && localPart.isNotEmpty) return localPart;
  return 'Student';
}

String _greeting(DateTime now) {
  final hour = now.hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

String _todayLabel(DateTime now) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
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
  return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
}
