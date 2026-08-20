import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../promotions/domain/promotion_campaign.dart';
import '../../promotions/presentation/widgets/promotion_carousel.dart';
import 'home_screen_v5.dart' as v5;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.now});

  final DateTime Function()? now;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            0,
          ),
          child: PromotionPlacementView(
            placement: PromotionPlacement.home,
            compact: true,
          ),
        ),
        Expanded(child: v5.HomeScreen(now: now)),
      ],
    );
  }
}
