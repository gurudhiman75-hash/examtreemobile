import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/exams/domain/exam_catalog.dart';
import 'package:examtree/features/exams/presentation/exams_screen.dart';
import 'package:examtree/features/exams/presentation/providers/exam_catalog_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ExamCatalogSnapshot snapshot({
    bool empty = false,
  }) {
    if (empty) {
      return const ExamCatalogSnapshot(
        categories: [],
        exams: [],
        series: [],
      );
    }
    return const ExamCatalogSnapshot(
      categories: [
        ExamCatalogCategory(
          code: 'ssc',
          name: 'SSC',
          description: 'Staff Selection Commission examinations',
          iconUrl: '',
          colorHex: '#2563eb',
          testCount: 12,
        ),
        ExamCatalogCategory(
          code: 'railway',
          name: 'Railway',
          description: 'Railway recruitment examinations',
          iconUrl: '',
          colorHex: '#2563eb',
          testCount: 8,
        ),
        ExamCatalogCategory(
          code: 'banking',
          name: 'Banking',
          description: 'Banking examinations',
          iconUrl: '',
          colorHex: '#2563eb',
          testCount: 7,
        ),
      ],
      exams: [
        ExamCatalogExam(
          code: 'ssc-cgl',
          familyCode: 'ssc',
          familyName: 'SSC',
          name: 'SSC CGL',
          description: 'Combined Graduate Level Examination',
          iconUrl: '',
          languages: ['en', 'hi'],
          seriesCount: 1,
          testCount: 12,
          primarySeriesId: 'series-cgl',
        ),
        ExamCatalogExam(
          code: 'rrb-ntpc',
          familyCode: 'railway',
          familyName: 'Railway',
          name: 'RRB NTPC',
          description: 'Railway NTPC Examination',
          iconUrl: '',
          languages: ['en', 'hi'],
          seriesCount: 1,
          testCount: 8,
          primarySeriesId: 'series-rrb',
        ),
        ExamCatalogExam(
          code: 'ibps-po',
          familyCode: 'banking',
          familyName: 'Banking',
          name: 'IBPS PO',
          description: 'Probationary Officer Examination',
          iconUrl: '',
          languages: ['en', 'hi'],
          seriesCount: 1,
          testCount: 7,
          primarySeriesId: 'series-ibps',
        ),
      ],
      series: [],
    );
  }

  Future<void> pumpCategories(
    WidgetTester tester, {
    required ExamCatalogSnapshot catalog,
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
          examCatalogProvider.overrideWith((ref) async => catalog),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(
                size: const Size(390, 844),
                textScaler: TextScaler.linear(textScale),
                disableAnimations: true,
              ),
              child: const ExamsScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('exams tab presents master categories before individual exams',
      (tester) async {
    await pumpCategories(tester, catalog: snapshot());

    expect(find.textContaining('Your Preparation'), findsOneWidget);
    expect(find.byKey(const Key('exam-category-catalogue')), findsOneWidget);
    expect(find.byKey(const Key('exam-category-search')), findsOneWidget);
    expect(find.byKey(const Key('exam-category-ssc')), findsOneWidget);
    expect(find.byKey(const Key('exam-category-railway')), findsOneWidget);
    expect(find.byKey(const Key('exam-category-banking')), findsOneWidget);
    expect(find.byKey(const Key('popular-exam-ssc-cgl')), findsOneWidget);
  });

  testWidgets('category search filters only master categories', (tester) async {
    await pumpCategories(tester, catalog: snapshot());

    await tester.enterText(
      find.byKey(const Key('exam-category-search')),
      'rail',
    );
    await tester.pump();

    expect(find.byKey(const Key('exam-category-railway')), findsOneWidget);
    expect(find.byKey(const Key('exam-category-ssc')), findsNothing);
  });

  testWidgets('empty category catalogue remains truthful', (tester) async {
    await pumpCategories(tester, catalog: snapshot(empty: true));

    expect(find.text('No exam categories are published yet.'), findsOneWidget);
    expect(find.textContaining('popular'), findsNothing);
    expect(find.textContaining('recommended for you'), findsNothing);
  });

  testWidgets('category catalogue remains usable at 200 percent text scaling',
      (tester) async {
    await pumpCategories(
      tester,
      catalog: snapshot(),
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('exam-category-search')), findsOneWidget);
  });

  test('canonical category mapping keeps exams under their family code', () {
    final catalog = snapshot();
    final ssc = catalog.examsForCategory('ssc');
    expect(ssc.map((exam) => exam.name), contains('SSC CGL'));
    expect(ssc.map((exam) => exam.name), isNot(contains('IBPS PO')));
    expect(catalog.findExam('ssc-cgl')?.familyName, 'SSC');
  });
}
