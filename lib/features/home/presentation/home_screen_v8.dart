import 'dart:async';

// ignore_for_file: unused_element, unused_element_parameter, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/analytics_model.dart';
import '../../../core/providers/mobile_analytics_provider.dart';
import '../../../core/models/exam_model.dart';
import '../../../core/models/result_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../companion/presentation/providers/daily_companion_providers.dart';
import '../../content_planning/presentation/mobile_content_planning_providers.dart';
import '../../content_planning/presentation/widgets/mobile_planned_content_section.dart';
import '../../exam_preferences/presentation/providers/exam_preferences_providers.dart';
import '../../exams/presentation/providers/exam_providers.dart';
import '../../notifications/presentation/mobile_notifications_screen.dart';
import '../../profile/presentation/providers/analytics_providers.dart';
import '../../promotions/domain/promotion_campaign.dart';
import '../../promotions/presentation/providers/promotion_providers.dart';
import '../../promotions/presentation/widgets/promotion_carousel.dart';
import '../../results/presentation/providers/result_providers.dart';
import '../domain/mobile_home_configuration.dart';
import 'home_exam_priority.dart';
import 'home_primary_action.dart';
import 'mobile_home_providers.dart';
import 'mobile_custom_home_section.dart';

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
      ..invalidate(mobileHomeConfigurationProvider)
      ..invalidate(promotionsForPlacementProvider(PromotionPlacement.home))
      ..invalidate(mobileContentPlanProvider('home_learn'))
      ..invalidate(mobileContentPlanProvider('home_current_affairs'))
      ..invalidate(mobileNotificationInboxProvider);

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
    final homeConfigAsync = ref.watch(mobileHomeConfigurationProvider);
    final user = ref.watch(authStateChangesProvider).value;
    final notificationUnreadCount = user == null
        ? 0
        : (ref
                .watch(mobileNotificationInboxProvider)
                .value
                ?.where((item) => item.isUnread)
                .length ??
            0);
    final currentTime = now?.call() ?? DateTime.now();
    final mobileAnalytics = ref.read(mobileAnalyticsClientProvider);
    final promotionExposureStore = ref.read(promotionExposureStoreProvider);
    unawaited(
      mobileAnalytics.trackOnce(
        'home_view',
        'home_view',
        metadata: const <String, Object?>{'screen': 'home'},
      ),
    );

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
    final homeConfig =
        homeConfigAsync.value ?? MobileHomeConfiguration.fallback;
    final examCategoriesSetting = homeConfig.settingFor('exam_categories');
    final featuredSeriesSetting = homeConfig.settingFor('featured_test_series');
    final continueLearningSetting = homeConfig.settingFor('continue_learning');
    final recommendedLearningSetting =
        homeConfig.settingFor('recommended_learning');
    final currentAffairsSetting = homeConfig.settingFor('current_affairs');
    final todayGoalSetting = homeConfig.settingFor('today_goal');
    final heroSetting = homeConfig.settingFor('hero');

    final configurableSections = <String, Widget>{
      'hero': heroSetting.isVisible
          ? Column(
        children: [
          if (homeConfig.heroSlides.isNotEmpty)
            _ConfiguredHeroCarousel(
              slides: homeConfig.heroSlides,
              onImpression: (slide) => unawaited(
                mobileAnalytics.track(
                  'hero_impression',
                  entityType: 'hero_slide',
                  entityId: slide.id,
                  placement: 'home',
                ),
              ),
              onClick: (slide) => unawaited(
                mobileAnalytics.track(
                  'hero_click',
                  entityType: 'hero_slide',
                  entityId: slide.id,
                  placement: 'home',
                ),
              ),
            )
          else
            const Column(
              children: [
                _HomePromoFallback(),
                SizedBox(height: 6),
                _HeroPageDots(),
              ],
            ),
          if (campaigns.isNotEmpty) ...[
            const SizedBox(height: 10),
            PromotionCarousel(
              campaigns: campaigns,
              compact: true,
              onImpression: (campaign) {
                unawaited(promotionExposureStore.recordImpression(campaign));
                unawaited(
                  mobileAnalytics.track(
                    'promotion_impression',
                    entityType: 'promotion',
                    entityId: campaign.id,
                    placement: 'home',
                  ),
                );
              },
              onAction: (campaign) => unawaited(
                mobileAnalytics.track(
                  'promotion_click',
                  entityType: 'promotion',
                  entityId: campaign.id,
                  placement: 'home',
                ),
              ),
              onDismiss: (campaign) {
                unawaited(promotionExposureStore.dismiss(campaign.id));
                unawaited(
                  mobileAnalytics.track(
                    'promotion_dismiss',
                    entityType: 'promotion',
                    entityId: campaign.id,
                    placement: 'home',
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 12),
        ],
      )
          : const SizedBox.shrink(),
      'exam_categories': examCategoriesSetting.isVisible
          ? Column(
        children: [
          _SectionTitle(
            title: examCategoriesSetting.title.trim().isNotEmpty
                ? examCategoriesSetting.title
                : 'Exam Categories',
            action: 'See All',
            onAction: () => context.go('/exams'),
            subtitle: examCategoriesSetting.subtitle,
            iconName: examCategoriesSetting.iconName,
            iconUrl: examCategoriesSetting.iconUrl,
          ),
          const SizedBox(height: 3),
          _ExamCategoriesGrid(
            families: homeConfig.featuredExamFamilies,
            overrides: homeConfig.itemOverrides,
            layout: examCategoriesSetting.layout,
            columns: examCategoriesSetting.columns,
            onOpen: () => context.go('/exams'),
          ),
          const SizedBox(height: 8),
        ],
      )
          : const SizedBox.shrink(),
      'featured_test_series': featuredSeriesSetting.isVisible
          ? Column(
        children: [
          _SectionTitle(
            title: featuredSeriesSetting.title.trim().isNotEmpty
                ? featuredSeriesSetting.title
                : 'Featured Test Series',
            action: 'See All',
            onAction: () => context.go('/exams'),
            subtitle: featuredSeriesSetting.subtitle,
            iconName: featuredSeriesSetting.iconName,
            iconUrl: featuredSeriesSetting.iconUrl,
          ),
          const SizedBox(height: 6),
          if (homeConfig.featuredTestSeries.isNotEmpty)
            _ConfiguredSeriesRail(
              series: homeConfig.featuredTestSeries,
              overrides: homeConfig.itemOverrides,
              layout: featuredSeriesSetting.layout,
              columns: featuredSeriesSetting.columns,
              onOpen: (series) => context.push('/test-series?id=${Uri.encodeQueryComponent(series.id)}'),
            )
          else
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
          const SizedBox(height: 16),
        ],
      )
          : const SizedBox.shrink(),
      'continue_learning': continueLearningSetting.isVisible
          ? Column(
        children: [
          _SectionTitle(
            title: continueLearningSetting.title.trim().isNotEmpty
                ? continueLearningSetting.title
                : 'Continue Learning',
            action: 'See All',
            onAction: () => context.go('/learn'),
            subtitle: continueLearningSetting.subtitle,
            iconName: continueLearningSetting.iconName,
            iconUrl: continueLearningSetting.iconUrl,
          ),
          const SizedBox(height: 6),
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
          const SizedBox(height: 16),
        ],
      )
          : const SizedBox.shrink(),
      'recommended_learning': recommendedLearningSetting.isVisible
          ? MobilePlannedContentSection(
              slotKey: 'home_learn',
              title: recommendedLearningSetting.title.trim().isNotEmpty
                  ? recommendedLearningSetting.title
                  : 'Recommended Learning',
              subtitle: recommendedLearningSetting.subtitle,
              iconName: recommendedLearningSetting.iconName,
              iconUrl: recommendedLearningSetting.iconUrl,
            )
          : const SizedBox.shrink(),
      'current_affairs': currentAffairsSetting.isVisible
          ? MobilePlannedContentSection(
              slotKey: 'home_current_affairs',
              title: currentAffairsSetting.title.trim().isNotEmpty
                  ? currentAffairsSetting.title
                  : 'Current Affairs',
              subtitle: currentAffairsSetting.subtitle,
              iconName: currentAffairsSetting.iconName,
              iconUrl: currentAffairsSetting.iconUrl,
            )
          : const SizedBox.shrink(),
      'today_goal': todayGoalSetting.isVisible
          ? Column(
              children: [
                _SectionTitle(
                  title: todayGoalSetting.title.trim().isNotEmpty
                      ? todayGoalSetting.title
                      : "Today's Goal",
                  action: 'See All',
                  onAction: () => context.push('/profile'),
                  subtitle: todayGoalSetting.subtitle,
                  iconName: todayGoalSetting.iconName,
                  iconUrl: todayGoalSetting.iconUrl,
                ),
                const SizedBox(height: 6),
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
                const SizedBox(height: 16),
              ],
            )
          : const SizedBox.shrink(),
      for (final section in homeConfig.customSections)
        section.id: MobileCustomHomeSectionView(section: section),
    };

    final orderedSections = homeConfig.sectionOrder
        .map((key) => configurableSections[key])
        .whereType<Widget>()
        .toList(growable: false);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => _refreshAll(ref),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                8,
                AppSpacing.sm,
                8,
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
                    onNotifications: () => context.push('/notifications'),
                    notificationUnreadCount: notificationUnreadCount,
                    onProfile: () => context.push('/profile'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...orderedSections,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _ConfiguredHeroCarousel extends StatefulWidget {
  const _ConfiguredHeroCarousel({
    required this.slides,
    this.onImpression,
    this.onClick,
  });

  final List<MobileHeroSlide> slides;
  final ValueChanged<MobileHeroSlide>? onImpression;
  final ValueChanged<MobileHeroSlide>? onClick;

  @override
  State<_ConfiguredHeroCarousel> createState() => _ConfiguredHeroCarouselState();
}

class _ConfiguredHeroCarouselState extends State<_ConfiguredHeroCarousel> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.slides.isEmpty) return;
      widget.onImpression?.call(widget.slides.first);
    });
  }

  Future<void> _open(MobileHeroSlide slide) async {
    if (!mounted) return;
    widget.onClick?.call(slide);
    switch (slide.destinationType) {
      case 'exam':
        if (slide.destinationValue.isNotEmpty) {
          context.push('/exam-details', extra: slide.destinationValue);
        } else {
          context.go('/exams');
        }
        return;
      case 'test_series':
        final destination = slide.destinationValue.trim();
        if (destination.isNotEmpty) {
          context.push('/test-series?id=${Uri.encodeQueryComponent(destination)}');
        } else {
          context.go('/exams');
        }
        return;
      case 'learn':
        final destination = slide.destinationValue.trim();
        context.go(destination.startsWith('/') ? destination : '/learn');
        return;
      case 'page':
        final destination = slide.destinationValue.trim();
        if (destination.isNotEmpty) {
          context.push('/page/${Uri.encodeComponent(destination)}');
        }
        return;
      case 'url':
        final uri = Uri.tryParse(slide.destinationValue);
        if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        return;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.slides;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final height = textScale > 1.3
        ? (214 * textScale).clamp(285, 360).toDouble()
        : 194.0;

    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            itemCount: slides.length,
            onPageChanged: (value) {
              setState(() => _index = value);
              if (value >= 0 && value < slides.length) {
                widget.onImpression?.call(slides[value]);
              }
            },
            itemBuilder: (context, index) {
              final slide = slides[index];
              final hasImage = slide.imageUrl.trim().isNotEmpty;
              final hasAction = slide.destinationType != 'none' &&
                  (slide.destinationType != 'url' ||
                      slide.destinationValue.trim().isNotEmpty);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: hasAction ? () => _open(slide) : null,
                    child: Ink(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF031B3A),
                            Color(0xFF063A70),
                            Color(0xFF0B5D96),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (hasImage)
                            Image.network(
                              slide.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF02172F)
                                      .withValues(alpha: .96),
                                  const Color(0xFF031B3A)
                                      .withValues(alpha: .76),
                                  const Color(0xFF031B3A)
                                      .withValues(alpha: .18),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  slide.title,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.premiumHeading(
                                    Theme.of(context).textTheme.headlineSmall,
                                  ).copyWith(
                                    color: Colors.white,
                                    height: 1.04,
                                  ),
                                ),
                                if (slide.subtitle.trim().isNotEmpty) ...[
                                  const SizedBox(height: 7),
                                  SizedBox(
                                    width: MediaQuery.sizeOf(context).width * .62,
                                    child: Text(
                                      slide.subtitle,
                                      maxLines: textScale > 1.3 ? 3 : 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.white
                                                .withValues(alpha: .88),
                                            height: 1.3,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                if (hasAction)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD36B),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      slide.ctaLabel.trim().isEmpty
                                          ? 'Explore'
                                          : slide.ctaLabel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: const Color(0xFF0B2748),
                                            fontWeight: FontWeight.w900,
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
                ),
              );
            },
          ),
        ),
        if (slides.length > 1) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              slides.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: index == _index ? 9 : 7,
                height: index == _index ? 9 : 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: index == _index
                      ? const Color(0xFF073A78)
                      : const Color(0xFFD9E1EA),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ConfiguredSeriesRail extends StatelessWidget {
  const _ConfiguredSeriesRail({
    required this.series,
    required this.onOpen,
    this.overrides = const {},
    this.layout = '',
    this.columns = 0,
  });

  final List<MobileFeaturedTestSeries> series;
  final ValueChanged<MobileFeaturedTestSeries> onOpen;
  final Map<String, MobileHomeItemOverride> overrides;
  final String layout;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final visibleSeries = series
        .where((item) => !(overrides[item.id]?.hidden ?? false))
        .toList(growable: false);
    if (visibleSeries.isEmpty) return const SizedBox.shrink();

    Widget card(int index, {bool compact = false, bool listMode = false}) {
      final item = visibleSeries[index];
      return _ConfiguredSeriesCard(
        item: item,
        itemOverride: overrides[item.id],
        alternate: index.isOdd,
        compact: compact,
        listMode: listMode,
        onTap: () => onOpen(item),
      );
    }

    switch (layout.trim().toLowerCase()) {
      case 'grid':
        final requestedColumns = columns <= 0 ? 2 : columns.clamp(1, 2).toInt();
        return LayoutBuilder(
          builder: (context, constraints) {
            final effectiveColumns =
                constraints.maxWidth < 330 ? 1 : requestedColumns;
            const gap = 8.0;
            final width =
                (constraints.maxWidth - gap * (effectiveColumns - 1)) /
                    effectiveColumns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var index = 0; index < visibleSeries.length; index++)
                  SizedBox(
                    width: width,
                    height: effectiveColumns >= 2 ? 150 : 158,
                    child: card(index, compact: effectiveColumns >= 2),
                  ),
              ],
            );
          },
        );
      case 'list':
        return Column(
          children: [
            for (var index = 0; index < visibleSeries.length; index++) ...[
              SizedBox(height: 112, child: card(index, listMode: true)),
              if (index != visibleSeries.length - 1)
                const SizedBox(height: 8),
            ],
          ],
        );
      default:
        return SizedBox(
          height: 166,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: visibleSeries.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) => SizedBox(
              width: 286,
              child: card(index),
            ),
          ),
        );
    }
  }
}

