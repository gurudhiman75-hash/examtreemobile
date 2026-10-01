import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/promotion_campaign.dart';
import '../providers/promotion_providers.dart';

enum PromotionCarouselVisualStyle { standard, loginFeature }

class PromotionPlacementView extends ConsumerWidget {
  const PromotionPlacementView({
    super.key,
    required this.placement,
    this.compact = false,
    this.markLoginCampaignsPresented = false,
    this.visualStyle = PromotionCarouselVisualStyle.standard,
    this.fallbackCampaigns = const <PromotionCampaign>[],
  });

  final PromotionPlacement placement;
  final bool compact;
  final bool markLoginCampaignsPresented;
  final PromotionCarouselVisualStyle visualStyle;
  final List<PromotionCampaign> fallbackCampaigns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(promotionsForPlacementProvider(placement));
    return campaignsAsync.when(
      loading: () => fallbackCampaigns.isEmpty
          ? const SizedBox.shrink()
          : PromotionCarousel(
              campaigns: fallbackCampaigns,
              compact: compact,
              visualStyle: visualStyle,
            ),
      error: (error, stackTrace) => fallbackCampaigns.isEmpty
          ? const SizedBox.shrink()
          : PromotionCarousel(
              campaigns: fallbackCampaigns,
              compact: compact,
              visualStyle: visualStyle,
            ),
      data: (campaigns) {
        final effectiveCampaigns =
            campaigns.isEmpty ? fallbackCampaigns : campaigns;
        if (effectiveCampaigns.isEmpty) return const SizedBox.shrink();
        if (markLoginCampaignsPresented && campaigns.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(promotionSessionRegistryProvider)
                .markLoginCampaignsPresented(campaigns);
          });
        }
        return PromotionCarousel(
          campaigns: effectiveCampaigns,
          compact: compact,
          visualStyle: visualStyle,
        );
      },
    );
  }
}

class PromotionCarousel extends StatefulWidget {
  const PromotionCarousel({
    super.key,
    required this.campaigns,
    this.compact = false,
    this.visualStyle = PromotionCarouselVisualStyle.standard,
    this.onImpression,
    this.onAction,
  });

  final List<PromotionCampaign> campaigns;
  final bool compact;
  final PromotionCarouselVisualStyle visualStyle;
  final ValueChanged<PromotionCampaign>? onImpression;
  final ValueChanged<PromotionCampaign>? onAction;

  @override
  State<PromotionCarousel> createState() => _PromotionCarouselState();
}

