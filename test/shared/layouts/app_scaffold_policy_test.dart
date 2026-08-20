import 'package:examtree/shared/layouts/app_scaffold.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home always resets while inactive non-Home branches preserve stack', () {
    expect(
      shouldResetBranchOnSelection(selectedIndex: 0, currentIndex: 2),
      isTrue,
    );
    expect(
      shouldResetBranchOnSelection(selectedIndex: 1, currentIndex: 2),
      isFalse,
    );
    expect(
      shouldResetBranchOnSelection(selectedIndex: 2, currentIndex: 2),
      isTrue,
    );
  });

  test('Daily Companion action appears only on Home', () {
    expect(shouldShowDailyAction(0), isTrue);
    expect(shouldShowDailyAction(1), isFalse);
    expect(shouldShowDailyAction(2), isFalse);
    expect(shouldShowDailyAction(3), isFalse);
  });

  test('Daily Companion action reflects real revision state', () {
    expect(
      dailyActionLabel(dueCount: 4, completedToday: 3, dailyGoal: 10),
      '4 due',
    );
    expect(
      dailyActionLabel(dueCount: 0, completedToday: 10, dailyGoal: 10),
      'Revision done',
    );
    expect(
      dailyActionLabel(dueCount: 0, completedToday: 3, dailyGoal: 10),
      'Daily plan',
    );
  });
}
