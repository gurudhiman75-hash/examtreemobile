import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/store/domain/store_product.dart';
import 'package:examtree/features/store/presentation/providers/store_providers.dart';
import 'package:examtree/features/store/presentation/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  StoreProduct product({
    String id = 'series-1',
    String title = 'SSC CGL Complete Test Series',
    String description = 'Published full-length and sectional tests for SSC CGL preparation.',
    int listPriceMinor = 99900,
    int salePriceMinor = 49900,
    int? validityDays = 90,
    int testCount = 25,
  }) {
    return StoreProduct(
      id: id,
      code: id.toUpperCase(),
      title: title,
      description: description,
      currency: 'INR',
      listPriceMinor: listPriceMinor,
      salePriceMinor: salePriceMinor,
      validityDays: validityDays,
      saleStartAt: null,
      saleEndAt: null,
      testCount: testCount,
    );
  }

  Future<void> pumpStore(
    WidgetTester tester, {
    required List<StoreProduct> products,
    StoreSection initialSection = StoreSection.tests,
    double textScale = 1,
  }) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storeProductsProvider.overrideWith((ref) async => products),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              textScaler: TextScaler.linear(textScale),
              disableAnimations: true,
            ),
            child: StoreScreen(initialSection: initialSection),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('store renders only canonical product facts and prices', (tester) async {
    await pumpStore(tester, products: [product()]);

    expect(find.text('Preparation products'), findsOneWidget);
    expect(find.byKey(const Key('store-test-series')), findsOneWidget);
    expect(find.text('SSC CGL Complete Test Series'), findsOneWidget);
    expect(find.text('25 tests'), findsOneWidget);
    expect(find.text('90 days access'), findsOneWidget);
    expect(find.text('₹499'), findsOneWidget);
    expect(find.text('₹999'), findsOneWidget);
    expect(find.text('View tests'), findsOneWidget);
    expect(find.textContaining('Buy now'), findsNothing);
    expect(find.textContaining('Purchase'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('batches remain truthful until real products exist', (tester) async {
    await pumpStore(
      tester,
      products: [product()],
      initialSection: StoreSection.batches,
    );

    expect(find.byKey(const Key('store-batches')), findsOneWidget);
    expect(find.text('Batches are not published yet'), findsOneWidget);
    expect(find.text('SSC CGL Complete Test Series'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty catalogue directs learner back to available tests', (tester) async {
    await pumpStore(tester, products: const []);

    expect(find.text('No test products on sale'), findsOneWidget);
    expect(find.text('Browse tests'), findsOneWidget);
    expect(find.textContaining('discount'), findsNothing);
    expect(find.textContaining('limited time'), findsNothing);
  });

  testWidgets('store remains usable at 200 percent text scaling', (tester) async {
    await pumpStore(
      tester,
      products: [
        product(
          title: 'SSC Combined Graduate Level complete preparation test series',
          description:
              'A longer canonical catalogue description used to verify that Store cards stack safely with accessibility text.',
          testCount: 100,
          validityDays: 365,
        ),
      ],
      textScale: 2,
    );

    expect(tester.takeException(), isNull);

    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -520));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('store-test-series')), findsOneWidget);

    await tester.drag(scrollable, const Offset(0, -760));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.textContaining('Mobile checkout is not connected yet'),
      findsOneWidget,
    );
  });
}
