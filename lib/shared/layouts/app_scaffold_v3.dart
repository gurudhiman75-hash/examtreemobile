import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/diagnostics/presentation/network_diagnostics_screen.dart';
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
    final shell = PostLoginPromotionGate(
      child: v2.AppScaffold(navigationShell: navigationShell),
    );
    if (!kDebugMode) return shell;

    return Stack(
      children: [
        shell,
        Positioned(
          right: 12,
          bottom: 84,
          child: SafeArea(
            child: FloatingActionButton.small(
              heroTag: 'shell-network-diagnostics',
              tooltip: 'Network diagnostics',
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const NetworkDiagnosticsScreen(),
                  ),
                );
              },
              child: const Icon(Icons.monitor_heart_outlined),
            ),
          ),
        ),
      ],
    );
  }
}
