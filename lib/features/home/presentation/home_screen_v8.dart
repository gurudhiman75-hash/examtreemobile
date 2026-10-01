// ignore_for_file: unused_element, unused_element_parameter, unnecessary_underscores

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
                    photoUrl: user?.photoURL,
                    onSearch: () => context.go('/exams'),
                    onNotifications: () => context.push('/daily'),
                    onProfile: () => context.push('/profile'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (campaigns.isNotEmpty)
                    PromotionCarousel(campaigns: campaigns, compact: true)
                  else
                    const Column(
                      children: [
                        _HomePromoFallback(),
                        SizedBox(height: 10),
                        _HeroPageDots(),
                      ],
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionTitle(
                    title: 'Exam Categories',
                    action: 'See All',
                    onAction: () => context.go('/exams'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ExamCategoriesGrid(onOpen: () => context.go('/exams')),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionTitle(
                    title: 'Featured Test Series',
                    action: 'See All',
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
                    action: 'See All',
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
                    action: 'See All',
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
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final largeText = textScale > 1.3;
    final heroHeight = largeText
        ? (285 * textScale).clamp(390, 500).toDouble()
        : 268.0;

    return Container(
      height: heroHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF031B3A),
            Color(0xFF062D5C),
            Color(0xFF0A477C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFE9B94E).withValues(alpha: 0.30),
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
          const Positioned.fill(
            child: CustomPaint(painter: _PunjabLandmarkPainter()),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF031B3A).withValues(alpha: 0.96),
                    const Color(0xFF031B3A).withValues(alpha: 0.78),
                    const Color(0xFF031B3A).withValues(alpha: 0.08),
                  ],
                  stops: const [0, .52, 1],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE9B94E)),
                      borderRadius: BorderRadius.circular(999),
                      color: const Color(0xFF082A52).withValues(alpha: .52),
                    ),
                    child: Text(
                      'PUNJAB GOVT. EXAMS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFFFD977),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                FractionallySizedBox(
                  widthFactor: largeText ? 0.88 : 0.64,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Your Dream Government Job Starts Here',
                    maxLines: largeText ? 5 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.premiumHeading(
                      theme.textTheme.headlineSmall,
                    ).copyWith(
                      color: Colors.white,
                      height: 1.02,
                      letterSpacing: -0.35,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (!largeText)
                  FractionallySizedBox(
                    widthFactor: .67,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Mock tests · Detailed solutions\nPractice · Bilingual content',
                      maxLines: 2,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: .88),
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const Spacer(),
                if (largeText)
                  Material(
                    color: const Color(0xFFFFD36B),
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      onTap: () => context.go('/exams'),
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Start Preparing',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: const Color(0xFF082A52),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 19,
                              color: Color(0xFF082A52),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FilledButton.icon(
                        onPressed: () => context.go('/exams'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD36B),
                          foregroundColor: const Color(0xFF082A52),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 11,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        label: const Text('Start Preparing'),
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 19),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: _HeroFeatureRow()),
                    ],
                  ),
                if (largeText)
                  const SizedBox(height: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroFeatureRow extends StatelessWidget {
  const _HeroFeatureRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _HeroFeature(
            icon: Icons.verified_user_outlined,
            label: 'Focused\npractice',
          ),
        ),
        _HeroFeatureDivider(),
        Expanded(
          child: _HeroFeature(
            icon: Icons.bar_chart_rounded,
            label: 'Exam-focused\ncontent',
          ),
        ),
        _HeroFeatureDivider(),
        Expanded(
          child: _HeroFeature(
            icon: Icons.menu_book_rounded,
            label: 'Bilingual\nsupport',
          ),
        ),
      ],
    );
  }
}

class _HeroFeature extends StatelessWidget {
  const _HeroFeature({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: const Color(0xFFFFD36B)),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: .9),
                fontSize: 8.8,
                height: 1.1,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _HeroFeatureDivider extends StatelessWidget {
  const _HeroFeatureDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: .20),
    );
  }
}