class _ConfiguredSeriesCard extends StatelessWidget {
  const _ConfiguredSeriesCard({
    required this.item,
    required this.alternate,
    required this.onTap,
    this.itemOverride,
    this.compact = false,
    this.listMode = false,
  });

  final MobileFeaturedTestSeries item;
  final MobileHomeItemOverride? itemOverride;
  final bool alternate;
  final VoidCallback onTap;
  final bool compact;
  final bool listMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = itemOverride?.title.trim().isNotEmpty == true
        ? itemOverride!.title
        : item.name;
    final displaySubtitle = itemOverride?.subtitle.trim().isNotEmpty == true
        ? itemOverride!.subtitle
        : item.examName;
    final badge = itemOverride?.badge.trim().isNotEmpty == true
        ? itemOverride!.badge
        : 'TEST SERIES';
    final imageUrl = itemOverride?.imageUrl.trim() ?? '';
    final hasImage = imageUrl.isNotEmpty;
    final foreground =
        hasImage || !alternate ? Colors.white : const Color(0xFF152746);
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(compact ? 16 : 22),
      gradient: hasImage
          ? null
          : LinearGradient(
              colors: alternate
                  ? const [Color(0xFFFFF0C6), Color(0xFFFFF9E8)]
                  : const [Color(0xFF04366B), Color(0xFF075A98)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      color: hasImage ? const Color(0xFF04366B) : null,
      border: Border.all(
        color: alternate && !hasImage
            ? const Color(0xFFE7C879).withValues(alpha: .42)
            : Colors.white.withValues(alpha: .08),
      ),
    );

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          badge.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: foreground.withValues(alpha: .78),
            fontWeight: FontWeight.w900,
            letterSpacing: .6,
            fontSize: compact ? 8 : null,
          ),
        ),
        SizedBox(height: compact ? 5 : 8),
        Row(
          children: [
            if (itemOverride?.iconUrl.trim().isNotEmpty == true) ...[
              Image.network(
                itemOverride!.iconUrl,
                width: compact ? 20 : 24,
                height: compact ? 20 : 24,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  _homeIconFromName(itemOverride!.iconName),
                  size: compact ? 20 : 24,
                  color: foreground,
                ),
              ),
              const SizedBox(width: 7),
            ] else if (itemOverride?.iconName.trim().isNotEmpty == true) ...[
              Icon(
                _homeIconFromName(itemOverride!.iconName),
                size: compact ? 20 : 24,
                color: foreground,
              ),
              const SizedBox(width: 7),
            ],
            Expanded(
              child: Text(
                displayName,
                maxLines: compact ? 2 : 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.premiumHeading(
                  compact ? theme.textTheme.titleSmall : theme.textTheme.titleLarge,
                ).copyWith(color: foreground, height: 1.06),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (!compact)
          Text(
            displaySubtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: foreground.withValues(alpha: .72),
              fontWeight: FontWeight.w600,
            ),
          ),
        const Spacer(),
        Row(
          children: [
            Icon(
              Icons.layers_rounded,
              size: compact ? 14 : 17,
              color: foreground.withValues(alpha: .82),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                item.testCount == 1 ? '1 test' : '${item.testCount} tests',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 10 : null,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_rounded,
                color: foreground, size: compact ? 16 : 20),
          ],
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      borderRadius: decoration.borderRadius as BorderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: decoration,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              if (hasImage)
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xE6032345), Color(0xB3054C80)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(compact ? 11 : 16),
                child: listMode
                    ? Row(
                        children: [
                          Expanded(child: copy),
                        ],
                      )
                    : copy,
              ),
            ],
          ),
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
        ? (238 * textScale).clamp(335, 425).toDouble()
        : 194.0;

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
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
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
                const SizedBox(height: 7),
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
                const SizedBox(height: 4),
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
                            horizontal: 14,
                            vertical: 8,
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

