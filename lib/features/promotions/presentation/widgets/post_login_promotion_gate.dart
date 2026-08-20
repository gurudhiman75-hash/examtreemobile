import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    context.push(campaign.deepLink!);
                  },
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(campaign.ctaLabel!),
                ),
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                key: Key('post-login-promotion-dismiss-${campaign.id}'),
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: Text(campaign.hasAction ? 'Not now' : 'Got it'),
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
