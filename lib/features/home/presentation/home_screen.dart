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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
        // Each module renders its own recoverable error state.
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

    final activeTests = activeAsync.value ?? const <Exam>[];
    final availableTests = availableAsync.value ?? const <Exam>[];
    final results = resultsAsync.value ?? const <Result>[];
    final actionState = _resolveActionState(
      activeAsync: activeAsync,
      resultsAsync: resultsAsync,
      availableAsync: availableAsync,
      activeTests: activeTests,
      results: results,
      availableTests: availableTests,
    );

    final primaryExamId = actionState.action?.exam?.id;
    final activeIds = activeTests.map((test) => test.id).toSet();
    final recommendations = availableTests
        .where(
          (test) => test.id != primaryExamId && !activeIds.contains(test.id),
        )
        .take(6)
        .toList(growable: false);
    final otherActive = actionState.action?.kind ==
            HomePrimaryActionKind.resumeTest
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
                      onSearch: () => context.go('/exams'),
                      onProfile: () => context.go('/profile'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _SectionTitle(
                      title: 'Next best action',
                      subtitle: 'One clear step based on your current activity',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ActionStateView(
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
                    const SizedBox(height: AppSpacing.md),
                    _QuickLinks(
                      onTests: () => context.go('/exams'),
                      onResults: () => context.go('/results'),
                      onProfile: () => context.go('/profile'),
                    ),
                    if (otherActive.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xl),
                      _SectionTitle(
                        title: 'Continue learning',
                        subtitle: otherActive.length == 1
                            ? 'One more active test is ready'
                            : '${otherActive.length} more active tests are ready',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _ExamRail(
                        tests: otherActive,
                        label: 'Resume',
                        onOpen: (test) => context.push(
                          '/test-attempt',
                          extra: test.id,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionTitle(
                      title: 'Performance pulse',
                      subtitle: 'Enough insight to decide what to do next',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    analyticsAsync.when(
                      loading: () => const _Skeleton(height: 146),
                      error: (error, stackTrace) => _ErrorCard(
                        title: 'Performance data is temporarily unavailable',
                        onRetry: () => ref.invalidate(userAnalyticsProvider),
                      ),
                      data: (analytics) => _PerformancePulse(
                        analytics: analytics,
                        onOpen: () => context.go('/profile'),
                      ),
                    ),
                    if (latestResult != null &&
                        actionState.action?.kind !=
                            HomePrimaryActionKind.reviewResult) ...[
                      const SizedBox(height: AppSpacing.xl),
                      const _SectionTitle(
                        title: 'Latest result',
                        subtitle: 'Return to the questions behind this score',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _LatestResultCard(
                        result: latestResult,
                        onOpen: () => context.push(
                          '/review',
                          extra: latestResult.attemptId,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    _SectionTitle(
                      title: 'Recommended for you',
                      subtitle: 'Fresh tests from your available catalogue',
                      actionLabel: 'View all',
                      onAction: () => context.go('/exams'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    availableAsync.when(
                      loading: () => const _Skeleton(height: 190),
                      error: (error, stackTrace) => _ErrorCard(
                        title: 'Recommendations could not be loaded',
                        onRetry: () => ref.invalidate(availableExamsProvider),
                      ),
                      data: (tests) => recommendations.isEmpty
                          ? _RecommendationEmpty(
                              catalogueIsEmpty: tests.isEmpty,
                              onBrowse: () => context.go('/exams'),
                            )
                          : _ExamRail(
                              tests: recommendations,
                              label: null,
                              onOpen: (test) => context.push(
                                '/exam-details',
                                extra: test.id,
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
  );
  if (provisional.kind == HomePrimaryActionKind.reviewResult) {
    return _ActionState(action: provisional);
  }
  if (availableAsync.isLoading && availableTests.isEmpty) {
    return const _ActionState(loading: true);
  }
  if (activeAsync.hasError &&
      resultsAsync.hasError &&
      availableAsync.hasError) {
    return const _ActionState(error: true);
  }
  return _ActionState(
    action: resolveHomePrimaryAction(
      activeTests: activeTests,
      results: results,
      availableTests: availableTests,
    ),
  );
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

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

String _todayLabel() {
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
  final now = DateTime.now();
  return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
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
  final local = date.toLocal();
  return '${local.day} ${months[local.month - 1]} ${local.year}';
}

class _CommandHeader extends StatelessWidget {
  const _CommandHeader({
    required this.name,
    required this.onSearch,
    required this.onProfile,
  });

  final String name;
  final VoidCallback onSearch;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_greeting()},',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                _todayLabel(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Search tests',
          onPressed: onSearch,
          icon: const Icon(Icons.search_rounded),
        ),
        const SizedBox(width: AppSpacing.sm),
        InkWell(
          onTap: onProfile,
          customBorder: const CircleBorder(),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              name.isEmpty ? 'S' : name[0].toUpperCase(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionStateView extends StatelessWidget {
  const _ActionStateView({
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
    if (state.loading) return const _Skeleton(height: 210);
    if (state.error) {
      return _ErrorCard(
        title: 'Your next action could not be prepared',
        onRetry: onRetry,
      );
    }
    final action = state.action!;
    return _PrimaryActionCard(
      action: action,
      onOpen: () => onOpen(action),
      onBrowse: onBrowse,
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  const _PrimaryActionCard({
    required this.action,
    required this.onOpen,
    required this.onBrowse,
  });

  final HomePrimaryAction action;
  final VoidCallback onOpen;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = switch (action.kind) {
      HomePrimaryActionKind.resumeTest => Icons.play_circle_outline_rounded,
      HomePrimaryActionKind.reviewResult => Icons.fact_check_outlined,
      HomePrimaryActionKind.startTest => Icons.rocket_launch_outlined,
      HomePrimaryActionKind.browseTests => Icons.explore_outlined,
    };

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
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Icon(icon, color: theme.colorScheme.onPrimary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.eyebrow.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.76),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      action.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            action.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.86),
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ActionMetadata(action: action),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onOpen,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.onPrimary,
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                  icon: Icon(icon),
                  label: Text(action.actionLabel),
                ),
              ),
              if (action.kind != HomePrimaryActionKind.browseTests) ...[
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  tooltip: 'Browse all tests',
                  onPressed: onBrowse,
                  style: IconButton.styleFrom(
                    backgroundColor:
                        theme.colorScheme.onPrimary.withValues(alpha: 0.14),
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  icon: const Icon(Icons.grid_view_rounded),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionMetadata extends StatelessWidget {
  const _ActionMetadata({required this.action});

  final HomePrimaryAction action;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String)>[];
    final exam = action.exam;
    final result = action.result;
    if (exam != null) {
      items
        ..add((Icons.timer_outlined, '${exam.durationInSeconds ~/ 60} min'))
        ..add((Icons.help_outline_rounded, '${exam.totalQuestions} questions'))
        ..add((Icons.signal_cellular_alt_rounded, exam.difficulty));
    } else if (result != null) {
      items
        ..add((
          Icons.stars_outlined,
          '${result.percentageScore.round().clamp(0, 100)}% score',
        ))
        ..add((
          Icons.track_changes_outlined,
          '${result.accuracy.round().clamp(0, 100)}% accuracy',
        ))
        ..add((Icons.check_circle_outline, '${result.correctCount} correct'));
    } else {
      items.add((Icons.auto_awesome_outlined, 'Live catalogue'));
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: items
          .map(
            (item) => _MetaChip(icon: item.$1, label: item.$2),
          )
          .toList(),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.onPrimary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks({
    required this.onTests,
    required this.onResults,
    required this.onProfile,
  });

  final VoidCallback onTests;
  final VoidCallback onResults;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickLink(
            icon: Icons.explore_outlined,
            label: 'Tests',
            onTap: onTests,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickLink(
            icon: Icons.insights_outlined,
            label: 'Results',
            onTap: onResults,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickLink(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            onTap: onProfile,
          ),
        ),
      ],
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
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
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
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
              const SizedBox(height: AppSpacing.xxs),
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

class _PerformancePulse extends StatelessWidget {
  const _PerformancePulse({required this.analytics, required this.onOpen});

  final Analytics analytics;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focus = analytics.weakestTopics.isEmpty
        ? null
        : analytics.weakestTopics.first;
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _PulseMetric(
                      value: '${analytics.totalTestsAttempted}',
                      label: 'Tests',
                    ),
                  ),
                  Expanded(
                    child: _PulseMetric(
                      value: '${analytics.averageScore.round()}%',
                      label: 'Average',
                    ),
                  ),
                  Expanded(
                    child: _PulseMetric(
                      value: '${analytics.averageAccuracy.round()}%',
                      label: 'Accuracy',
                    ),
                  ),
                ],
              ),
              if (focus != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer
                        .withValues(alpha: 0.32),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.track_changes_rounded,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Focus next: $focus',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
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

class _PulseMetric extends StatelessWidget {
  const _PulseMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
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
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.36),
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
                width: 60,
                height: 60,
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
                      result.testName.trim().isEmpty
                          ? 'Completed test'
                          : result.testName,
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
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      _formatDate(result.calculatedAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamRail extends StatelessWidget {
  const _ExamRail({
    required this.tests,
    required this.label,
    required this.onOpen,
  });

  final List<Exam> tests;
  final String? label;
  final ValueChanged<Exam> onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tests.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) => _CompactExamCard(
          exam: tests[index],
          label: label,
          onTap: () => onOpen(tests[index]),
        ),
      ),
    );
  }
}

class _CompactExamCard extends StatelessWidget {
  const _CompactExamCard({
    required this.exam,
    required this.label,
    required this.onTap,
  });

  final Exam exam;
  final String? label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPaid = exam.status.trim().toLowerCase() == 'paid';
    final badge = label ?? (isPaid ? 'Paid' : 'Free');
    return SizedBox(
      width: 258,
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exam.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: label != null
                            ? theme.colorScheme.secondaryContainer
                            : isPaid
                                ? theme.colorScheme.tertiaryContainer
                                : theme.colorScheme.primaryContainer,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Text(
                        badge,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  exam.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const Spacer(),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _CompactMeta(
                      icon: Icons.timer_outlined,
                      label: '${exam.durationInSeconds ~/ 60} min',
                    ),
                    _CompactMeta(
                      icon: Icons.help_outline_rounded,
                      label: '${exam.totalQuestions}',
                    ),
                    _CompactMeta(
                      icon: Icons.signal_cellular_alt_rounded,
                      label: exam.difficulty,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Text(
                      label != null ? 'Continue test' : 'View details',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 19,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactMeta extends StatelessWidget {
  const _CompactMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _RecommendationEmpty extends StatelessWidget {
  const _RecommendationEmpty({
    required this.catalogueIsEmpty,
    required this.onBrowse,
  });

  final bool catalogueIsEmpty;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            catalogueIsEmpty
                ? Icons.event_busy_outlined
                : Icons.task_alt_rounded,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              catalogueIsEmpty
                  ? 'No tests are currently available. Pull down to check again.'
                  : 'The most relevant available test is already shown above.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (!catalogueIsEmpty)
            IconButton(
              tooltip: 'Browse tests',
              onPressed: onBrowse,
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.38),
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

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.height});

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
