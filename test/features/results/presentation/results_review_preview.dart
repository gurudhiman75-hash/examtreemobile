import 'dart:io';

import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/results/presentation/providers/result_providers.dart';
import 'package:examtree/features/results/presentation/results_screen.dart';
import 'package:examtree/features/results/presentation/review_retry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var fontsLoaded = false;
  const phoneSize = Size(390, 844);
  final now = DateTime(2026, 8, 20, 11, 15);

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

  ResultQuestionReview question({
    required int id,
    required String text,
    required int? selected,
    required int correct,
    bool flagged = false,
    int timeTakenSeconds = 52,
  }) {
    const options = [
      'Option A',
      'Option B',
      'Option C',
      'Option D',
    ];
    return ResultQuestionReview(
      questionId: id,
      questionVersionId: 'version-$id',
      testQuestionId: 'test-question-$id',
      testSectionId: 'section-${id <= 2 ? 1 : 2}',
      section: id <= 2 ? 'Quantitative Aptitude' : 'Reasoning',
      text: text,
      options: options,
      optionKeys: const ['A', 'B', 'C', 'D'],
      selected: selected,
      selectedOptionKey:
          selected == null ? null : String.fromCharCode(65 + selected),
      correct: correct,
      correctOptionKey: String.fromCharCode(65 + correct),
      timeTakenSeconds: timeTakenSeconds,
      flagged: flagged,
      explanation:
          'Work from the information given in the question, eliminate the incompatible choices, and verify the final option before moving on.',
    );
  }

  Result detailedResult({
    String id = '1',
    String name = 'SSC CGL diagnostic mock',
    String category = 'SSC',
    double score = 72,
    double accuracy = 78,
    int daysAgo = 0,
  }) {
    final questions = [
      question(
        id: 1,
        text: 'A quantity increases by 20% and then decreases by 10%. What is the net percentage change?',
        selected: 1,
        correct: 2,
        flagged: true,
        timeTakenSeconds: 83,
      ),
      question(
        id: 2,
        text: 'Which option completes the number pattern shown in the question?',
        selected: null,
        correct: 3,
        timeTakenSeconds: 61,
      ),
      question(
        id: 3,
        text: 'Choose the conclusion that follows from the given statements.',
        selected: 0,
        correct: 0,
        timeTakenSeconds: 38,
      ),
    ];
    return Result(
      id: 'attempt-$id',
      attemptId: 'attempt-$id',
      userId: 'student-1',
      examId: 'exam-$id',
      score: score,
      maxScore: 100,
      accuracy: accuracy,
      correctCount: 72,
      incorrectCount: 18,
      skippedCount: 10,
      calculatedAt: now.subtract(Duration(days: daysAgo)),
      testName: name,
      category: category,
      percentageScore: score,
      rawScore: score,
      totalQuestions: 100,
      questionReview: questions,
    );
  }

  List<Result> history() => [
        detailedResult(),
        detailedResult(
          id: '2',
          name: 'Railway NTPC full mock',
          category: 'Railways',
          score: 81,
          accuracy: 86,
          daysAgo: 2,
        ),
        detailedResult(
          id: '3',
          name: 'Quantitative Aptitude sectional test',
          category: 'SSC',
          score: 68,
          accuracy: 74,
          daysAgo: 4,
        ),
      ];

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

  testWidgets('render populated Results initial viewport', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userResultsProvider.overrideWith((ref) async => history()),
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
            child: ResultsScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/results_populated_390x844.png'),
    );
  });

  testWidgets('render lower Results history viewport', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userResultsProvider.overrideWith((ref) async => history()),
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
            child: ResultsScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -470));
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/results_lower_390x844.png'),
    );
  });

  testWidgets('render Answer Review with learning handoff', (tester) async {
    await configurePhone(tester);
    final result = detailedResult();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resultProvider('attempt-1').overrideWith((ref) async => result),
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
            child: ReviewRetryScreen(resultId: 'attempt-1'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/review_question_390x844.png'),
    );
  });
}
