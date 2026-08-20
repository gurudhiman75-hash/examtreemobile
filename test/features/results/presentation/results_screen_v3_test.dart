import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/results/presentation/providers/result_providers.dart';
import 'package:examtree/features/results/presentation/results_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 18, 12);

  ResultQuestionReview reviewQuestion({bool correct = false}) {
    return ResultQuestionReview(
      questionId: 1,
      questionVersionId: 'qv-1',
      testQuestionId: 'tq-1',
      testSectionId: 'section-1',
      section: 'Quantitative Aptitude',
      text: 'Sample question',
      options: const ['A', 'B', 'C', 'D'],
      optionKeys: const ['A', 'B', 'C', 'D'],
      selected: correct ? 1 : 0,
      selectedOptionKey: correct ? 'B' : 'A',
      correct: 1,
      correctOptionKey: 'B',
      timeTakenSeconds: 42,
      flagged: false,
      explanation: 'Sample explanation',
    );
  }

  Result result({
    required String id,
    required String name,
    required String category,
    required double score,
    required double accuracy,
    bool withReview = true,
    bool cleanAttempt = false,
  }) {
    final correctCount = cleanAttempt ? 100 : score.round();
    final incorrectCount = cleanAttempt ? 0 : 100 - score.round();
    return Result(
      id: id,
      attemptId: 'attempt-$id',
      userId: 'student-1',
      examId: 'exam-$id',
      score: score,
      maxScore: 100,
      accuracy: accuracy,
      correctCount: correctCount,
      incorrectCount: incorrectCount,
      skippedCount: 0,
      calculatedAt: now.subtract(Duration(days: int.parse(id))),
      testName: name,
      category: category,
      percentageScore: score,
      rawScore: score,
      totalQuestions: 100,
      questionReview: withReview
          ? [reviewQuestion(correct: cleanAttempt)]
          : const [],
    );
  }

  Future<void> pumpResults(
    WidgetTester tester, {
    required List<Result> results,
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
          userResultsProvider.overrideWith((ref) async => results),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              textScaler: TextScaler.linear(textScale),
              disableAnimations: true,
            ),
            child: const ResultsScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('results place performance snapshot before attempt history', (tester) async {
    await pumpResults(
      tester,
      results: [
        result(id: '1', name: 'SSC CGL Mock', category: 'SSC', score: 74, accuracy: 82),
        result(id: '2', name: 'Railway NTPC Mock', category: 'Railways', score: 81, accuracy: 88),
      ],
    );

    expect(find.text('Results'), findsOneWidget);
    expect(find.byKey(const Key('results-performance-snapshot')), findsOneWidget);
    expect(find.text('2'), findsWidgets);
    expect(find.text('Attempt history'), findsOneWidget);
    expect(find.text('SSC CGL Mock'), findsOneWidget);
  });

  testWidgets('review mistakes is primary before retake when review exists', (tester) async {
    await pumpResults(
      tester,
      results: [
        result(id: '1', name: 'SSC CGL Mock', category: 'SSC', score: 74, accuracy: 82),
      ],
    );

    expect(find.text('Review mistakes'), findsOneWidget);
    expect(find.byKey(const Key('results-review-primary')), findsOneWidget);
    expect(find.byKey(const Key('results-retake-secondary')), findsOneWidget);
    expect(find.byKey(const Key('results-retake-primary')), findsNothing);
  });

  testWidgets('clean attempt uses truthful review answers label', (tester) async {
    await pumpResults(
      tester,
      results: [
        result(
          id: '1',
          name: 'Perfect mock',
          category: 'SSC',
          score: 100,
          accuracy: 100,
          cleanAttempt: true,
        ),
      ],
    );

    expect(find.text('Review answers'), findsOneWidget);
    expect(find.byKey(const Key('results-review-primary')), findsOneWidget);
    expect(find.byKey(const Key('results-retake-secondary')), findsOneWidget);
  });

  testWidgets('legacy result without question review keeps retake usable as primary', (tester) async {
    await pumpResults(
      tester,
      results: [
        result(
          id: '1',
          name: 'Older attempt',
          category: 'SSC',
          score: 74,
          accuracy: 82,
          withReview: false,
        ),
      ],
    );

    expect(find.byKey(const Key('results-review-primary')), findsNothing);
    expect(find.byKey(const Key('results-retake-primary')), findsOneWidget);
    expect(find.byKey(const Key('results-retake-secondary')), findsNothing);
  });

  testWidgets('search filters attempt history and exposes reset', (tester) async {
    await pumpResults(
      tester,
      results: [
        result(id: '1', name: 'SSC CGL Mock', category: 'SSC', score: 74, accuracy: 82),
        result(id: '2', name: 'Railway NTPC Mock', category: 'Railways', score: 81, accuracy: 88),
      ],
    );

    await tester.enterText(find.byKey(const Key('results-search')), 'railway');
    await tester.pump();

    expect(find.text('Railway NTPC Mock'), findsOneWidget);
    expect(find.text('SSC CGL Mock'), findsNothing);
    expect(find.text('1 of 2 shown.'), findsOneWidget);
    expect(find.byKey(const Key('results-reset')), findsOneWidget);
  });

  testWidgets('empty results direct learner back to tests without fake metrics', (tester) async {
    await pumpResults(tester, results: const []);

    expect(find.text('No completed attempts yet'), findsOneWidget);
    expect(find.text('Explore tests'), findsOneWidget);
    expect(find.byKey(const Key('results-performance-snapshot')), findsNothing);
    expect(find.textContaining('rank'), findsNothing);
    expect(find.textContaining('percentile'), findsNothing);
  });

  testWidgets('results remain usable at 200 percent text scaling', (tester) async {
    await pumpResults(
      tester,
      results: [
        result(
          id: '1',
          name: 'SSC Combined Graduate Level Full Length Diagnostic Mock',
          category: 'SSC',
          score: 74,
          accuracy: 82,
        ),
      ],
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('results-search')), findsOneWidget);
  });
}