class _PromotionCarouselState extends State<PromotionCarousel> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.campaigns.isEmpty) return;
      widget.onImpression?.call(widget.campaigns.first);
    });
  }

  @override
  void didUpdateWidget(covariant PromotionCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_page >= widget.campaigns.length) {
      _page = 0;
      if (_controller.hasClients) _controller.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.campaigns.isEmpty) return const SizedBox.shrink();
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final largeText = textScale > 1.5;
    final loginFeature =
        widget.visualStyle == PromotionCarouselVisualStyle.loginFeature;
    final height = loginFeature
        ? (largeText
            ? (190 * textScale).clamp(290, 390).toDouble()
            : 222.0)
        : widget.compact
            ? (largeText ? 216.0 : 164.0)
            : (largeText ? 228.0 : 176.0);

    return Semantics(
      container: true,
      label: loginFeature ? 'ExamTree features' : 'ExamTree updates',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: height,
            child: PageView.builder(
              key: const Key('promotion-carousel'),
              controller: _controller,
              itemCount: widget.campaigns.length,
              onPageChanged: (value) {
                setState(() => _page = value);
                if (value >= 0 && value < widget.campaigns.length) {
                  widget.onImpression?.call(widget.campaigns[value]);
                }
              },
              itemBuilder: (context, index) {
                final campaign = widget.campaigns[index];
                if (loginFeature) {
                  return _LoginFeatureCard(
                    campaign: campaign,
                    onAction: widget.onAction,
                  );
                }
                return _PromotionCard(
                  campaign: campaign,
                  compact: widget.compact,
                  onAction: widget.onAction,
                );
              },
            ),
          ),
          if (widget.campaigns.length > 1) ...[
            const SizedBox(height: 8),
            Semantics(
              label: loginFeature
                  ? 'Feature ${_page + 1} of ${widget.campaigns.length}'
                  : 'Promotion ${_page + 1} of ${widget.campaigns.length}',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var index = 0;
                      index < widget.campaigns.length;
                      index++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: index == _page ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: index == _page
                            ? const Color(0xFF0B3565)
                            : loginFeature
                                ? const Color(0xFFD4D8DE)
                                : Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
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

class _LoginFeatureCard extends StatelessWidget {
  const _LoginFeatureCard({
    required this.campaign,
    this.onAction,
  });

  final PromotionCampaign campaign;
  final ValueChanged<PromotionCampaign>? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = campaign.imageUrl?.trim();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE1E7EF)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -34,
            child: Container(
              width: 126,
              height: 126,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFE8A8).withValues(alpha: .38),
              ),
            ),
          ),
          Positioned(
            left: -28,
            bottom: -42,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEAF1F8).withValues(alpha: .8),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              campaign.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: const Color(0xFF0B2A50),
                                fontWeight: FontWeight.w900,
                                height: 1.03,
                                letterSpacing: -.45,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              campaign.subtitle,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF68778A),
                                height: 1.32,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const _LoginStudyIllustration(),
                              )
                            : const _LoginStudyIllustration(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Expanded(
                      child: _LoginFeaturePill(
                        icon: Icons.query_stats_rounded,
                        label: 'Exam Focused',
                      ),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: _LoginFeaturePill(
                        icon: Icons.description_outlined,
                        label: 'Expert Content',
                      ),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: _LoginFeaturePill(
                        icon: Icons.insights_rounded,
                        label: 'Track Progress',
                      ),
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

class _LoginFeaturePill extends StatelessWidget {
  const _LoginFeaturePill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFE3E9F1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: const Color(0xFFB77A0B)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF1A385E),
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginStudyIllustration extends StatelessWidget {
  const _LoginStudyIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3D4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Color(0xFFB77A0B),
              size: 25,
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          right: 0,
          child: Column(
            children: [
              Transform.rotate(
                angle: -.04,
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF173F70),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'POLITY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .55,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Container(
                height: 27,
                decoration: BoxDecoration(
                  color: const Color(0xFFCEA13A),
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'HISTORY',
                  style: TextStyle(
                    color: Color(0xFF0A2B53),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .55,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Transform.rotate(
                angle: .03,
                child: Container(
                  height: 27,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E315B),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'GEOGRAPHY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .45,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PromotionCard extends StatelessWidget {
  const _PromotionCard({
    required this.campaign,
    required this.compact,
    this.onAction,
  });

  final PromotionCampaign campaign;
  final bool compact;
  final ValueChanged<PromotionCampaign>? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final imageUrl = campaign.imageUrl?.trim();

    return Material(
      color: scheme.primaryContainer.withValues(alpha: 0.66),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -34,
            top: -42,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          if (imageUrl != null && imageUrl.isNotEmpty)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: compact ? 112 : 132,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surface.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'EXAMTREE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        campaign.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: (compact
                                ? theme.textTheme.titleMedium
                                : theme.textTheme.titleLarge)
                            ?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.25,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        campaign.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              scheme.onPrimaryContainer.withValues(alpha: 0.82),
                          height: 1.35,
                        ),
                      ),
                      if (campaign.hasAction) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            key: Key('promotion-action-${campaign.id}'),
                            onPressed: () {
                              onAction?.call(campaign);
                              context.push(campaign.deepLink!);
                            },
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              foregroundColor: scheme.primary,
                            ),
                            iconAlignment: IconAlignment.end,
                            icon:
                                const Icon(Icons.arrow_forward_rounded, size: 17),
                            label: Text(campaign.ctaLabel!),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (imageUrl != null && imageUrl.isNotEmpty)
                  const Expanded(flex: 3, child: SizedBox()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
