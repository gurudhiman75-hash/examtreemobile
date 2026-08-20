import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/promotions/presentation/widgets/post_login_promotion_gate.dart';
import 'app_scaffold_v2.dart' as v2;

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return PostLoginPromotionGate(
      child: v2.AppScaffold(navigationShell: navigationShell),
    );
  }
}
