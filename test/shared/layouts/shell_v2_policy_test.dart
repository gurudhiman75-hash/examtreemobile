import 'package:examtree/features/store/presentation/store_screen.dart';
import 'package:examtree/shared/layouts/app_scaffold.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Shell V2 exposes preparation-first primary destinations', () {
    expect(shellDestinationLabel(0), 'Home');
    expect(shellDestinationLabel(1), 'Tests');
    expect(shellDestinationLabel(2), 'Learn');
    expect(shellDestinationLabel(3), 'Results');
    expect(shellDestinationLabel(99), 'ExamTree');
  });

  test('large layouts switch from drawer/bottom nav to collapsible rail', () {
    expect(shouldUseExpandedNavigation(839), isFalse);
    expect(shouldUseExpandedNavigation(840), isTrue);
    expect(shouldUseExpandedNavigation(1200), isTrue);
  });

  test('store query keeps test series and batches distinct', () {
    expect(storeSectionFromQuery(null), StoreSection.tests);
    expect(storeSectionFromQuery('tests'), StoreSection.tests);
    expect(storeSectionFromQuery('batches'), StoreSection.batches);
    expect(storeSectionFromQuery(' BATCHES '), StoreSection.batches);
  });
}
