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
      description: description ?? '$title preparation paper',
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
      chipTheme: baseTheme.chipTheme.copyWith(
        labelStyle: pinnedTextTheme.labelMedium,
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

  Future<void> pumpCatalogue(
    WidgetTester tester, {
    required List<Exam> available,
    required List<Exam> inProgress,
  }) async {
    await configurePhone(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableExamsProvider.overrideWith((ref) async => available),
          inProgressExamsProvider.overrideWith((ref) async => inProgress),
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
            child: Scaffold(
              appBar: AppBar(title: const Text('Tests')),
              body: const ExamsScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('render populated Tests catalogue', (tester) async {
    await pumpCatalogue(
      tester,
      inProgress: [
        exam(
          id: 'active-1',
          title: 'SSC CGL full-length mock',
          category: 'SSC',
        ),
        exam(
          id: 'active-2',
          title: 'Quant sectional speed test',
          category: 'SSC',
        ),
      ],
      available: [
        exam(
          id: 'available-1',
          title: 'Reasoning mixed practice',
          category: 'SSC',
        ),
        exam(
          id: 'available-2',
          title: 'Railway NTPC mock',
          category: 'Railways',
        ),
        exam(
          id: 'available-3',
          title: 'Banking prelims mock',
          category: 'Banking',
          status: 'paid',
          difficulty: 'Hard',
        ),
      ],
    );

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/tests_populated_390x844.png'),
    );
  });

  testWidgets('render lower Tests catalogue', (tester) async {
    await pumpCatalogue(
      tester,
      inProgress: [
        exam(
          id: 'active-1',
          title: 'SSC CGL full-length mock',
          category: 'SSC',
        ),
      ],
      available: [
        exam(
          id: 'available-1',
          title: 'Reasoning mixed practice',
          category: 'SSC',
        ),
        exam(
          id: 'available-2',
          title: 'Railway NTPC mock',
          category: 'Railways',
        ),
        exam(
          id: 'available-3',
          title: 'Banking prelims mock',
          category: 'Banking',
          status: 'paid',
          difficulty: 'Hard',
        ),
      ],
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -480));
    await tester.pump(const Duration(milliseconds: 300));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/tests_lower_390x844.png'),
    );
  });

  testWidgets('render empty Tests catalogue', (tester) async {
    await pumpCatalogue(
      tester,
      inProgress: const [],
      available: const [],
    );

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
