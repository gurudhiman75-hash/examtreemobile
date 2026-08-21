import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/analytics_model.dart';
import '../../../core/models/exam_model.dart';
import '../../../core/models/result_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../companion/presentation/providers/daily_companion_providers.dart';
import '../../exam_preferences/presentation/providers/exam_preferences_providers.dart';
import '../../exams/presentation/providers/exam_providers.dart';
import '../../profile/presentation/providers/analytics_providers.dart';
import '../../promotions/domain/promotion_campaign.dart';
import '../../promotions/presentation/providers/promotion_providers.dart';
import '../../promotions/presentation/widgets/promotion_carousel.dart';
import '../../results/presentation/providers/result_providers.dart';
import 'home_exam_priority.dart';
import 'home_primary_action.dart';

final homeV8SelectedExamCodesProvider =
    Provider<AsyncValue<List<String>>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const AsyncValue.data(<String>[]);
  return ref.watch(selectedExamCodesProvider);
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.now});

  final DateTime Function()? now;

  Future<void> _refreshAll(WidgetRef ref) async {
    ref
      ..invalidate(userAnalyticsProvider)
      ..invalidate(inProgressExamsProvider)
      ..invalidate(availableExamsProvider)
      ..invalidate(userResultsProvider)
      ..invalidate(dailyCompanionSnapshotProvider)
      ..invalidate(homeV8SelectedExamCodesProvider)
      ..invalidate(promotionsForPlacementProvider(PromotionPlacement.home));

    Future<void> settle(Future<Object?> request) async {
      try {
        await request;
      } catch (_) {
        // Home modules recover independently and keep the rest of the page useful.
      }
    }

    await Future.wait([
      settle(ref.read(userAnalyticsProvider.future)),
      settle(ref.read(inProgressExamsProvider.future)),
      settle(ref.read(availableExamsProvider.future)),
      settle(ref.read(userResultsProvider.future)),
      settle(ref.read(dailyCompanionSnapshotProvider.future)),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(userAnalyticsProvider);
    final activeAsync = ref.watch(inProgressExamsProvider);
    final availableAsync = ref.watch(availableExamsProvider);
    final resultsAsync = ref.watch(userResultsProvider);
    final companionAsync = ref.watch(dailyCompanionSnapshotProvider);
    final selectedCodesAsync = ref.watch(homeV8SelectedExamCodesProvider);
    final campaignsAsync = ref.watch(
      promotionsForPlacementProvider(PromotionPlacement.home),
    );

    final user = ref.watch(authStateChangesProvider).value;
    final currentTime = now?.call() ?? DateTime.now();
    final activeTests = activeAsync.value ?? const <Exam>[];
    final availableTests = availableAsync.value ?? const <Exam>[];
    final results = resultsAsync.value ?? const <Result>[];
    final selectedCodes = selectedCodesAsync.value ?? const <String>[];
    final prioritizedAvailable = prioritizeHomeExams(
      exams: availableTests,
      selectedExamCodes: selectedCodes,
    );
    final companionSnapshot = companionAsync.value;
    final dueRevisionCount =
        companionSnapshot?.dueItems(currentTime).length ?? 0;
    final actionState = _resolveActionState(
      activeAsync: activeAsync,
      resultsAsync: resultsAsync,
      availableAsync: availableAsync,
      companionLoading: companionAsync.isLoading && companionSnapshot == null,
      dueRevisionCount: dueRevisionCount,
      now: currentTime,
      activeTests: activeTests,
      results: results,
      availableTests: prioritizedAvailable,
    );

    final actionExamId = actionState.action?.exam?.id;
    final activeIds = activeTests.map((test) => test.id).toSet();
    final recommendations = prioritizedAvailable
        .where(
          (test) => test.id != actionExamId && !activeIds.contains(test.id),
        )
        .take(6)
        .toList(growable: false);
    final remainingActive = actionState.action?.kind ==
            HomePrimaryActionKind.resumeTest
        ? activeTests.skip(1).take(4).toList(growable: false)
        : activeTests.take(4).toList(growable: false);
    final latestResult = results.isEmpty ? null : _latestResult(results);
    final campaigns = campaignsAsync.value ?? const <PromotionCampaign>[];

    return SafeArea(
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
                108,
              ),
              sliver: SliverList.list(
                children: [
                  _HomeHeader(
                    name: _displayName(user?.displayName, user?.email),
                    greeting: _greeting(currentTime),
                    todayLabel: _todayLabel(currentTime),
                    onMenu: MediaQuery.sizeOf(context).width < 840
                        ? () => Scaffold.maybeOf(context)?.openDrawer()
                        : null,
                    onSearch: () => context.go('/exams'),
                    onProfile: () => context.push('/profile'),
                  ),
                  if (campaigns.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    PromotionCarousel(campaigns: campaigns, compact: true),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _PrimaryHero(
                    state: actionState,
                    onOpen: (action) => _openAction(context, action),
                    onRetry: () {
                      ref
                        ..invalidate(inProgressExamsProvider)
                        ..invalidate(userResultsProvider)
                        ..invalidate(availableExamsProvider)
                        ..invalidate(dailyCompanionSnapshotProvider);
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _QuickActions(
                    onTests: () => context.go('/exams'),
                    onLearn: () => context.go('/learn'),
                    onRevision: () => context.push('/daily'),
                    onStore: () => context.push('/store?section=tests'),
                  ),
                  if (remainingActive.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _SectionHeading(
                      title: 'Continue learning',
                      actionLabel: 'All tests',
                      onAction: () => context.go('/exams'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ContinueRail(
                      exams: remainingActive,
                      onOpen: (exam) =>
                          context.push('/test-attempt', extra: exam.id),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  _SectionHeading(
                    title: 'Your progress',
                    actionLabel: 'Details',
                    onAction: () => context.push('/profile'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  analyticsAsync.when(
                    loading: () => const _LoadingSurface(height: 176),
                    error: (error, stack) => _CompactError(
                      title: 'Progress is temporarily unavailable',
                      onRetry: () => ref.invalidate(userAnalyticsProvider),
                    ),
                    data: (analytics) => _ProgressCard(
                      key: const Key('home-progress-overview'),
                      analytics: analytics,
                      onOpen: () => context.push('/profile'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionHeading(
                    title: 'Recommended for you',
                    actionLabel: 'View all',
                    onAction: () => context.go('/exams'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  availableAsync.when(
                    loading: () => const _LoadingSurface(height: 184),
                    error: (error, stack) => _CompactError(
                      title: 'Tests could not be loaded',
                      onRetry: () => ref.invalidate(availableExamsProvider),
                    ),
                    data: (tests) => recommendations.isEmpty
                        ? _CatalogueEmpty(
                            catalogueIsEmpty: tests.isEmpty,
                            onBrowse: () => context.go('/exams'),
                          )
                        : _RecommendationRail(
                            key: const Key('home-recommendations'),
                            exams: recommendations,
                            onOpen: (exam) => context.push(
                              '/exam-details',
                              extra: exam.id,
                            ),
                          ),
                  ),
                  if (latestResult != null &&
                      actionState.action?.kind !=
                          HomePrimaryActionKind.reviewResult) ...[
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionHeading(title: 'Latest result'),
                    const SizedBox(height: AppSpacing.sm),
                    _LatestResultCard(
                      result: latestResult,
                      onOpen: () => context.push(
                        '/review',
                        extra: latestResult.attemptId,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
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
  required bool companionLoading,
  required int dueRevisionCount,
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
        dueRevisionCount: dueRevisionCount,
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
  if (companionLoading) return const _ActionState(loading: true);

  final revisionAware = resolveHomePrimaryAction(
    activeTests: activeTests,
    results: results,
    availableTests: availableTests,
    dueRevisionCount: dueRevisionCount,
    now: now,
  );
  if (revisionAware.kind == HomePrimaryActionKind.reviseDue) {
    return _ActionState(action: revisionAware);
  }
  if (availableAsync.isLoading && availableTests.isEmpty) {
    return const _ActionState(loading: true);
  }
  if (activeAsync.hasError && resultsAsync.hasError && availableAsync.hasError) {
    return const _ActionState(error: true);
  }
  return _ActionState(action: revisionAware);
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.name,
    required this.greeting,
    required this.todayLabel,
    required this.onMenu,
    required this.onSearch,
    required this.onProfile,
  });

  final String name;
  final String greeting;
  final String todayLabel;
  final VoidCallback? onMenu;
  final VoidCallback onSearch;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      container: true,
      label: '$greeting, $name. $todayLabel.',
      child: Row(
        children: [
          if (onMenu != null) ...[
            _HeaderIconButton(
              tooltip: 'Open navigation',
              icon: Icons.menu_rounded,
              onTap: onMenu!,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.55,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  todayLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _HeaderIconButton(
            tooltip: 'Search tests',
            icon: Icons.search_rounded,
            onTap: onSearch,
          ),
          const SizedBox(width: AppSpacing.sm),
          Semantics(
            button: true,
            label: 'Open profile',
            child: InkWell(
              onTap: onProfile,
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.tertiary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    name.isEmpty ? 'S' : name[0].toUpperCase(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
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

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      icon: Icon(icon),
    );
  }
}

class _PrimaryHero extends StatelessWidget {
  const _PrimaryHero({
    required this.state,
    required this.onOpen,
    required this.onRetry,
  });

  final _ActionState state;
  final ValueChanged<HomePrimaryAction> onOpen;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.loading) return const _HeroSkeleton();
    if (state.error) {
      return _CompactError(
        title: 'Your next action could not be prepared',
        onRetry: onRetry,
      );
    }

    final action = state.action!;
    final theme = Theme.of(context);
    final metadata = _actionMetadata(action);
    return Semantics(
      container: true,
      label: '${action.eyebrow}. ${action.title}. ${action.description}',
      child: Container(
        key: const Key('home-primary-action'),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF6D4AE8), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.22),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            const Positioned(
              right: -42,
              top: -52,
              child: _HeroOrb(size: 150, opacity: 0.09),
            ),
            const Positioned(
              right: 42,
              bottom: -58,
              child: _HeroOrb(size: 118, opacity: 0.07),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          action.eyebrow.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _actionIcon(action.kind),
                        color: Colors.white.withValues(alpha: 0.82),
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    action.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                      letterSpacing: -0.65,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    action.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      height: 1.42,
                    ),
                  ),
                  if (metadata.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: metadata
                          .map((label) => _HeroMeta(label: label))
                          .toList(growable: false),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: () => onOpen(action),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(action.actionLabel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroOrb extends StatelessWidget {
  const _HeroOrb({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onTests,
    required this.onLearn,
    required this.onRevision,
    required this.onStore,
  });

  final VoidCallback onTests;
  final VoidCallback onLearn;
  final VoidCallback onRevision;
  final VoidCallback onStore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.assignment_rounded,
            label: 'Tests',
            containerColor: AppColors.skyContainer,
            foregroundColor: AppColors.onSkyContainer,
            onTap: onTests,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickAction(
            icon: Icons.menu_book_rounded,
            label: 'Learn',
            containerColor: AppColors.mintContainer,
            foregroundColor: AppColors.onMintContainer,
            onTap: onLearn,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickAction(
            icon: Icons.replay_circle_filled_rounded,
            label: 'Revision',
            containerColor: AppColors.amberContainer,
            foregroundColor: AppColors.onAmberContainer,
            onTap: onRevision,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickAction(
            icon: Icons.shopping_bag_rounded,
            label: 'Store',
            containerColor: AppColors.tertiaryContainer,
            foregroundColor: AppColors.onTertiaryContainer,
            onTap: onStore,
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
    required this.containerColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color containerColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _softShadow(),
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: foregroundColor, size: 22),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
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
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.35,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({super.key, required this.analytics, required this.onOpen});

  final Analytics analytics;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accuracy = analytics.averageAccuracy.clamp(0, 100).toDouble();
    return _SurfaceCard(
      onTap: onOpen,
      child: Column(
        children: [
          Row(
            children: [
              _ProgressRing(value: accuracy),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accuracy',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${accuracy.round()}%',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: accuracy / 100,
                        minHeight: 7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  value: '${analytics.totalTestsAttempted}',
                  label: 'Tests',
                ),
              ),
              _MetricDivider(),
              Expanded(
                child: _Metric(
                  value: '${analytics.averageScore.round()}%',
                  label: 'Avg score',
                ),
              ),
              _MetricDivider(),
              Expanded(
                child: _Metric(
                  value: '${analytics.totalQuestionsAttempted}',
                  label: 'Questions',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 78,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value / 100,
            strokeWidth: 8,
            strokeCap: StrokeCap.round,
          ),
          Center(
            child: Icon(
              Icons.track_changes_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

class _ContinueRail extends StatelessWidget {
  const _ContinueRail({required this.exams, required this.onOpen});

  final List<Exam> exams;
  final ValueChanged<Exam> onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: exams.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final exam = exams[index];
          return SizedBox(
            width: 252,
            child: _SurfaceCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              onTap: () => onOpen(exam),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.mintContainer,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.onMintContainer,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Resume saved attempt',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecommendationRail extends StatelessWidget {
  const _RecommendationRail({
    super.key,
    required this.exams,
    required this.onOpen,
  });

  final List<Exam> exams;
  final ValueChanged<Exam> onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: exams.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final exam = exams[index];
          return SizedBox(
            width: 280,
            child: _ExamCard(exam: exam, onTap: () => onOpen(exam)),
          );
        },
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam, required this.onTap});

  final Exam exam;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = isHomeSelectedExam(exam);
    final paid = exam.status.trim().toLowerCase() == 'paid';
    return _SurfaceCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryContainer
                      : AppColors.skyContainer,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: selected
                      ? AppColors.onPrimaryContainer
                      : AppColors.onSkyContainer,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: paid
                      ? AppColors.tertiaryContainer
                      : AppColors.mintContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  paid ? 'PREMIUM' : 'AVAILABLE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: paid
                        ? AppColors.onTertiaryContainer
                        : AppColors.onMintContainer,
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                    letterSpacing: 0.55,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            exam.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              _TinyMeta(
                icon: Icons.quiz_outlined,
                text: '${exam.totalQuestions} Qs',
              ),
              const SizedBox(width: AppSpacing.md),
              _TinyMeta(
                icon: Icons.schedule_rounded,
                text: '${(exam.durationInSeconds / 60).ceil()} min',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TinyMeta extends StatelessWidget {
  const _TinyMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
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
    return _SurfaceCard(
      onTap: onOpen,
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                '${result.percentageScore.round()}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.onPrimaryContainer,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.testName.trim().isEmpty
                      ? 'Latest test result'
                      : result.testName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${result.accuracy.round()}% accuracy • ${result.correctCount} correct',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    final content = Padding(padding: padding, child: child);
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: radius,
          boxShadow: _softShadow(),
        ),
        child: onTap == null
            ? content
            : InkWell(onTap: onTap, borderRadius: radius, child: content),
      ),
    );
  }
}

class _LoadingSurface extends StatelessWidget {
  const _LoadingSurface({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        boxShadow: _softShadow(),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _CompactError extends StatelessWidget {
  const _CompactError({required this.title, required this.onRetry});

  final String title;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.error),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(title)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _CatalogueEmpty extends StatelessWidget {
  const _CatalogueEmpty({
    required this.catalogueIsEmpty,
    required this.onBrowse,
  });

  final bool catalogueIsEmpty;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.skyContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.explore_rounded,
              color: AppColors.onSkyContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              catalogueIsEmpty
                  ? 'No tests are published right now.'
                  : 'You are caught up on the current recommendations.',
            ),
          ),
          TextButton(onPressed: onBrowse, child: const Text('Browse')),
        ],
      ),
    );
  }
}

List<BoxShadow> _softShadow() => [
      BoxShadow(
        color: AppColors.shadow.withValues(alpha: 0.055),
        blurRadius: 22,
        offset: const Offset(0, 7),
      ),
    ];

List<String> _actionMetadata(HomePrimaryAction action) {
  final exam = action.exam;
  if (exam != null) {
    return [
      '${exam.totalQuestions} questions',
      '${(exam.durationInSeconds / 60).ceil()} min',
    ];
  }
  final result = action.result;
  if (result != null) {
    return [
      '${result.percentageScore.round()}% score',
      '${result.accuracy.round()}% accuracy',
    ];
  }
  if (action.dueRevisionCount > 0) {
    return ['${action.dueRevisionCount} due'];
  }
  return const [];
}

IconData _actionIcon(HomePrimaryActionKind kind) => switch (kind) {
      HomePrimaryActionKind.resumeTest => Icons.play_arrow_rounded,
      HomePrimaryActionKind.reviewResult => Icons.rate_review_rounded,
      HomePrimaryActionKind.reviseDue => Icons.replay_circle_filled_rounded,
      HomePrimaryActionKind.startTest => Icons.rocket_launch_rounded,
      HomePrimaryActionKind.browseTests => Icons.explore_rounded,
    };

void _openAction(BuildContext context, HomePrimaryAction action) {
  switch (action.kind) {
    case HomePrimaryActionKind.resumeTest:
      context.push('/test-attempt', extra: action.exam!.id);
    case HomePrimaryActionKind.reviewResult:
      context.push('/review', extra: action.result!.attemptId);
    case HomePrimaryActionKind.reviseDue:
      context.push('/daily');
    case HomePrimaryActionKind.startTest:
      context.push('/exam-details', extra: action.exam!.id);
    case HomePrimaryActionKind.browseTests:
      context.go('/exams');
  }
}

Result _latestResult(List<Result> results) {
  final sorted = [...results]
    ..sort((left, right) => right.calculatedAt.compareTo(left.calculatedAt));
  return sorted.first;
}

String _displayName(String? displayName, String? email) {
  final name = displayName?.trim();
  if (name != null && name.isNotEmpty) return name.split(RegExp(r'\s+')).first;
  final localPart = email?.split('@').first.trim();
  if (localPart != null && localPart.isNotEmpty) return localPart;
  return 'Student';
}

String _greeting(DateTime now) {
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 17) return 'Good afternoon';
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
