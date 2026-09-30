import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/analytics_model.dart';
import '../../../core/models/exam_model.dart';
import '../../../core/models/result_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
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
        // Each Home module owns its own recovery state.
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

    final active = activeAsync.value ?? const <Exam>[];
    final available = availableAsync.value ?? const <Exam>[];
    final results = resultsAsync.value ?? const <Result>[];
    final selectedCodes = selectedCodesAsync.value ?? const <String>[];
    final prioritizedAvailable = prioritizeHomeExams(
      exams: available,
      selectedExamCodes: selectedCodes,
    );
    final snapshot = companionAsync.value;
    final dueCount = snapshot?.dueItems(currentTime).length ?? 0;
    final actionState = _resolveActionState(
      activeAsync: activeAsync,
      resultsAsync: resultsAsync,
      availableAsync: availableAsync,
      companionLoading: companionAsync.isLoading && snapshot == null,
      dueRevisionCount: dueCount,
      now: currentTime,
      activeTests: active,
      results: results,
      availableTests: prioritizedAvailable,
    );
    final hiddenIds = <String>{
      ...active.map((item) => item.id),
      if (actionState.action?.exam != null) actionState.action!.exam!.id,
    };
    final recommendations = prioritizedAvailable
        .where((exam) => !hiddenIds.contains(exam.id))
        .take(6)
        .toList(growable: false);
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
                112,
              ),
              sliver: SliverList.list(
                children: [
                  _HomeHeader(
                    name: _displayName(user?.displayName, user?.email),
                    greeting: _greeting(currentTime),
                    dateLabel: _dateLabel(currentTime),
                    onMenu: MediaQuery.sizeOf(context).width < 840
                        ? () => Scaffold.maybeOf(context)?.openDrawer()
                        : null,
                    onSearch: () => context.go('/exams'),
                    onProfile: () => context.push('/profile'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (campaigns.isNotEmpty)
                    PromotionCarousel(campaigns: campaigns, compact: true)
                  else
                    const _HomePromoFallback(),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionTitle(
                    title: 'Exam Categories',
                    action: 'See all',
                    onAction: () => context.go('/exams'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ExamCategoriesGrid(onOpen: () => context.go('/exams')),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionTitle(
                    title: 'Featured Test Series',
                    action: 'See all',
                    onAction: () => context.go('/exams'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  availableAsync.when(
                    loading: () => const _LoadingCard(height: 194),
                    error: (error, stack) => _ErrorCard(
                      title: 'Test series could not be loaded',
                      onRetry: () => ref.invalidate(availableExamsProvider),
                    ),
                    data: (tests) {
                      final featured = recommendations.isNotEmpty
                          ? recommendations.take(4).toList(growable: false)
                          : prioritizedAvailable.take(4).toList(growable: false);
                      return featured.isEmpty
                          ? _EmptyRecommendations(
                              catalogueEmpty: tests.isEmpty,
                              onBrowse: () => context.go('/exams'),
                            )
                          : _FeaturedSeriesRail(
                              exams: featured,
                              onOpen: (exam) => context.push(
                                '/exam-details',
                                extra: exam.id,
                              ),
                            );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionTitle(
                    title: 'Continue Learning',
                    action: 'See all',
                    onAction: () => context.go('/learn'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ContinueLearningCard(
                    key: const Key('home-primary-action'),
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
                  const SizedBox(height: AppSpacing.xl),
                  _SectionTitle(
                    title: "Today's Goal",
                    action: 'Details',
                    onAction: () => context.push('/profile'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  analyticsAsync.when(
                    loading: () => const _LoadingCard(height: 112),
                    error: (error, stack) => _ErrorCard(
                      title: 'Progress is temporarily unavailable',
                      onRetry: () => ref.invalidate(userAnalyticsProvider),
                    ),
                    data: (analytics) => _TodayGoalCard(
                      analytics: analytics,
                      onTap: () => context.push('/profile'),
                    ),
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


class _HomePromoFallback extends StatelessWidget {
  const _HomePromoFallback();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF062C59), Color(0xFF0B4E8A), Color(0xFF0A6AA6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF062C59).withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -36,
            bottom: -44,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFF3C768)),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'PUNJAB GOVT. EXAMS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFFFD97A),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Your Dream Government Job Starts Here',
                  maxLines: 3,
                  style: AppTypography.premiumHeading(
                    theme.textTheme.headlineSmall,
                  ).copyWith(
                    color: Colors.white,
                    height: 1.05,
                    letterSpacing: -0.35,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () => context.go('/exams'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD36B),
                        foregroundColor: const Color(0xFF082A52),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                      ),
                      child: const Text('Start Preparing'),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.auto_graph_rounded,
                      color: Colors.white.withValues(alpha: 0.72),
                      size: 34,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamCategoriesGrid extends StatelessWidget {
  const _ExamCategoriesGrid({required this.onOpen});

  final VoidCallback onOpen;

  static const _items = [
    ('Punjab Govt.', Icons.location_on_rounded, Color(0xFFFFEFEF), Color(0xFFF04452)),
    ('SSC', Icons.workspace_premium_rounded, Color(0xFFEAF8F2), Color(0xFF11966F)),
    ('Banking', Icons.account_balance_rounded, Color(0xFFECF4FF), Color(0xFF1672E8)),
    ('Railway', Icons.train_rounded, Color(0xFFF3EEFF), Color(0xFF7248E8)),
    ('Teaching', Icons.school_rounded, Color(0xFFFFF5E8), Color(0xFFF28A19)),
    ('Defence', Icons.shield_rounded, Color(0xFFEAF8F2), Color(0xFF159D73)),
    ('State PCS', Icons.apartment_rounded, Color(0xFFFFEEEE), Color(0xFFF04452)),
    ('Other Exams', Icons.grid_view_rounded, Color(0xFFF1F4F8), Color(0xFF718096)),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = AppSpacing.sm;
        final scaledLabel = MediaQuery.textScalerOf(context).scale(12);
        final compactColumns = constraints.maxWidth < 340 || scaledLabel > 15;
        final columns = compactColumns ? 2 : 4;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: _items
              .map(
                (item) => SizedBox(
                  width: width,
                  child: _ExamCategoryTile(
                    label: item.$1,
                    icon: item.$2,
                    background: item.$3,
                    foreground: item.$4,
                    onTap: onOpen,
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _ExamCategoryTile extends StatelessWidget {
  const _ExamCategoryTile({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: foreground, size: 28),
              const SizedBox(height: 9),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF10264A),
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

class _FeaturedSeriesRail extends StatelessWidget {
  const _FeaturedSeriesRail({required this.exams, required this.onOpen});

  final List<Exam> exams;
  final ValueChanged<Exam> onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: exams.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) => SizedBox(
          width: 300,
          child: _FeaturedSeriesCard(
            exam: exams[index],
            alternate: index.isOdd,
            onTap: () => onOpen(exams[index]),
          ),
        ),
      ),
    );
  }
}

class _FeaturedSeriesCard extends StatelessWidget {
  const _FeaturedSeriesCard({
    required this.exam,
    required this.alternate,
    required this.onTap,
  });

  final Exam exam;
  final bool alternate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final durationMinutes = (exam.durationInSeconds / 60).round();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: alternate
                  ? const [Color(0xFFFFF5D9), Color(0xFFFFFBF0)]
                  : const [Color(0xFF062D5C), Color(0xFF0A4A83)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F2745).withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TEST SERIES',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: alternate
                        ? const Color(0xFF7C5B18)
                        : Colors.white.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  exam.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.premiumHeading(
                    theme.textTheme.titleLarge,
                  ).copyWith(
                    color: alternate ? const Color(0xFF152746) : Colors.white,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    _SeriesMetric(
                      icon: Icons.quiz_outlined,
                      value: '${exam.totalQuestions}',
                      label: 'Questions',
                      light: alternate,
                    ),
                    const SizedBox(width: 16),
                    _SeriesMetric(
                      icon: Icons.schedule_rounded,
                      value: '$durationMinutes min',
                      label: 'Duration',
                      light: alternate,
                    ),
                    const Spacer(),
                    CircleAvatar(
                      radius: 21,
                      backgroundColor: alternate
                          ? const Color(0xFF10264A)
                          : Colors.white.withValues(alpha: 0.13),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
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

class _SeriesMetric extends StatelessWidget {
  const _SeriesMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.light,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final color = light ? const Color(0xFF233A5C) : Colors.white;
    return Row(
      children: [
        Icon(icon, size: 18, color: color.withValues(alpha: 0.86)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color.withValues(alpha: 0.68),
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({
    super.key,
    required this.state,
    required this.onOpen,
    required this.onRetry,
  });

  final _ActionState state;
  final ValueChanged<HomePrimaryAction> onOpen;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.loading) return const _LoadingCard(height: 104);
    if (state.error || state.action == null) {
      return _ErrorCard(
        title: 'Continue learning is temporarily unavailable',
        onRetry: onRetry,
      );
    }

    final action = state.action!;
    final theme = Theme.of(context);
    return _SurfaceCard(
      onTap: () => onOpen(action),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFE9F2FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFF1672E8),
              size: 30,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF10264A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  action.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          CircleAvatar(
            radius: 23,
            backgroundColor: const Color(0xFF062D5C),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _TodayGoalCard extends StatelessWidget {
  const _TodayGoalCard({required this.analytics, required this.onTap});

  final Analytics analytics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accuracy = analytics.averageAccuracy.clamp(0, 100).round();
    return _SurfaceCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F3FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.track_changes_rounded,
              color: Color(0xFF1672E8),
              size: 30,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep Going!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF10264A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${analytics.totalTestsAttempted} tests attempted',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _GoalMetric(value: '${analytics.totalTestsAttempted}', label: 'Tests'),
          const SizedBox(width: AppSpacing.lg),
          _GoalMetric(value: '$accuracy%', label: 'Accuracy'),
        ],
      ),
    );
  }
}

class _GoalMetric extends StatelessWidget {
  const _GoalMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: const Color(0xFF10264A),
            fontWeight: FontWeight.w900,
          ),
        ),
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
    required this.dateLabel,
    required this.onMenu,
    required this.onSearch,
    required this.onProfile,
  });

  final String name;
  final String greeting;
  final String dateLabel;
  final VoidCallback? onMenu;
  final VoidCallback onSearch;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final title = 'Examtree';
    return Semantics(
      container: true,
      label: '$greeting, $name. $dateLabel.',
      child: Row(
        children: [
          if (onMenu != null) ...[
            _HeaderButton(
              icon: Icons.menu_rounded,
              tooltip: 'Open navigation',
              onTap: onMenu!,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.55,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '$greeting, $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _HeaderButton(
            icon: Icons.search_rounded,
            tooltip: 'Search tests',
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

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
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

class _NextActionHero extends StatelessWidget {
  const _NextActionHero({
    super.key,
    required this.state,
    required this.onOpen,
    required this.onRetry,
  });

  final _ActionState state;
  final ValueChanged<HomePrimaryAction> onOpen;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.loading) return const _HeroLoading();
    if (state.error) {
      return _ErrorCard(
        title: 'Your next action could not be prepared',
        onRetry: onRetry,
      );
    }

    final action = state.action!;
    final theme = Theme.of(context);
    final metadata = _actionMetadata(action);
    return Container(
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
          Positioned(
            right: -48,
            top: -56,
            child: _DecorativeOrb(size: 154, opacity: 0.09),
          ),
          Positioned(
            right: 34,
            bottom: -62,
            child: _DecorativeOrb(size: 122, opacity: 0.07),
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
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        action.eyebrow.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.75,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _actionIcon(action.kind),
                      color: Colors.white.withValues(alpha: 0.84),
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
                    height: 1.4,
                  ),
                ),
                if (metadata.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: metadata
                        .map((item) => _HeroMeta(text: item))
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
    );
  }
}

class _DecorativeOrb extends StatelessWidget {
  const _DecorativeOrb({required this.size, required this.opacity});

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
  const _HeroMeta({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
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
            background: AppColors.skyContainer,
            foreground: AppColors.onSkyContainer,
            onTap: onTests,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickAction(
            icon: Icons.menu_book_rounded,
            label: 'Learn',
            background: AppColors.mintContainer,
            foreground: AppColors.onMintContainer,
            onTap: onLearn,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickAction(
            icon: Icons.replay_circle_filled_rounded,
            label: 'Revision',
            background: AppColors.amberContainer,
            foreground: AppColors.onAmberContainer,
            onTap: onRevision,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickAction(
            icon: Icons.shopping_bag_rounded,
            label: 'Store',
            background: AppColors.tertiaryContainer,
            foreground: AppColors.onTertiaryContainer,
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
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
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
                color: background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: foreground, size: 22),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
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
    required this.action,
    required this.onAction,
  });

  final String title;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.premiumHeading(
              Theme.of(context).textTheme.titleLarge,
            ).copyWith(
              color: const Color(0xFF10264A),
            ),
          ),
        ),
        TextButton(onPressed: onAction, child: Text(action)),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    super.key,
    required this.analytics,
    required this.onTap,
  });

  final Analytics analytics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accuracy = analytics.averageAccuracy.clamp(0, 100).toDouble();
    return _SurfaceCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 74,
                height: 74,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: accuracy / 100,
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Text(
                        '${accuracy.round()}%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      accuracy >= 75
                          ? 'Strong momentum'
                          : accuracy >= 55
                              ? 'Keep building consistency'
                              : 'Focus on accuracy first',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
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
              _VerticalMetricDivider(),
              Expanded(
                child: _Metric(
                  value: '${analytics.averageScore.round()}%',
                  label: 'Avg score',
                ),
              ),
              _VerticalMetricDivider(),
              Expanded(
                child: _Metric(
                  value: '${analytics.averageTimePerQuestion}s',
                  label: 'Per question',
                ),
              ),
            ],
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

class _VerticalMetricDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

class _ExamRail extends StatelessWidget {
  const _ExamRail({super.key, required this.exams, required this.onOpen});

  final List<Exam> exams;
  final ValueChanged<Exam> onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 188,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: exams.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final exam = exams[index];
          return SizedBox(
            width: 278,
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
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
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

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
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

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.title, required this.onRetry});

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

class _EmptyRecommendations extends StatelessWidget {
  const _EmptyRecommendations({
    required this.catalogueEmpty,
    required this.onBrowse,
  });

  final bool catalogueEmpty;
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
              catalogueEmpty
                  ? 'No tests are published right now.'
                  : 'You are caught up on current recommendations.',
            ),
          ),
          TextButton(onPressed: onBrowse, child: const Text('Browse')),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.height});

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

class _HeroLoading extends StatelessWidget {
  const _HeroLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 236,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Center(child: CircularProgressIndicator()),
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
      return;
    case HomePrimaryActionKind.reviewResult:
      context.push('/review', extra: action.result!.attemptId);
      return;
    case HomePrimaryActionKind.reviseDue:
      context.push('/daily');
      return;
    case HomePrimaryActionKind.startTest:
      context.push('/exam-details', extra: action.exam!.id);
      return;
    case HomePrimaryActionKind.browseTests:
      context.go('/exams');
      return;
  }
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

String _dateLabel(DateTime now) {
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
