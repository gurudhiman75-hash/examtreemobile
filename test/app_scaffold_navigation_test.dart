import 'package:examtree/shared/layouts/app_scaffold.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bottom navigation branch reset policy', () {
    test('Home always resets to its canonical root on re-entry', () {
      expect(
        shouldResetBranchOnSelection(selectedIndex: 0, currentIndex: 1),
        isTrue,
      );
      expect(
        shouldResetBranchOnSelection(selectedIndex: 0, currentIndex: 2),
        isTrue,
      );
      expect(
        shouldResetBranchOnSelection(selectedIndex: 0, currentIndex: 3),
        isTrue,
      );
    });

    test('other inactive tabs preserve their branch stacks', () {
      expect(
        shouldResetBranchOnSelection(selectedIndex: 1, currentIndex: 0),
        isFalse,
      );
      expect(
        shouldResetBranchOnSelection(selectedIndex: 2, currentIndex: 1),
        isFalse,
      );
      expect(
        shouldResetBranchOnSelection(selectedIndex: 3, currentIndex: 2),
        isFalse,
      );
    });

    test('re-tapping the active tab still resets that branch', () {
      for (var index = 0; index < 4; index++) {
        expect(
          shouldResetBranchOnSelection(
            selectedIndex: index,
            currentIndex: index,
          ),
          isTrue,
        );
      }
    });
  });
}
