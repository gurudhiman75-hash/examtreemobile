import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/providers/mobile_analytics_provider.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/promotion_campaign.dart';
import '../providers/promotion_providers.dart';

class PostLoginPromotionGate extends ConsumerStatefulWidget {
  const PostLoginPromotionGate({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<PostLoginPromotionGate> createState() =>
      _PostLoginPromotionGateState();
}

class _PostLoginPromotionGateState extends ConsumerState<PostLoginPromotionGate> {
  String? _scheduledCampaignId;
  bool _sheetOpen = false;

  @override
  Widget build(BuildContext context) {
    final campaignsAsync = ref.watch(
      promotionsForPlacementProvider(PromotionPlacement.postLogin),
    );

    campaignsAsync.whenData((campaigns) {
      if (_sheetOpen) return;
      final registry = ref.read(promotionSessionRegistryProvider);
      PromotionCampaign? next;
      for (final campaign in campaigns) {
        if (registry.shouldPresentPostLogin(campaign)) {
          next = campaign;
          break;
        }
      }
      if (next == null || _scheduledCampaignId == next.id) return;
      _scheduledCampaignId = next.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _sheetOpen) return;
        final latestRegistry = ref.read(promotionSessionRegistryProvider);
        if (!latestRegistry.shouldPresentPostLogin(next!)) return;
        latestRegistry.markPostLoginCampaignPresented(next.id);
        _showCampaign(next);
      });
    });

    return widget.child;
  }

  Future<void> _showCampaign(PromotionCampaign campaign) async {
    if (!mounted) return;
    setState(() => _sheetOpen = true);
    final exposureStore = ref.read(promotionExposureStoreProvider);
    final analytics = ref.read(mobileAnalyticsClientProvider);
    await exposureStore.recordImpression(campaign);
    unawaited(
      analytics.track(
        'promotion_impression',
        entityType: 'promotion',
        entityId: campaign.id,
        placement: 'post_login',
      ),
    );
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      isDismissible: campaign.isDismissible,
      enableDrag: campaign.isDismissible,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.lg + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if ((campaign.imageUrl?.trim().isNotEmpty ?? false)) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        campaign.imageUrl!,
                        height: 170,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  Text(
                campaign.title,
                style: Theme.of(sheetContext).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.35,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                campaign.subtitle,
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (campaign.hasAction)
                FilledButton.icon(
                  key: Key('post-login-promotion-action-${campaign.id}'),
                  onPressed: () async {
                    unawaited(
                      analytics.track(
                        'promotion_click',
                        entityType: 'promotion',
                        entityId: campaign.id,
                        placement: 'post_login',
                      ),
                    );
                    Navigator.of(sheetContext).pop();
                    final external = campaign.externalUrl?.trim();
                    if (external != null &&
                        isSafePromotionExternalUrl(external)) {
                      await launchUrl(
                        Uri.parse(external),
                        mode: LaunchMode.externalApplication,
                      );
                      return;
                    }
                    final deepLink = campaign.deepLink;
                    if (isSafePromotionDeepLink(deepLink) && mounted) {
                      context.push(deepLink!);
                    }
                  },
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(campaign.ctaLabel!),
                ),
                  if (campaign.isDismissible) ...[
                    const SizedBox(height: AppSpacing.xs),
                    TextButton(
                      key: Key('post-login-promotion-dismiss-' + campaign.id),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(campaign.hasAction ? 'Not now' : 'Got it'),
                    ),
                  ],
                ],
              ),
              if (campaign.isDismissible)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Material(
                    color: Theme.of(sheetContext)
                        .colorScheme
                        .surface
                        .withValues(alpha: .92),
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: 'Close promotion',
                      key: Key('post-login-promotion-close-' + campaign.id),
                      onPressed: () async {
                        unawaited(
                          analytics.track(
                            'promotion_dismiss',
                            entityType: 'promotion',
                            entityId: campaign.id,
                            placement: 'post_login',
                          ),
                        );
                        await exposureStore.dismiss(campaign.id);
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    setState(() {
      _sheetOpen = false;
      _scheduledCampaignId = null;
    });
  }
}
