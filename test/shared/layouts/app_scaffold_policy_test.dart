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

  test('Daily action is extended only on Home', () {
    expect(shouldUseExtendedDailyAction(0), isTrue);
    expect(shouldUseExtendedDailyAction(1), isFalse);
    expect(shouldUseExtendedDailyAction(2), isFalse);
    expect(shouldUseExtendedDailyAction(3), isFalse);
  });
}
