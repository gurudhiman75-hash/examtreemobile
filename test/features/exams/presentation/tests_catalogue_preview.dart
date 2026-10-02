import 'dart:io';

import 'package:examtree/core/models/exam_model.dart';
import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/exams/domain/exam_catalog.dart';
import 'package:examtree/features/exams/presentation/exam_details_screen.dart';
import 'package:examtree/features/exams/presentation/exams_screen.dart';
import 'package:examtree/features/exams/presentation/providers/exam_catalog_providers.dart';
import 'package:examtree/features/exams/presentation/providers/exam_providers.dart';
import 'package:examtree/features/home/presentation/mobile_test_series_detail_screen.dart';
import 'package:examtree/features/results/presentation/providers/result_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var fontsLoaded = false;
  const phoneSize = Size(390, 844);
  final now = DateTime(2026, 10, 2, 12);

  Future<void> loadFont(String family, String path) async {
    final bytes = await File(path).readAsBytes();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  }

  Future<void> loadFonts() async {
    if (fontsLoaded) return;
    await loadFont(
      'Roboto',
      'test/features/exams/presentation/previews/Roboto-Regular.ttf',
    );
    await loadFont(
      'MaterialIcons',
      'test/features/exams/presentation/previews/MaterialIcons-Regular.otf',
    );
    fontsLoaded = true;
  }

  ThemeData previewTheme() {
    final baseTheme = AppTheme.lightTheme;
    final pinnedTextTheme = baseTheme.textTheme.apply(fontFamily: 'Roboto');
    return baseTheme.copyWith(
      textTheme: pinnedTextTheme,
      appBarTheme: baseTheme.appBarTheme.copyWith(
        titleTextStyle: baseTheme.appBarTheme.titleTextStyle?.copyWith(
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Future<void> configurePhone(WidgetTester tester) async {
    await tester.runAsync(loadFonts);
    tester.view
      ..physicalSize = phoneSize
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  final seriesDetail = <String, dynamic>{
    'series': <String, dynamic>{
      'id': 'series-cgl-1',
      'name': 'SSC CGL Complete Test Series',
      'description':
          'Full-length mocks and structured practice for SSC CGL preparation.',
      'examName': 'SSC CGL',
      'examFamilyName': 'SSC',
      'progressionMode': 'sequential',
    },
    'eligibility': <String, dynamic>{
      'available': true,
      'progressPercent': 25,
      'completedCount': 1,
      'requiredCount': 4,
      'totalCount': 4,
      'nextTestId': 'test-2',
      'members': <Map<String, dynamic>>[
        <String, dynamic>{
          'testId': 'test-1',
          'title': 'SSC CGL Full Length Mock 1',
          'description': 'Tier I full-length practice paper',
          'questionCount': 100,
          'durationSeconds': 3600,
          'totalMarks': 200,
          'isRequired': true,
          'completed': true,
          'unlocked': true,
          'attemptCount': 1,
          'bestScore': 148,
        },
        <String, dynamic>{
          'testId': 'test-2',
          'title': 'SSC CGL Full Length Mock 2',
          'description': 'Balanced practice across all major sections',
          'questionCount': 100,
          'durationSeconds': 3600,
          'totalMarks': 200,
          'isRequired': true,
          'completed': false,
          'unlocked': true,
          'attemptCount': 0,
        },
        <String, dynamic>{
          'testId': 'test-3',
          'title': 'SSC CGL Full Length Mock 3',
          'description': 'Advanced mixed-difficulty practice',
          'questionCount': 100,
          'durationSeconds': 3600,
          'totalMarks': 200,
          'isRequired': true,
          'completed': false,
          'unlocked': false,
          'lockReason': 'Complete the previous required test to unlock this one.',
          'attemptCount': 0,
        },
        <String, dynamic>{
          'testId': 'test-4',
          'title': 'SSC CGL Final Revision Mock',
          'description': 'Final timed revision before exam day',
          'questionCount': 100,
          'durationSeconds': 3600,
          'totalMarks': 200,
          'isRequired': true,
          'completed': false,
          'unlocked': false,
          'lockReason': 'Complete the previous required test to unlock this one.',
          'attemptCount': 0,
        },
      ],
    },
  };

  final snapshot = ExamCatalogSnapshot(
    categories: const [
      ExamCatalogCategory(
        code: 'ssc',
        name: 'SSC',
        description: 'Staff Selection Commission examinations',
        iconUrl: '',
        colorHex: '#2563eb',
        testCount: 68,
      ),
      ExamCatalogCategory(
        code: 'banking',
        name: 'Banking',
        description: 'IBPS, SBI and other banking examinations',
        iconUrl: '',
        colorHex: '#2563eb',
        testCount: 42,
      ),
      ExamCatalogCategory(
        code: 'insurance',
        name: 'Insurance',
        description: 'Insurance sector examinations',
        iconUrl: '',
        colorHex: '#2563eb',
        testCount: 18,
      ),
      ExamCatalogCategory(
        code: 'punjab',
        name: 'Punjab State',
        description: 'Punjab government recruitment examinations',
        iconUrl: '',
        colorHex: '#2563eb',
        testCount: 35,
      ),
      ExamCatalogCategory(
        code: 'railway',
        name: 'Railway',
        description: 'Railway recruitment examinations',
        iconUrl: '',
        colorHex: '#2563eb',
        testCount: 29,
      ),
      ExamCatalogCategory(
        code: 'teaching',
        name: 'Teaching',
        description: 'Teaching eligibility and recruitment examinations',
        iconUrl: '',
        colorHex: '#2563eb',
        testCount: 16,
      ),
    ],
    exams: const [
      ExamCatalogExam(
        code: 'ssc-cgl',
        familyCode: 'ssc',
        familyName: 'SSC',
        name: 'SSC CGL',
        description: 'Combined Graduate Level Examination',
        iconUrl: '',
        languages: ['en', 'hi'],
        seriesCount: 2,
        testCount: 24,
        primarySeriesId: null,
      ),
      ExamCatalogExam(
        code: 'ssc-chsl',
        familyCode: 'ssc',
        familyName: 'SSC',
        name: 'SSC CHSL',
        description: 'Combined Higher Secondary Level Examination',
        iconUrl: '',
        languages: ['en', 'hi'],
        seriesCount: 1,
        testCount: 18,
        primarySeriesId: 'series-chsl',
      ),
      ExamCatalogExam(
        code: 'ssc-cpo',
        familyCode: 'ssc',
        familyName: 'SSC',
        name: 'SSC CPO',
        description: 'Central Police Organisation Examination',
        iconUrl: '',
        languages: ['en', 'hi'],
        seriesCount: 1,
        testCount: 14,
        primarySeriesId: 'series-cpo',
      ),
      ExamCatalogExam(
        code: 'ssc-mts',
        familyCode: 'ssc',
        familyName: 'SSC',
        name: 'SSC MTS',
        description: 'Multi Tasking Staff Examination',
        iconUrl: '',
        languages: ['en', 'hi'],
        seriesCount: 1,
        testCount: 12,
        primarySeriesId: 'series-mts',
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
        testCount: 20,
        primarySeriesId: 'series-ibps',
      ),
      ExamCatalogExam(
        code: 'psssb-clerk',
        familyCode: 'punjab',
        familyName: 'Punjab State',
        name: 'PSSSB Clerk',
        description: 'Punjab Subordinate Services Selection Board Clerk',
        iconUrl: '',
        languages: ['en', 'pa'],
        seriesCount: 1,
        testCount: 15,
        primarySeriesId: 'series-psssb',
      ),
    ],
    series: const [
      ExamSeriesSummary(
        id: 'series-cgl-1',
        code: 'ssc-cgl-complete',
        name: 'SSC CGL Complete Test Series',
        description: 'Full mocks, sectional tests and exam-focused practice.',
        examCode: 'ssc-cgl',
        examName: 'SSC CGL',
        examFamilyCode: 'ssc',
        examFamilyName: 'SSC',
        testCount: 16,
        liveTestCount: 16,
        fullLengthTestCount: 10,
        durationSeconds: 57600,
        questionCount: 1600,
        attemptCount: 1200,
      ),
      ExamSeriesSummary(
        id: 'series-cgl-2',
        code: 'ssc-cgl-pyq',
        name: 'SSC CGL Previous Year Papers',
        description: 'Recent papers arranged for timed practice.',
        examCode: 'ssc-cgl',
        examName: 'SSC CGL',
        examFamilyCode: 'ssc',
        examFamilyName: 'SSC',
        testCount: 8,
        liveTestCount: 8,
        fullLengthTestCount: 8,
        durationSeconds: 28800,
        questionCount: 800,
        attemptCount: 900,
      ),
    ],
  );

  Future<void> pump(
    WidgetTester tester, {
    required Widget child,
    ExamCatalogSnapshot? catalog,
    Exam? details,
    Map<String, dynamic>? seriesDetailBody,
  }) async {
    await configurePhone(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (catalog != null)
            examCatalogProvider.overrideWith((ref) async => catalog),
          if (details != null)
            examDetailsProvider.overrideWith((ref, id) async => details),
          if (details != null)
            completedAttemptCountProvider.overrideWith((ref, id) async => 1),
          if (seriesDetailBody != null)
            mobileTestSeriesDetailProvider.overrideWith(
              (ref, id) async => seriesDetailBody,
            ),
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
            child: child,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('render approved exam categories', (tester) async {
    await pump(
      tester,
      catalog: snapshot,
      child: Scaffold(
        appBar: AppBar(title: const Text('Exams')),
        body: const ExamsScreen(),
      ),
    );

    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('previews/tests_categories_390x844.png'),
    );
  });

  testWidgets('render SSC exam list', (tester) async {
    await pump(
      tester,
      catalog: snapshot,
      child: const ExamCategoryScreen(categoryCode: 'ssc'),
    );

    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('previews/tests_ssc_list_390x844.png'),
    );
  });

  testWidgets('render SSC CGL series list', (tester) async {
    await pump(
      tester,
      catalog: snapshot,
      child: const ExamSeriesScreen(examCode: 'ssc-cgl'),
    );

    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('previews/tests_ssc_cgl_series_390x844.png'),
    );
  });

  testWidgets('render empty exam categories', (tester) async {
    await pump(
      tester,
      catalog: const ExamCatalogSnapshot(
        categories: [],
        exams: [],
        series: [],
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Exams')),
        body: const ExamsScreen(),
      ),
    );

    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('previews/tests_empty_390x844.png'),
    );
  });

  testWidgets('render premium test series detail', (tester) async {
    await pump(
      tester,
      seriesDetailBody: seriesDetail,
      child: const MobileTestSeriesDetailScreen(
        seriesId: 'series-cgl-1',
      ),
    );

    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('previews/tests_series_detail_390x844.png'),
    );
  });

  testWidgets('render refreshed Exam Details', (tester) async {
    final details = Exam(
      id: 'details-1',
      title: 'SSC CGL Full Length Mock 1',
      description:
          'A full-length practice paper built around the current SSC CGL pattern.',
      durationInSeconds: 3600,
      totalQuestions: 100,
      totalMarks: 200,
      maxAttempts: 3,
      negativeMarking: 0.5,
      difficulty: 'Medium',
      status: 'published',
      category: 'SSC',
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now,
    );
    await pump(
      tester,
      child: const ExamDetailsScreen(examId: 'details-1'),
      details: details,
    );

    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('previews/tests_details_390x844.png'),
    );
  });
}
