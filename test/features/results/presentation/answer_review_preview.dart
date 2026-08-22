import 'dart:io';

import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/results/presentation/providers/result_providers.dart';
import 'package:examtree/features/results/presentation/review_screen.dart';
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
    await loadFont(
      'Roboto',
      'test/features/results/presentation/previews/Roboto-Regular.ttf',
    );
    await loadFont(
      'MaterialIcons',
      'test/features/results/presentation/previews/MaterialIcons-Regular.otf',
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
      chipTheme: base.chipTheme.copyWith(labelStyle: textTheme.labelMedium),
    );
  }

  Result result() {
    final question = ResultQuestionReview(
      questionId: 1,
      questionVersionId: 'version-1',
      testQuestionId: 'test-question-1',
      testSectionId: 'section-1',
      section: 'Quantitative Aptitude',
      text:
          'A quantity increases by 20% and then decreases by 10%. What is the net percentage change?',
      options: const [
        '8% decrease',
        '10% increase',
        '8% increase',
        '12% increase',
      ],
      optionKeys: const ['A', 'B', 'C', 'D'],
      selected: 1,
      selectedOptionKey: 'B',
      correct: 2,
      correctOptionKey: 'C',
      timeTakenSeconds: 83,
      flagged: true,
      explanation:
          'Take the original value as 100. After a 20% increase it becomes 120; decreasing 120 by 10% gives 108. The net change is therefore an 8% increase.',
    );
    return Result(
      id: 'attempt-review',
      attemptId: 'attempt-review',
      userId: 'student-1',
      examId: 'exam-1',
      score: 72,
      maxScore: 100,
      accuracy: 78,
      correctCount: 72,
      incorrectCount: 18,
      skippedCount: 10,
      calculatedAt: DateTime(2026, 8, 22),
      testName: 'SSC CGL diagnostic mock',
      category: 'SSC',
      percentageScore: 72,
      rawScore: 72,
      totalQuestions: 100,
      questionReview: [question],
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

  testWidgets('render lower Answer Review learning surface', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resultProvider('attempt-review').overrideWith((ref) async => result()),
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
            child: ReviewScreen(resultId: 'attempt-review'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await tester.drag(
      find.byKey(const Key('review-question-scroll')),
      const Offset(0, -420),
    );
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/review_lower_v3_390x844.png'),
    );
  });
}