class _HeroPageDots extends StatelessWidget {
  const _HeroPageDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Container(
          width: index == 0 ? 9 : 7,
          height: index == 0 ? 9 : 7,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: index == 0
                ? const Color(0xFF073A78)
                : const Color(0xFFD9E1EA),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _PunjabLandmarkPainter extends CustomPainter {
  const _PunjabLandmarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()
      ..color = const Color(0xFFE4A534).withValues(alpha: .78);
    final warm = Paint()
      ..color = const Color(0xFFF8CE78).withValues(alpha: .72);
    final dark = Paint()
      ..color = const Color(0xFF061B35).withValues(alpha: .46);

    final baseY = size.height * .77;
    final left = size.width * .55;

    canvas.drawRect(
      Rect.fromLTRB(left, baseY, size.width, size.height),
      dark,
    );

    void tower(double cx, double width, double height) {
      final bodyTop = baseY - height * .62;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(cx, (baseY + bodyTop) / 2),
          width: width,
          height: baseY - bodyTop,
        ),
        gold,
      );
      final domeRect = Rect.fromCenter(
        center: Offset(cx, bodyTop - height * .08),
        width: width * 1.05,
        height: height * .30,
      );
      canvas.drawOval(domeRect, warm);
      final finial = Paint()
        ..color = const Color(0xFFFFD36B).withValues(alpha: .88)
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(cx, domeRect.top - 12),
        Offset(cx, domeRect.top + 2),
        finial,
      );
      canvas.drawCircle(Offset(cx, domeRect.top - 13), 2.1, finial);
    }

    tower(size.width * .76, size.width * .13, size.height * .60);
    tower(size.width * .60, size.width * .075, size.height * .35);
    tower(size.width * .91, size.width * .075, size.height * .36);

    final facade = Rect.fromLTRB(
      size.width * .56,
      size.height * .60,
      size.width * .98,
      baseY,
    );
    canvas.drawRect(facade, gold);

    final cut = Paint()..color = const Color(0xFF0B355D).withValues(alpha: .72);
    for (var i = 0; i < 7; i++) {
      final x = facade.left + 10 + i * ((facade.width - 20) / 6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, facade.bottom - 19),
            width: 9,
            height: 24,
          ),
          const Radius.circular(5),
        ),
        cut,
      );
    }

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFD36B).withValues(alpha: .22),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * .80, size.height * .38),
          radius: size.width * .30,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * .80, size.height * .38),
      size.width * .30,
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant _PunjabLandmarkPainter oldDelegate) => false;
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
        // Approved Home layout: keep four exam-category cards per row on
        // normal phone widths. Only collapse on exceptionally narrow surfaces.
        final columns = constraints.maxWidth < 260 ? 2 : 4;
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
    final radius = BorderRadius.circular(18);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
        border: Border.all(
          color: foreground.withValues(alpha: .20),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: foreground.withValues(alpha: .10),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: const Color(0xFF10264A).withValues(alpha: .035),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: foreground, size: 30),
                const SizedBox(height: 9),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF10264A),
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.05,
                  ),
                ),
              ],
            ),
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
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return SizedBox(
      height: largeText ? 250 : 196,
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
    final marks = exam.totalMarks == exam.totalMarks.roundToDouble()
        ? '${exam.totalMarks.round()}'
        : exam.totalMarks.toStringAsFixed(1);
    final foreground =
        alternate ? const Color(0xFF152746) : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: alternate
                  ? const [Color(0xFFFFF0C6), Color(0xFFFFF9E8)]
                  : const [Color(0xFF04366B), Color(0xFF075A98)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: alternate
                  ? const Color(0xFFE7C879).withValues(alpha: .42)
                  : Colors.white.withValues(alpha: .08),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F2745).withValues(alpha: 0.13),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -6,
                top: 23,
                child: Icon(
                  _seriesArtworkIcon(exam),
                  size: 96,
                  color: alternate
                      ? const Color(0xFFB48220).withValues(alpha: .12)
                      : Colors.white.withValues(alpha: .10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(17, 16, 15, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: alternate
                              ? const Color(0xFF8C6A2A).withValues(alpha: .50)
                              : Colors.white.withValues(alpha: .45),
                        ),
                      ),
                      child: Text(
                        'TEST SERIES',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: alternate
                              ? const Color(0xFF72531B)
                              : Colors.white.withValues(alpha: .88),
                          fontWeight: FontWeight.w900,
                          letterSpacing: .7,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 208,
                      child: Text(
                        exam.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.premiumHeading(
                          theme.textTheme.titleLarge,
                        ).copyWith(
                          color: foreground,
                          height: 1.06,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${exam.category} · ${exam.difficulty}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: foreground.withValues(alpha: .74),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: _SeriesMetric(
                            icon: Icons.quiz_outlined,
                            value: '${exam.totalQuestions}',
                            label: 'Questions',
                            light: alternate,
                          ),
                        ),
                        Expanded(
                          child: _SeriesMetric(
                            icon: Icons.schedule_rounded,
                            value: '$durationMinutes min',
                            label: 'Duration',
                            light: alternate,
                          ),
                        ),
                        Expanded(
                          child: _SeriesMetric(
                            icon: Icons.emoji_events_outlined,
                            value: marks,
                            label: 'Marks',
                            light: alternate,
                          ),
                        ),
                        CircleAvatar(
                          radius: 19,
                          backgroundColor: alternate
                              ? const Color(0xFF10264A)
                              : Colors.white.withValues(alpha: 0.16),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                      ],
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

IconData _seriesArtworkIcon(Exam exam) {
  final haystack = '${exam.title} ${exam.category}'.toLowerCase();
  if (haystack.contains('police') || haystack.contains('defence')) {
    return Icons.shield_rounded;
  }
  if (haystack.contains('bank')) return Icons.account_balance_rounded;
  if (haystack.contains('rail')) return Icons.train_rounded;
  if (haystack.contains('teacher') || haystack.contains('teaching')) {
    return Icons.school_rounded;
  }
  return Icons.workspace_premium_rounded;
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
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color.withValues(alpha: .90)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color.withValues(alpha: .68),
            fontSize: 8.5,
          ),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
          final compact = constraints.maxWidth < 330;

          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                action.eyebrow.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF526B91),
                  fontWeight: FontWeight.w900,
                  letterSpacing: .75,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                action.title,
                maxLines: largeText ? 3 : 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF10264A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                action.description,
                maxLines: largeText ? 4 : 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Text(
                    action.actionLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF0B3A6F),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Color(0xFF1672E8),
                  ),
                ],
              ),
            ],
          );

          if (largeText || compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _LearningIcon(),
                const SizedBox(height: 12),
                details,
              ],
            );
          }

          return Row(
            children: [
              const _LearningIcon(),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: details),
              const SizedBox(width: AppSpacing.md),
              const CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFF073A78),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LearningIcon extends StatelessWidget {
  const _LearningIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFE9F3FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.menu_book_rounded,
        color: Color(0xFF1672E8),
        size: 31,
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

    final intro = Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .72),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.track_changes_rounded,
            color: Color(0xFF1672E8),
            size: 31,
          ),
        ),
        const SizedBox(width: 12),
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
                '${analytics.totalTestsAttempted} tests completed so far.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF526B91),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final metrics = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GoalMetric(
          value: '${analytics.totalTestsAttempted}',
          label: 'Tests',
        ),
        const _GoalDivider(),
        _GoalMetric(value: '$accuracy%', label: 'Accuracy'),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE9F5FF), Color(0xFFDDEEFF)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCFE3F8)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1672E8).withValues(alpha: .07),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final largeText =
                    MediaQuery.textScalerOf(context).scale(1) > 1.3;
                if (largeText || constraints.maxWidth < 340) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      intro,
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: metrics,
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: intro),
                    const SizedBox(width: 12),
                    metrics,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalDivider extends StatelessWidget {
  const _GoalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: const Color(0xFF9FC8EE),
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
            color: const Color(0xFF526B91),
            fontWeight: FontWeight.w700,
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
    required this.photoUrl,
    required this.onSearch,
    required this.onNotifications,
    required this.onProfile,
  });

  final String name;
  final String greeting;
  final String dateLabel;
  final String? photoUrl;
  final VoidCallback onSearch;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = photoUrl?.trim();
    final hasPhoto = imageUrl != null && imageUrl.isNotEmpty;
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;

    final brand = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 38,
          height: 40,
          child: CustomPaint(painter: _ExamtreeMarkPainter()),
        ),
        const SizedBox(width: 9),
        Flexible(
          child: Text(
            'Examtree',
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: AppTypography.premiumHeading(
              theme.textTheme.headlineSmall,
            ).copyWith(
              color: const Color(0xFF092B5A),
              fontWeight: FontWeight.w900,
              letterSpacing: -0.45,
            ),
          ),
        ),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderButton(
          icon: Icons.search_rounded,
          tooltip: 'Search tests',
          onTap: onSearch,
        ),
        const SizedBox(width: 2),
        _NotificationButton(onTap: onNotifications),
        const SizedBox(width: 7),
        Semantics(
          button: true,
          label: 'Open profile',
          child: InkWell(
            onTap: onProfile,
            customBorder: const CircleBorder(),
            child: CircleAvatar(
              radius: 21,
              backgroundColor: const Color(0xFFEAF2FB),
              backgroundImage: hasPhoto ? NetworkImage(imageUrl) : null,
              foregroundColor: const Color(0xFF0B3A6F),
              child: hasPhoto
                  ? null
                  : Text(
                      name.isEmpty ? 'S' : name[0].toUpperCase(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );

    return Semantics(
      container: true,
      label: '$greeting, $name. $dateLabel.',
      child: largeText
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(alignment: Alignment.centerLeft, child: brand),
                const SizedBox(height: 6),
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            )
          : Row(
              children: [
                Expanded(child: brand),
                actions,
              ],
            ),
    );
  }
}

class _ExamtreeMarkPainter extends CustomPainter {
  const _ExamtreeMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final navy = Paint()..color = const Color(0xFF0756A5);
    final deep = Paint()..color = const Color(0xFF073A78);
    final gold = Paint()..color = const Color(0xFFF4A21B);

    final left = Path()
      ..moveTo(size.width * .08, size.height * .18)
      ..quadraticBezierTo(
        size.width * .30,
        size.height * .22,
        size.width * .48,
        size.height * .38,
      )
      ..lineTo(size.width * .48, size.height * .92)
      ..quadraticBezierTo(
        size.width * .28,
        size.height * .73,
        size.width * .08,
        size.height * .70,
      )
      ..close();
    canvas.drawPath(left, navy);

    final right = Path()
      ..moveTo(size.width * .92, size.height * .18)
      ..quadraticBezierTo(
        size.width * .70,
        size.height * .22,
        size.width * .52,
        size.height * .38,
      )
      ..lineTo(size.width * .52, size.height * .92)
      ..quadraticBezierTo(
        size.width * .72,
        size.height * .73,
        size.width * .92,
        size.height * .70,
      )
      ..close();
    canvas.drawPath(right, deep);

    final flame = Path()
      ..moveTo(size.width * .50, size.height * .12)
      ..cubicTo(
        size.width * .62,
        size.height * .04,
        size.width * .72,
        size.height * .17,
        size.width * .67,
        size.height * .31,
      )
      ..cubicTo(
        size.width * .63,
        size.height * .43,
        size.width * .55,
        size.height * .48,
        size.width * .50,
        size.height * .55,
      )
      ..cubicTo(
        size.width * .45,
        size.height * .48,
        size.width * .37,
        size.height * .43,
        size.width * .33,
        size.height * .31,
      )
      ..cubicTo(
        size.width * .28,
        size.height * .17,
        size.width * .38,
        size.height * .04,
        size.width * .50,
        size.height * .12,
      )
      ..close();
    canvas.drawPath(flame, gold);
  }

  @override
  bool shouldRepaint(covariant _ExamtreeMarkPainter oldDelegate) => false;
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _HeaderButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Daily reminders',
          onTap: onTap,
        ),
        Positioned(
          right: 7,
          top: 7,
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFFF04452),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
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
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        foregroundColor: const Color(0xFF082A52),
        backgroundColor: Colors.transparent,
      ),
      icon: Icon(icon, size: 27),
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
    final titleWidget = Text(
      title,
      style: AppTypography.premiumHeading(
        Theme.of(context).textTheme.titleLarge,
      ).copyWith(
        color: const Color(0xFF10264A),
      ),
    );
    final actionWidget = TextButton(
      onPressed: onAction,
      child: Text(action),
    );
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;

    if (largeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerRight,
            child: actionWidget,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: titleWidget),
        actionWidget,
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
    final radius = BorderRadius.circular(19);
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
          border: Border.all(color: const Color(0xFFE7EDF4)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10264A).withValues(alpha: .055),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
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
