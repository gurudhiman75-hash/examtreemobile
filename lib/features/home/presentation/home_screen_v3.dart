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
        // Every home module owns its own recoverable error state.
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                    const SizedBox(height: AppSpacing.md),
                    analyticsAsync.when(
                      loading: () => const _SkeletonCard(height: 146),
                      error: (error, stackTrace) => _ErrorCard(
                        title: 'Your progress could not be loaded',
                        onRetry: () => ref.invalidate(userAnalyticsProvider),
                      ),
                      data: (analytics) => _ProgressOverview(
                        analytics: analytics,
                        onOpen: () => context.go('/profile'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ContextActions(
                      onTests: () => context.go('/exams'),
                      onResults: () => context.go('/results'),
                    ),
                    if (otherActive.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xl),
                      _SectionHeader(
                        title: 'Continue learning',
                        subtitle: otherActive.length == 1
                            ? 'One more saved attempt is ready'
                            : '${otherActive.length} more saved attempts are ready',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _ExamRail(
                        tests: otherActive,
                        badge: 'Resume',
                        semanticLabel: 'Other active tests',
                        onOpen: (test) => context.push(
                          '/test-attempt',
                          extra: test.id,
                        ),
                      ),
                    ],
                    if (latestResult != null &&
                        actionState.action?.kind !=
                            HomePrimaryActionKind.reviewResult) ...[
                      const SizedBox(height: AppSpacing.xl),
                      const _SectionHeader(
                        title: 'Recent result',
                        subtitle: 'Review the questions behind your latest score',
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
                    _SectionHeader(
                      title: 'Discover your next test',
                      subtitle: 'Available mocks and focused practice papers',
                      actionLabel: 'View all',
                      onAction: () => context.go('/exams'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    availableAsync.when(
                      loading: () => const _SkeletonCard(height: 210),
                      error: (error, stackTrace) => _ErrorCard(
                        title: 'Available tests could not be loaded',
                        onRetry: () => ref.invalidate(availableExamsProvider),
                      ),
                      data: (tests) => recommendations.isEmpty
                          ? _RecommendationEmpty(
                              catalogueIsEmpty: tests.isEmpty,
                              onBrowse: () => context.go('/exams'),
                            )
                          : _ExamRail(
                              key: const Key('home-recommendations'),
                              tests: recommendations,
                              badge: null,
                              semanticLabel: 'Recommended tests',
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
      now: now,
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
    final radius = BorderRadius.circular(AppSpacing.radiusXl);

    return Semantics(
      container: true,
      label: '$greeting, $name. $todayLabel.',
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.primaryContainer.withValues(alpha: 0.88),
                Color.lerp(
                  scheme.primaryContainer,
                  scheme.surface,
                  0.72,
                )!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: radius,
            border: Border.all(
              color: scheme.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -22,
                top: -34,
                child: Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primary.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
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
                                'ExamTree',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              Text(
                                'Preparation dashboard',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
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
                        const SizedBox(width: AppSpacing.xs),
                        InkWell(
                          onTap: onProfile,
                          customBorder: const CircleBorder(),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: scheme.primary,
                            child: Text(
                              name.isEmpty ? 'S' : name[0].toUpperCase(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: scheme.onPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '$greeting, $name',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w900,
                        height: 1.12,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Pick up where you left off or start a focused test.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.72),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 15,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              todayLabel,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
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
      return const _SkeletonCard(height: 226);
    }
    if (state.error) {
      return _ErrorCard(
        title: 'Your next learning action could not be prepared',
        onRetry: onRetry,
      );
    }
    final action = state.action!;
    return _PrimaryActionCard(
      key: const Key('home-primary-action'),
      action: action,
      onOpen: () => onOpen(action),
      onBrowse: onBrowse,
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  const _PrimaryActionCard({
    super.key,
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
    final scheme = theme.colorScheme;
    final icon = switch (action.kind) {
      HomePrimaryActionKind.resumeTest => Icons.play_arrow_rounded,
      HomePrimaryActionKind.reviewResult => Icons.fact_check_rounded,
      HomePrimaryActionKind.startTest => Icons.rocket_launch_rounded,
      HomePrimaryActionKind.browseTests => Icons.explore_rounded,
    };
    final metadata = <_ActionMetadata>[];
    final exam = action.exam;
    final result = action.result;

    if (exam != null) {
      metadata
        ..add(
          _ActionMetadata(
            icon: Icons.timer_outlined,
            label: '${exam.durationInSeconds ~/ 60} min',
          ),
        )
        ..add(
          _ActionMetadata(
            icon: Icons.help_outline_rounded,
            label: '${exam.totalQuestions} questions',
          ),
        )
        ..add(
          _ActionMetadata(
            icon: Icons.signal_cellular_alt_rounded,
            label: exam.difficulty,
          ),
        );
    } else if (result != null) {
      metadata
        ..add(
          _ActionMetadata(
            icon: Icons.stars_rounded,
            label: '${result.percentageScore.round().clamp(0, 100)}% score',
          ),
        )
        ..add(
          _ActionMetadata(
            icon: Icons.track_changes_rounded,
            label: '${result.accuracy.round().clamp(0, 100)}% accuracy',
          ),
        )
        ..add(
          _ActionMetadata(
            icon: Icons.check_circle_outline_rounded,
            label: '${result.correctCount} correct',
          ),
        );
    } else {
      metadata.add(
        const _ActionMetadata(
          icon: Icons.auto_awesome_rounded,
          label: 'Live test catalogue',
        ),
      );
    }

    final radius = BorderRadius.circular(AppSpacing.radiusXl);
    final onPrimary = scheme.onPrimary;

    return Semantics(
      container: true,
      label: '${action.eyebrow}. ${action.title}. ${action.description}',
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.primary,
                Color.lerp(scheme.primary, scheme.secondary, 0.42)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -35,
                bottom: -45,
                child: Container(
                  width: 155,
                  height: 155,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: onPrimary.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned(
                right: 62,
                top: -45,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: onPrimary.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: onPrimary.withValues(alpha: 0.14),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusLg),
                          ),
                          alignment: Alignment.center,
                          child: Icon(icon, color: onPrimary, size: 28),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                action.eyebrow.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: onPrimary.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                action.title,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: onPrimary,
                                  fontWeight: FontWeight.w900,
                                  height: 1.12,
                                  letterSpacing: -0.45,
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
                        color: onPrimary.withValues(alpha: 0.88),
                        height: 1.42,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: metadata
                          .map((item) => _ActionMetadataChip(item: item))
                          .toList(growable: false),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final textScale =
                            MediaQuery.textScalerOf(context).scale(1);
                        final stack =
                            constraints.maxWidth < 290 || textScale > 1.5;
                        final primary = FilledButton.icon(
                          onPressed: onOpen,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 50),
                            backgroundColor: onPrimary,
                            foregroundColor: scheme.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.md,
                            ),
                          ),
                          icon: Icon(icon),
                          label: Text(action.actionLabel),
                        );
                        final browse = action.kind ==
                                HomePrimaryActionKind.browseTests
                            ? null
                            : OutlinedButton.icon(
                                onPressed: onBrowse,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 50),
                                  foregroundColor: onPrimary,
                                  side: BorderSide(
                                    color: onPrimary.withValues(alpha: 0.45),
                                  ),
                                ),
                                icon: const Icon(Icons.grid_view_rounded),
                                label: const Text('All tests'),
                              );

                        if (stack) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              primary,
                              if (browse != null) ...[
                                const SizedBox(height: AppSpacing.sm),
                                browse,
                              ],
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: primary),
                            if (browse != null) ...[
                              const SizedBox(width: AppSpacing.sm),
                              browse,
                            ],
                          ],
                        );
                      },
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

class _ActionMetadata {
  const _ActionMetadata({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _ActionMetadataChip extends StatelessWidget {
  const _ActionMetadataChip({required this.item});

  final _ActionMetadata item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 15, color: foreground),
          const SizedBox(width: AppSpacing.xs),
          Text(
            item.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressOverview extends StatelessWidget {
  const _ProgressOverview({required this.analytics, required this.onOpen});

  final Analytics analytics;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final focus = analytics.weakestTopics.isEmpty
        ? null
        : analytics.weakestTopics.first;
    final radius = BorderRadius.circular(AppSpacing.radiusXl);

    return Semantics(
      container: true,
      label:
          'Your progress. ${analytics.totalTestsAttempted} tests. ${analytics.averageScore.round()} percent average score. ${analytics.averageAccuracy.round()} percent accuracy.',
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: radius,
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: InkWell(
            key: const Key('home-progress-overview'),
            onTap: onOpen,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.insights_rounded,
                          color: scheme.onSecondaryContainer,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your progress',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'A quick view of your completed work',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          value: '${analytics.totalTestsAttempted}',
                          label: 'Tests',
                        ),
                      ),
                      _MetricDivider(color: scheme.outlineVariant),
                      Expanded(
                        child: _MetricTile(
                          value: '${analytics.averageScore.round()}%',
                          label: 'Average',
                        ),
                      ),
                      _MetricDivider(color: scheme.outlineVariant),
                      Expanded(
                        child: _MetricTile(
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
                        color: scheme.tertiaryContainer.withValues(alpha: 0.55),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.track_changes_rounded,
                            color: scheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Needs attention: $focus',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onTertiaryContainer,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      color: color,
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
        final stack = constraints.maxWidth < 340 || textScale > 1.4;
        final tests = _ContextActionCard(
          key: const Key('home-context-tests'),
          icon: Icons.explore_rounded,
          title: 'Browse tests',
          subtitle: 'Mocks, sectionals and practice papers',
          onTap: onTests,
        );
        final results = _ContextActionCard(
          key: const Key('home-context-results'),
          icon: Icons.fact_check_rounded,
          title: 'Results & review',
          subtitle: 'Scores, answers and explanations',
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

class _ContextActionCard extends StatelessWidget {
  const _ContextActionCard({
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
    final radius = BorderRadius.circular(AppSpacing.radiusLg);
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: radius,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: scheme.onPrimaryContainer),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 19,
                  color: scheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
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
    final action = actionLabel != null && onAction != null
        ? TextButton(onPressed: onAction, child: Text(actionLabel!))
        : null;

    return Semantics(
      header: true,
      container: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          final stack = constraints.maxWidth < 300 || textScale > 1.5;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.25,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          );

          if (action == null) return copy;
          if (stack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: AppSpacing.xs),
                action,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: copy),
              const SizedBox(width: AppSpacing.sm),
              action,
            ],
          );
        },
      ),
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
    final scheme = theme.colorScheme;
    final score = result.percentageScore.round().clamp(0, 100);
    final radius = BorderRadius.circular(AppSpacing.radiusXl);
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: scheme.secondaryContainer.withValues(alpha: 0.42),
          borderRadius: radius,
          border: Border.all(color: scheme.secondaryContainer),
        ),
        child: InkWell(
          onTap: onOpen,
          borderRadius: radius,
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
                        backgroundColor: scheme.surface.withValues(alpha: 0.72),
                      ),
                      Center(
                        child: Text(
                          '$score%',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
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
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${result.correctCount} correct · ${result.incorrectCount} incorrect',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        _formatDate(result.calculatedAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: scheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExamRail extends StatelessWidget {
  const _ExamRail({
    super.key,
    required this.tests,
    required this.badge,
    required this.semanticLabel,
    required this.onOpen,
  });

  final List<Exam> tests;
  final String? badge;
  final String semanticLabel;
  final ValueChanged<Exam> onOpen;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final height = textScale > 1.4 ? 248.0 : 210.0;
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = (width - (AppSpacing.md * 2)).clamp(250.0, 300.0);

    return Semantics(
      container: true,
      label: semanticLabel,
      child: SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: tests.length,
          separatorBuilder: (context, index) =>
              const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final test = tests[index];
            return SizedBox(
              width: cardWidth,
              child: Semantics(
                label: '${index + 1} of ${tests.length}. ${test.title}.',
                child: _CompactExamCard(
                  exam: test,
                  badge: badge,
                  onTap: () => onOpen(test),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CompactExamCard extends StatelessWidget {
  const _CompactExamCard({
    required this.exam,
    required this.badge,
    required this.onTap,
  });

  final Exam exam;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isPaid = exam.status.trim().toLowerCase() == 'paid';
    final label = badge ?? (isPaid ? 'Paid' : 'Free');
    final radius = BorderRadius.circular(AppSpacing.radiusXl);

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: radius,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
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
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: badge != null
                            ? scheme.secondaryContainer
                            : isPaid
                                ? scheme.tertiaryContainer
                                : scheme.primaryContainer,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Text(
                        label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
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
                    fontWeight: FontWeight.w900,
                    height: 1.23,
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
                    Expanded(
                      child: Text(
                        badge != null ? 'Continue test' : 'View details',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 19,
                      color: scheme.primary,
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
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            alignment: Alignment.center,
            child: Icon(
              catalogueIsEmpty
                  ? Icons.event_busy_outlined
                  : Icons.task_alt_rounded,
              color: scheme.onPrimaryContainer,
            ),
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
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: scheme.error.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.sync_problem_rounded, color: scheme.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Loading',
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: scheme.outlineVariant),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 150;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  height: 18,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                FractionallySizedBox(
                  widthFactor: 0.68,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                ),
                if (!compact) ...[
                  const Spacer(),
                  Container(
                    width: 126,
                    height: 42,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