IconData _homeIconFromName(String value, {IconData fallback = Icons.apps_rounded}) {
  switch (value.trim().toLowerCase()) {
    case 'school':
    case 'teaching':
      return Icons.school_rounded;
    case 'bank':
    case 'banking':
      return Icons.account_balance_rounded;
    case 'railway':
    case 'train':
      return Icons.train_rounded;
    case 'defence':
      return Icons.shield_rounded;
    case 'government':
    case 'govt':
      return Icons.apartment_rounded;
    case 'learn':
    case 'book':
      return Icons.menu_book_rounded;
    case 'test':
    case 'quiz':
      return Icons.quiz_rounded;
    case 'news':
    case 'current_affairs':
      return Icons.newspaper_rounded;
    case 'star':
      return Icons.star_rounded;
    case 'brain':
      return Icons.psychology_alt_rounded;
    case 'bell':
      return Icons.notifications_rounded;
    case 'sparkles':
      return Icons.auto_awesome_rounded;
    case 'grid':
      return Icons.grid_view_rounded;
    case 'location':
    case 'punjab':
      return Icons.location_on_rounded;
    default:
      return fallback;
  }
}

class _ExamCategoryPresentation {
  const _ExamCategoryPresentation({
    required this.label,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.iconUrl,
    required this.imageUrl,
  });

