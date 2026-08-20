import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/exam_model.dart';
import '../../core/models/result_model.dart';
import '../../features/companion/presentation/providers/daily_companion_providers.dart';
import '../../features/exams/presentation/providers/exam_providers.dart';
import '../../features/home/presentation/home_primary_action.dart';
import '../../features/results/presentation/providers/result_providers.dart';

bool shouldResetBranchOnSelection({
  required int selectedIndex,
  required int currentIndex,
}) {
  // Home is the canonical dashboard root. Re-entering it should never restore a
  // stale/offstage branch state; always rebuild from /home. Other branches keep
  // their navigation stacks, while re-tapping the active tab resets as before.
  return selectedIndex == 0 || selectedIndex == currentIndex;
}

bool shouldShowDailyAction(
  int currentIndex, {
  bool revisionIsPrimary = false,
}) =>
    currentIndex == 0 && !revisionIsPrimary;

bool isRevisionPrimaryOnHome({
  required AsyncValue<List<Exam>> activeAsync,
  required AsyncValue<List<Result>> resultsAsync,
  required int dueCount,
  required DateTime now,
}) {
  if (dueCount <= 0) return false;
  final active = activeAsync.value;
  final results = resultsAsync.value;
  if (active == null || results == null) return false;

  final action = resolveHomePrimaryAction(
    activeTests: active,
    results: results,
    availableTests: const <Exam>[],
    dueRevisionCount: dueCount,
    now: now,
  );
  return action.kind == HomePrimaryActionKind.reviseDue;
}

String dailyActionLabel({
  required int dueCount,
  required int completedToday,
  required int dailyGoal,
}) {
  if (dueCount > 0) return '$dueCount due';
  if (dailyGoal > 0 && completedToday >= dailyGoal) return 'Revision done';
  return 'Daily plan';
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
    final dailyAsync = ref.watch(dailyCompanionSnapshotProvider);
    final dailySnapshot = dailyAsync.value;
    final now = ref.watch(dailyCompanionClockProvider)();
    final dueCount = dailySnapshot?.dueItems(now).length ?? 0;
    final dailyLabel = dailySnapshot == null
        ? 'Daily plan'
        : dailyActionLabel(
            dueCount: dueCount,
            completedToday: dailySnapshot.completedToday,
            dailyGoal: dailySnapshot.settings.dailyQuestionGoal,
          );

    final onHome = navigationShell.currentIndex == 0;
    var revisionIsPrimary = false;
    if (onHome && dueCount > 0) {
      revisionIsPrimary = isRevisionPrimaryOnHome(
        activeAsync: ref.watch(inProgressExamsProvider),
        resultsAsync: ref.watch(userResultsProvider),
        dueCount: dueCount,
        now: now,
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final showDailyAction = shouldShowDailyAction(
      navigationShell.currentIndex,
      revisionIsPrimary: revisionIsPrimary,
    );

    return Scaffold(
      body: navigationShell,
      floatingActionButton: showDailyAction
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/daily'),
              tooltip: dueCount > 0
                  ? 'Open Daily Companion with $dueCount revision ${dueCount == 1 ? 'question' : 'questions'} due'
                  : 'Open Daily Companion',
              backgroundColor: scheme.tertiaryContainer,
              foregroundColor: scheme.onTertiaryContainer,
              icon: const Icon(Icons.auto_awesome_rounded, size: 20),
              label: Text(dailyLabel),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          border: Border(
            top: BorderSide(color: scheme.outlineVariant),
          ),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            indicatorColor: scheme.primaryContainer,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
                tooltip: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment_rounded),
                label: 'Tests',
                tooltip: 'Tests',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart_rounded),
                label: 'Results',
                tooltip: 'Results',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
                tooltip: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
