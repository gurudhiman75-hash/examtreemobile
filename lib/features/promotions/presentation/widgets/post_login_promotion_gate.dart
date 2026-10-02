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
  bool _modalOpen = false;

  @override
  Widget build(BuildContext context) {
    final campaignsAsync = ref.watch(
      promotionsForPlacementProvider(PromotionPlacement.postLogin),
    );

    campaignsAsync.whenData((campaigns) {
      if (_modalOpen) return;
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
        if (!mounted || _modalOpen) return;
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
    setState(() => _modalOpen = true);
    final exposureStore = ref.read(promotionExposureStoreProvider);
    final analytics = ref.read(mobileAnalyticsClientProvider);
    await exposureStore.recordImpression(campaign);
    if (!mounted) return;
    unawaited(
      analytics.track(
        'promotion_impression',
        entityType: 'promotion',
        entityId: campaign.id,
        placement: 'post_login',
      ),
    );
    await showDialog<void>(
      context: context,
      barrierDismissible: campaign.isDismissible,
      barrierColor: Colors.black.withValues(alpha: .58),
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final imageUrl = campaign.imageUrl?.trim();
        final hasImage = imageUrl?.isNotEmpty ?? false;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Material(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              elevation: 18,
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hasImage)
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          hasImage ? AppSpacing.md : AppSpacing.xl,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              campaign.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                height: 1.15,
                              ),
                            ),
                            if (campaign.subtitle.trim().isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                campaign.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                              ),
                            ],
                            if (campaign.hasAction) ...[
                              const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                height: 50,
                                child: FilledButton.icon(
                                  key: Key(
                                    'post-login-promotion-action-${campaign.id}',
                                  ),
                                  onPressed: () async {
                                    unawaited(
                                      analytics.track(
                                        'promotion_click',
                                        entityType: 'promotion',
                                        entityId: campaign.id,
                                        placement: 'post_login',
                                      ),
                                    );
                                    Navigator.of(dialogContext).pop();
                                    final external =
                                        campaign.externalUrl?.trim();
                                    if (external != null &&
                                        isSafePromotionExternalUrl(external)) {
                                      await launchUrl(
                                        Uri.parse(external),
                                        mode: LaunchMode.externalApplication,
                                      );
                                      return;
                                    }
                                    final deepLink = campaign.deepLink;
                                    if (isSafePromotionDeepLink(deepLink) &&
                                        mounted) {
                                      context.push(deepLink!);
                                    }
                                  },
                                  iconAlignment: IconAlignment.end,
                                  icon:
                                      const Icon(Icons.arrow_forward_rounded),
                                  label: Text(campaign.ctaLabel!),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (campaign.isDismissible)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Material(
                        color: Colors.white.withValues(alpha: .94),
                        elevation: 2,
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: 'Close promotion',
                          key: Key(
                            'post-login-promotion-close-${campaign.id}',
                          ),
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
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
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
      },
    );
    if (!mounted) return;
    setState(() {
      _modalOpen = false;
      _scheduledCampaignId = null;
    });
  }
}