  final String label;
  final String subtitle;
  final String badge;
  final IconData icon;
  final Color background;
  final Color foreground;
  final String iconUrl;
  final String imageUrl;
}

class _ExamCategoriesGrid extends StatelessWidget {
  const _ExamCategoriesGrid({
    required this.onOpen,
    this.families = const [],
    this.overrides = const {},
    this.layout = '',
    this.columns = 0,
  });

  final VoidCallback onOpen;
  final List<MobileFeaturedExamFamily> families;
  final Map<String, MobileHomeItemOverride> overrides;
  final String layout;
  final int columns;

  static const _items = [
    _ExamCategoryPresentation(label: 'Punjab Govt.', subtitle: '', badge: '', icon: Icons.location_on_rounded, background: Color(0xFFFFEFEF), foreground: Color(0xFFF04452), iconUrl: '', imageUrl: ''),
    _ExamCategoryPresentation(label: 'SSC', subtitle: '', badge: '', icon: Icons.workspace_premium_rounded, background: Color(0xFFEAF8F2), foreground: Color(0xFF11966F), iconUrl: '', imageUrl: ''),
    _ExamCategoryPresentation(label: 'Banking', subtitle: '', badge: '', icon: Icons.account_balance_rounded, background: Color(0xFFECF4FF), foreground: Color(0xFF1672E8), iconUrl: '', imageUrl: ''),
    _ExamCategoryPresentation(label: 'Railway', subtitle: '', badge: '', icon: Icons.train_rounded, background: Color(0xFFF3EEFF), foreground: Color(0xFF7248E8), iconUrl: '', imageUrl: ''),
    _ExamCategoryPresentation(label: 'Teaching', subtitle: '', badge: '', icon: Icons.school_rounded, background: Color(0xFFFFF5E8), foreground: Color(0xFFF28A19), iconUrl: '', imageUrl: ''),
    _ExamCategoryPresentation(label: 'Defence', subtitle: '', badge: '', icon: Icons.shield_rounded, background: Color(0xFFEAF8F2), foreground: Color(0xFF159D73), iconUrl: '', imageUrl: ''),
    _ExamCategoryPresentation(label: 'State PCS', subtitle: '', badge: '', icon: Icons.apartment_rounded, background: Color(0xFFFFEEEE), foreground: Color(0xFFF04452), iconUrl: '', imageUrl: ''),
    _ExamCategoryPresentation(label: 'Other Exams', subtitle: '', badge: '', icon: Icons.grid_view_rounded, background: Color(0xFFF1F4F8), foreground: Color(0xFF718096), iconUrl: '', imageUrl: ''),
  ];

