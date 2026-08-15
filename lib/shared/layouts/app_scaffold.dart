import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/companion/presentation/providers/daily_companion_providers.dart';

bool shouldResetBranchOnSelection({
  required int selectedIndex,
  required int currentIndex,
}) {
  // Home is the canonical dashboard root. Re-entering it should never restore a
  // stale/offstage branch state; always rebuild from /home. Other branches keep
  // their navigation stacks, while re-tapping the active tab resets as before.
  return selectedIndex == 0 || selectedIndex == currentIndex;
}

class AppScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: shouldResetBranchOnSelection(
        selectedIndex: index,
        currentIndex: navigationShell.currentIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Warm the private local Daily Companion snapshot while the authenticated
    // shell is active. The provider publishes the same truthful local counts
    // to the Android home-screen widget when available.
    ref.watch(dailyCompanionSnapshotProvider);

    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/daily'),
        tooltip: 'Open Daily Companion',
        icon: const Icon(Icons.auto_awesome_rounded),
        label: const Text('Daily'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Tests',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Results',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
