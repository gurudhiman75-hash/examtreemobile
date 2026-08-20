import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../promotions/domain/promotion_campaign.dart';
import '../../promotions/presentation/providers/promotion_providers.dart';
import '../../promotions/presentation/widgets/promotion_carousel.dart';
import 'home_screen_v5.dart' as v5;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.now});

  final DateTime Function()? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(
      promotionsForPlacementProvider(PromotionPlacement.home),
    );
    final campaigns = campaignsAsync.value ?? const <PromotionCampaign>[];

    if (campaigns.isEmpty) {
      return v5.HomeScreen(now: now);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            0,
          ),
          child: PromotionCarousel(
            campaigns: campaigns,
            compact: true,
          ),
        ),
        Expanded(child: v5.HomeScreen(now: now)),
      ],
    );
  }
}