  static (String, IconData, Color, Color) _visual(
    MobileFeaturedExamFamily family,
  ) {
    final key = '${family.code} ${family.name}'.toLowerCase();
    if (key.contains('punjab')) {
      return (family.name, Icons.location_on_rounded,
          const Color(0xFFFFEFEF), const Color(0xFFF04452));
    }
    if (key.contains('ssc')) {
      return (family.name, Icons.workspace_premium_rounded,
          const Color(0xFFEAF8F2), const Color(0xFF11966F));
    }
    if (key.contains('bank')) {
      return (family.name, Icons.account_balance_rounded,
          const Color(0xFFECF4FF), const Color(0xFF1672E8));
    }
    if (key.contains('rail')) {
      return (family.name, Icons.train_rounded,
          const Color(0xFFF3EEFF), const Color(0xFF7248E8));
    }
    if (key.contains('teach')) {
      return (family.name, Icons.school_rounded,
          const Color(0xFFFFF5E8), const Color(0xFFF28A19));
    }
    if (key.contains('defen')) {
      return (family.name, Icons.shield_rounded,
          const Color(0xFFEAF8F2), const Color(0xFF159D73));
    }
    if (key.contains('pcs') || key.contains('state')) {
      return (family.name, Icons.apartment_rounded,
          const Color(0xFFFFEEEE), const Color(0xFFF04452));
    }
    return (family.name, Icons.grid_view_rounded,
        const Color(0xFFF1F4F8), const Color(0xFF718096));
  }

