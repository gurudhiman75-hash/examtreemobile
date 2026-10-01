import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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
    await exposureStore.recordImpression(campaign);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .42),
      showDragHandle: false,
      isDismissible: campaign.isDismissible,
      enableDrag: campaign.isDismissible,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final hasImage = campaign.imageUrl?.trim().isNotEmpty ?? false;
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              10,
              AppSpacing.sm,
              10,
              10 + MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 560),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE3E9F1)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF071C38).withValues(alpha: .18),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hasImage)
                        Image.network(
                          campaign.imageUrl!,
                          height: 178,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox(height: 10),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF4D6),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  'EXAMTREE',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFF8A5A00),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: .7,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 9),
                            Text(
                              campaign.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: const Color(0xFF10264A),
                                fontWeight: FontWeight.w900,
                                letterSpacing: -.35,
                                height: 1.12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              campaign.subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF68778A),
                                height: 1.45,
                              ),
                            ),
                            if (campaign.hasAction) ...[
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                key: Key(
                                  'post-login-promotion-action-${campaign.id}',
                                ),
                                onPressed: () async {
                                  Navigator.of(sheetContext).pop();
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
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  backgroundColor: const Color(0xFF073A6A),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                iconAlignment: IconAlignment.end,
                                icon: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 19,
                                ),
                                label: Text(campaign.ctaLabel!),
                              ),
                            ],
                            const SizedBox(height: 4),
                            TextButton(
                              key: Key(
                                'post-login-promotion-dismiss-${campaign.id}',
                              ),
                              onPressed: () =>
                                  Navigator.of(sheetContext).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF526274),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              child: Text(
                                campaign.hasAction ? 'Not now' : 'Got it',
                              ),
                            ),
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
                        shape: const CircleBorder(),
                        elevation: hasImage ? 2 : 0,
                        child: IconButton(
                          tooltip: 'Close promotion',
                          key: Key(
                            'post-login-promotion-close-${campaign.id}',
                          ),
                          onPressed: () async {
                            await exposureStore.dismiss(campaign.id);
                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF10264A),
                          ),
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
      _sheetOpen = false;
      _scheduledCampaignId = null;
    });
  }
}
