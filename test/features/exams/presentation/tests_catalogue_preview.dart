import 'dart:io';

import 'package:examtree/core/models/exam_model.dart';
import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/exams/presentation/exam_details_screen.dart';
import 'package:examtree/features/exams/presentation/exams_screen.dart';
import 'package:examtree/features/exams/presentation/providers/exam_providers.dart';
import 'package:examtree/features/results/presentation/providers/result_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var fontsLoaded = false;
  const phoneSize = Size(390, 844);
  final now = DateTime(2026, 8, 18, 12);

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

  Exam exam({
    required String id,
    required String title,
    required String category,
    String status = 'published',
    String difficulty = 'Medium',
    String? description,
    int maxAttempts = 5,
  }) {
    return Exam(
      id: id,
      title: title,
      description: description ?? title + ' preparation paper',
      durationInSeconds: 3600,
      totalQuestions: 100,
      totalMarks: 200,
      maxAttempts: maxAttempts,
      negativeMarking: 0.5,
      difficulty: difficulty,
      status: status,
      category: category,
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now,
    );
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

  Future<void> pumpCategories(
    WidgetTester tester, {
    required List<Exam> available,
  }) async {
    await configurePhone(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableExamsProvider.overrideWith((ref) async => available),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: previewTheme(),
          home: const MediaQuery(
            data: MediaQueryData(
              size: phoneSize,
              devicePixelRatio: 1,
              disableAnimations: true,
            ),
            child: Scaffold(
              appBar: AppBar(title: Text('Exams')),
              body: ExamsScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  Future<void> pumpFamily(
    WidgetTester tester, {
    required List<Exam> available,
    required ExamFamily family,
  }) async {
    await configurePhone(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableExamsProvider.overrideWith((ref) async => available),
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
            child: ExamCategoryScreen(family: family),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  Future<void> pumpDetails(WidgetTester tester) async {
    await configurePhone(tester);
    final details = exam(
      id: 'details-1',
      title: 'SSC CGL Full Length Mock 1',
      category: 'SSC',
      description:
          'A full-length practice paper built around the current SSC CGL pattern.',
      maxAttempts: 3,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          examDetailsProvider.overrideWith((ref, id) async => details),
          completedAttemptCountProvider.overrideWith((ref, id) async => 1),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: previewTheme(),
          home: const MediaQuery(
            data: MediaQueryData(
              size: phoneSize,
              devicePixelRatio: 1,
              disableAnimations: true,
            ),
            child: ExamDetailsScreen(examId: 'details-1'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  final catalogue = <Exam>[
    exam(id: 'ssc-1', title: 'SSC CGL', category: 'SSC'),
    exam(id: 'ssc-2', title: 'SSC CHSL', category: 'SSC'),
    exam(id: 'ssc-3', title: 'SSC CPO', category: 'SSC', status: 'paid'),
    exam(id: 'rail-1', title: 'RRB NTPC', category: 'Railways'),
    exam(id: 'bank-1', title: 'IBPS PO', category: 'Banking', status: 'paid'),
    exam(id: 'punjab-1', title: 'PSSSB Clerk', category: 'Punjab Government'),
    exam(id: 'insurance-1', title: 'LIC AAO', category: 'Insurance'),
  ];

  testWidgets('render approved exam categories', (tester) async {
    await pumpCategories(tester, available: catalogue);

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/tests_categories_390x844.png'),
    );
  });

  testWidgets('render SSC exam list', (tester) async {
    await pumpFamily(
      tester,
      available: catalogue,
      family: ExamFamily.ssc,
    );

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/tests_ssc_list_390x844.png'),
    );
  });

  testWidgets('render empty exam categories', (tester) async {
    await pumpCategories(tester, available: const []);

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/tests_empty_390x844.png'),
    );
  });

  testWidgets('render refreshed Exam Details', (tester) async {
    await pumpDetails(tester);

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/tests_details_390x844.png'),
    );
  });
}