  @override
  Widget build(BuildContext context) {
    final items = families.isEmpty
        ? _items
        : families
            .where((family) => !(overrides[family.id]?.hidden ?? false))
            .take(12)
            .map((family) {
              final base = _visual(family);
              final override = overrides[family.id];
              return _ExamCategoryPresentation(
                label: override?.title.trim().isNotEmpty == true
                    ? override!.title
                    : base.$1,
                subtitle: override?.subtitle ?? '',
                badge: override?.badge ?? '',
                icon: override?.iconName.trim().isNotEmpty == true
                    ? _homeIconFromName(override!.iconName, fallback: base.$2)
                    : base.$2,
                background: base.$3,
                foreground: base.$4,
                iconUrl: override?.iconUrl ?? '',
                imageUrl: override?.imageUrl ?? '',
              );
            })
            .toList(growable: false);

    if (layout.trim().toLowerCase() == 'horizontal') {
      return SizedBox(
        height: 126,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) => SizedBox(
            width: 102,
            child: _ExamCategoryTile(
              item: items[index],
              onTap: onOpen,
              showDetails: false,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 4.0;
        final requestedColumns = columns <= 0 ? 4 : columns.clamp(2, 4).toInt();
        final effectiveColumns =
            constraints.maxWidth < 260 ? 2 : requestedColumns;
        final width =
            (constraints.maxWidth - gap * (effectiveColumns - 1)) /
                effectiveColumns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items
              .map(
                (item) => SizedBox(
                  width: width,
                  child: _ExamCategoryTile(
                    item: item,
                    onTap: onOpen,
                    showDetails: effectiveColumns <= 2,
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
    required this.item,
    required this.onTap,
    required this.showDetails,
  });

  final _ExamCategoryPresentation item;
  final VoidCallback onTap;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(18);
    final visual = item.imageUrl.trim().isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.imageUrl,
              width: 34,
              height: 34,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(item.icon, color: item.foreground, size: 30),
            ),
          )
        : item.iconUrl.trim().isNotEmpty
            ? Image.network(
                item.iconUrl,
                width: 30,
                height: 30,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Icon(item.icon, color: item.foreground, size: 30),
              )
            : Icon(item.icon, color: item.foreground, size: 30);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: item.background,
        borderRadius: radius,
        border: Border.all(
          color: item.foreground.withValues(alpha: .20),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: item.foreground.withValues(alpha: .10),
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
                if (item.badge.trim().isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .74),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.badge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: item.foreground,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                visual,
                const SizedBox(height: 9),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF10264A),
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.05,
                  ),
                ),
                if (showDetails && item.subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF718096),
                      fontSize: 9,
                    ),
                  ),
                ],
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
    required this.notificationUnreadCount,
    required this.onProfile,
  });

  final String name;
  final String greeting;
  final String dateLabel;
  final String? photoUrl;
  final VoidCallback onSearch;
  final VoidCallback onNotifications;
  final int notificationUnreadCount;
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
        _NotificationButton(
          onTap: onNotifications,
          unreadCount: notificationUnreadCount,
        ),
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
  const _NotificationButton({
    required this.onTap,
    required this.unreadCount,
  });

  final VoidCallback onTap;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final badgeLabel = unreadCount > 99 ? '99+' : '$unreadCount';
    return Semantics(
      button: true,
      label: unreadCount > 0
          ? 'Notifications, $unreadCount unread'
          : 'Notifications, no unread updates',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _HeaderButton(
            icon: Icons.notifications_none_rounded,
            tooltip: unreadCount > 0
                ? 'Notifications ($unreadCount unread)'
                : 'Notifications',
            onTap: onTap,
          ),
          if (unreadCount > 0)
            Positioned(
              right: 1,
              top: 1,
              child: Container(
                constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF04452),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  badgeLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        height: 1,
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
    this.subtitle = '',
    this.iconName = '',
    this.iconUrl = '',
  });

  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onAction;
  final String iconName;
  final String iconUrl;

  Widget _legacyHeader(BuildContext context) {
    final titleText = Text(
      title,
      style: AppTypography.premiumHeading(
        Theme.of(context).textTheme.titleLarge,
      ).copyWith(
        color: const Color(0xFF10264A),
      ),
    );
    final titleWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (iconUrl.trim().isNotEmpty)
          Image.network(
            iconUrl,
            width: 22,
            height: 22,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              _homeIconFromName(iconName),
              size: 22,
              color: const Color(0xFF10264A),
            ),
          )
        else if (iconName.trim().isNotEmpty)
          Icon(
            _homeIconFromName(iconName),
            size: 22,
            color: const Color(0xFF10264A),
          ),
        if (iconName.trim().isNotEmpty || iconUrl.trim().isNotEmpty)
          const SizedBox(width: 7),
        Flexible(child: titleText),
      ],
    );
    final actionWidget = TextButton(
      onPressed: onAction,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
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

  @override
  Widget build(BuildContext context) {
    if (subtitle.trim().isEmpty) return _legacyHeader(context);

    final theme = Theme.of(context);
    final titleWidget = Row(
      children: [
        if (iconUrl.trim().isNotEmpty)
          Image.network(
            iconUrl,
            width: 22,
            height: 22,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              _homeIconFromName(iconName),
              size: 22,
              color: const Color(0xFF10264A),
            ),
          )
        else if (iconName.trim().isNotEmpty)
          Icon(
            _homeIconFromName(iconName),
            size: 22,
            color: const Color(0xFF10264A),
          ),
        if (iconName.trim().isNotEmpty || iconUrl.trim().isNotEmpty)
          const SizedBox(width: 7),
        Expanded(
          child: Text(
            title,
            style: AppTypography.premiumHeading(
              theme.textTheme.titleLarge,
            ).copyWith(color: const Color(0xFF10264A)),
          ),
        ),
      ],
    );
    final actionWidget = TextButton(
      onPressed: onAction,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      child: Text(action),
    );
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleWidget,
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF718096),
            height: 1.3,
          ),
        ),
      ],
    );
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    if (largeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading,
          const SizedBox(height: 2),
          Align(alignment: Alignment.centerRight, child: actionWidget),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: heading),
        const SizedBox(width: 8),
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
