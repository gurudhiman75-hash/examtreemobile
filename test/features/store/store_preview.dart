import 'dart:io';
import 'dart:typed_data';

import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/store/domain/store_product.dart';
import 'package:examtree/features/store/presentation/providers/store_providers.dart';
import 'package:examtree/features/store/presentation/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var fontsLoaded = false;
  const phoneSize = Size(390, 844);

  Future<void> loadFont(String family, String path) async {
    final bytes = await File(path).readAsBytes();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  }

  Future<void> loadFonts() async {
    if (fontsLoaded) return;
    await loadFont('Roboto', 'test/features/store/previews/Roboto-Regular.ttf');
    await loadFont(
      'MaterialIcons',
      'test/features/store/previews/MaterialIcons-Regular.otf',
    );
    fontsLoaded = true;
  }

  ThemeData previewTheme() {
    final base = AppTheme.lightTheme;
    final textTheme = base.textTheme.apply(fontFamily: 'Roboto');
    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  List<StoreProduct> products() => const [
        StoreProduct(
          id: 'ssc-cgl-series',
          code: 'SSC_CGL_SERIES',
          title: 'SSC CGL Complete Test Series',
          description:
              'Full-length mocks and sectional practice from the published ExamTree catalogue.',
          currency: 'INR',
          listPriceMinor: 99900,
          salePriceMinor: 49900,
          validityDays: 90,
          saleStartAt: null,
          saleEndAt: null,
          testCount: 25,
        ),
        StoreProduct(
          id: 'railway-series',
          code: 'RAILWAY_NTPC_SERIES',
          title: 'Railway NTPC Practice Series',
          description:
              'Published Railway NTPC mocks with structured practice coverage.',
          currency: 'INR',
          listPriceMinor: 69900,
          salePriceMinor: 69900,
          validityDays: 60,
          saleStartAt: null,
          saleEndAt: null,
          testCount: 18,
        ),
      ];

  Future<void> configurePhone(WidgetTester tester) async {
    await tester.runAsync(loadFonts);
    tester.view
      ..physicalSize = phoneSize
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget app({
    required List<StoreProduct> items,
    StoreSection initialSection = StoreSection.tests,
  }) => ProviderScope(
        overrides: [
          storeProductsProvider.overrideWith((ref) async => items),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: previewTheme(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: phoneSize,
              devicePixelRatio: 1,
              disableAnimations: true,
            ),
            child: StoreScreen(initialSection: initialSection),
          ),
        ),
      );

  testWidgets('render populated Store initial viewport', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(app(items: products()));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/store_populated_390x844.png'),
    );
  });

  testWidgets('render populated Store lower viewport', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(app(items: products()));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.drag(find.byType(ListView), const Offset(0, -680));
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/store_lower_390x844.png'),
    );
  });

  testWidgets('render Store batches state', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(
      app(items: products(), initialSection: StoreSection.batches),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/store_batches_390x844.png'),
    );
  });

  testWidgets('render empty Store catalogue', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(app(items: const []));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/store_empty_390x844.png'),
    );
  });
}
