import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/exam_model.dart';
import '../../core/models/result_model.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/companion/presentation/providers/daily_companion_providers.dart';
import '../../features/exams/presentation/providers/exam_providers.dart';
import '../../features/home/presentation/home_primary_action.dart';
import '../../features/results/presentation/providers/result_providers.dart';

bool shouldResetBranchOnSelection({
  required int selectedIndex,
  required int currentIndex,
}) {
  // Home remains the canonical dashboard root. Re-entering it should always
  // rebuild from /home. Other branches preserve their stack unless re-tapped.
  return selectedIndex == 0 || selectedIndex == currentIndex;
}

bool shouldShowDailyAction(
  int currentIndex, {
  bool revisionIsPrimary = false,
}) =>
    currentIndex == 0 && !revisionIsPrimary;

bool shouldUseExpandedNavigation(double width) => width >= 840;

String shellDestinationLabel(int index) => switch (index) {
      0 => 'Home',
      1 => 'Tests',
      2 => 'Learn',
      3 => 'Results',
      _ => 'ExamTree',
    };

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

class AppScaffold extends ConsumerStatefulWidget {
  const AppScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  bool _railExtended = true;

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: shouldResetBranchOnSelection(
        selectedIndex: index,
        currentIndex: widget.navigationShell.currentIndex,
      ),
    );
  }

  void _closeDrawerAnd(VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }

  @override
  Widget build(BuildContext context) {
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

    final currentIndex = widget.navigationShell.currentIndex;
    final onHome = currentIndex == 0;
    var revisionIsPrimary = false;
    if (onHome && dueCount > 0) {
      revisionIsPrimary = isRevisionPrimaryOnHome(
        activeAsync: ref.watch(inProgressExamsProvider),
        resultsAsync: ref.watch(userResultsProvider),
        dueCount: dueCount,
        now: now,
      );
    }

    final showDailyAction = shouldShowDailyAction(
      currentIndex,
      revisionIsPrimary: revisionIsPrimary,
    );
    final scheme = Theme.of(context).colorScheme;
    final user = ref.watch(authStateChangesProvider).value;
    final displayName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : user?.email?.split('@').first ?? 'Student';
    final initial = displayName.isEmpty ? 'S' : displayName[0].toUpperCase();
    final expandedNavigation = shouldUseExpandedNavigation(
      MediaQuery.sizeOf(context).width,
    );

    final body = expandedNavigation
        ? Row(
            children: [
              NavigationRail(
                extended: _railExtended,
                selectedIndex: currentIndex,
                onDestinationSelected: _goBranch,
                leading: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: IconButton(
                    key: const Key('shell-collapse-navigation'),
                    tooltip: _railExtended
                        ? 'Collapse navigation'
                        : 'Expand navigation',
                    onPressed: () => setState(() {
                      _railExtended = !_railExtended;
                    }),
                    icon: Icon(
                      _railExtended
                          ? Icons.menu_open_rounded
                          : Icons.menu_rounded,
                    ),
                  ),
                ),
                trailing: Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Daily Companion',
                        onPressed: () => context.push('/daily'),
                        icon: const Icon(Icons.auto_awesome_rounded),
                      ),
                      IconButton(
                        tooltip: 'Exam day',
                        onPressed: () => context.push('/exam-day'),
                        icon: const Icon(Icons.event_available_outlined),
                      ),
                      IconButton(
                        tooltip: 'Buy test series',
                        onPressed: () => context.push('/store?section=tests'),
                        icon: const Icon(Icons.shopping_bag_outlined),
                      ),
                      IconButton(
                        tooltip: 'Profile',
                        onPressed: () => context.push('/profile'),
                        icon: const Icon(Icons.person_outline_rounded),
                      ),
                    ],
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.assignment_outlined),
                    selectedIcon: Icon(Icons.assignment_rounded),
                    label: Text('Tests'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book_rounded),
                    label: Text('Learn'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart_rounded),
                    label: Text('Results'),
                  ),
                ],
              ),
              VerticalDivider(width: 1, color: scheme.outlineVariant),
              Expanded(child: widget.navigationShell),
            ],
          )
        : widget.navigationShell;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: expandedNavigation
            ? null
            : Builder(
                builder: (context) => IconButton(
                  key: const Key('shell-open-navigation'),
                  tooltip: 'Open navigation',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu_rounded),
                ),
              ),
        title: Text(onHome ? 'ExamTree' : shellDestinationLabel(currentIndex)),
        actions: [
          if (!onHome)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Semantics(
                button: true,
                label: 'Open profile',
                child: InkWell(
                  onTap: () => context.push('/profile'),
                  customBorder: const CircleBorder(),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: scheme.primaryContainer,
                    foregroundColor: scheme.onPrimaryContainer,
                    child: Text(
                      initial,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      drawer: expandedNavigation
          ? null
          : NavigationDrawer(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                if (index <= 3) {
                  _closeDrawerAnd(() => _goBranch(index));
                  return;
                }
                switch (index) {
                  case 4:
                    _closeDrawerAnd(() => context.push('/daily'));
                  case 5:
                    _closeDrawerAnd(() => context.push('/exam-day'));
                  case 6:
                    _closeDrawerAnd(
                      () => context.push('/store?section=tests'),
                    );
                  case 7:
                    _closeDrawerAnd(
                      () => context.push('/store?section=batches'),
                    );
                  case 8:
                    _closeDrawerAnd(() => context.push('/profile'));
                }
              },
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: scheme.primaryContainer,
                        foregroundColor: scheme.onPrimaryContainer,
                        child: Text(
                          initial,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            if ((user?.email ?? '').isNotEmpty)
                              Text(
                                user!.email!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('Home'),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment_rounded),
                  label: Text('Tests'),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: Text('Learn'),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart_rounded),
                  label: Text('Results'),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(28, 18, 16, 8),
                  child: Text('PREPARATION'),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.auto_awesome_outlined),
                  selectedIcon: Icon(Icons.auto_awesome_rounded),
                  label: Text('Daily Companion'),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.event_available_outlined),
                  selectedIcon: Icon(Icons.event_available_rounded),
                  label: Text('Exam day'),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(28, 18, 16, 8),
                  child: Text('STORE'),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.shopping_bag_outlined),
                  selectedIcon: Icon(Icons.shopping_bag_rounded),
                  label: Text('Buy test series'),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.school_outlined),
                  selectedIcon: Icon(Icons.school_rounded),
                  label: Text('Buy batches'),
                ),
                const Divider(),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text('Profile & account'),
                ),
              ],
            ),
      body: body,
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
      bottomNavigationBar: expandedNavigation
          ? null
          : DecoratedBox(
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
                  selectedIndex: currentIndex,
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
                      icon: Icon(Icons.menu_book_outlined),
                      selectedIcon: Icon(Icons.menu_book_rounded),
                      label: 'Learn',
                      tooltip: 'Learn',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.bar_chart_outlined),
                      selectedIcon: Icon(Icons.bar_chart_rounded),
                      label: 'Results',
                      tooltip: 'Results',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
