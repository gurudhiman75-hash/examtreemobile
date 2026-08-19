import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/results/presentation/providers/result_providers.dart';
import 'package:examtree/features/results/presentation/review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ResultQuestionReview question({
    required int id,
    required int? selected,
    required int correct,
    required String text,
  }) {
    return ResultQuestionReview(
      questionId: id,
      questionVersionId: 'version-$id',
      testQuestionId: 'test-question-$id',
      testSectionId: 'section-1',
      section: 'Quantitative Aptitude',
      text: text,
      options: const ['Option A', 'Option B', 'Option C', 'Option D'],
      optionKeys: const ['A', 'B', 'C', 'D'],
      selected: selected,
      selectedOptionKey:
          selected == null ? null : String.fromCharCode(65 + selected),
      correct: correct,
      correctOptionKey: String.fromCharCode(65 + correct),
      timeTakenSeconds: 75,
      flagged: id == 2,
      explanation:
          'Use the given information step by step and compare the available options.',
    );
  }

  Result result() {
    final questions = [
      question(
        id: 1,
        selected: 0,
        correct: 0,
        text: 'A correct sample question?',
      ),
      question(
        id: 2,
        selected: 1,
        correct: 2,
        text: 'An incorrect sample question?',
      ),
      question(
        id: 3,
        selected: null,
        correct: 3,
        text: 'An unanswered sample question?',
      ),
    ];
    return Result(
      id: 'attempt-1',
      attemptId: 'attempt-1',
      userId: 'student-1',
      examId: 'test-1',
      score: 1,
      maxScore: 3,
      accuracy: 50,
      correctCount: 1,
      incorrectCount: 1,
      skippedCount: 1,
      calculatedAt: DateTime(2026, 8, 18),
      testName: 'SSC CGL Practice Test',
      totalQuestions: 3,
      questionReview: questions,
    );
  }

  Future<void> pumpReview(
    WidgetTester tester, {
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
          resultProvider('attempt-1').overrideWith((ref) async => result()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              textScaler: TextScaler.linear(textScale),
              disableAnimations: true,
            ),
            child: const ReviewScreen(resultId: 'attempt-1'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('review keeps answer semantics and moves between questions', (
    tester,
  ) async {
    await pumpReview(tester);

    expect(find.text('Answer review'), findsOneWidget);
    expect(find.text('SSC CGL Practice Test'), findsOneWidget);
    expect(find.text('Question 1 of 3'), findsOneWidget);
    expect(find.text('Your answer · Correct'), findsOneWidget);

    await tester.tap(find.byKey(const Key('review-next-finish')));
    await tester.pumpAndSettle();

    expect(find.text('Question 2 of 3'), findsOneWidget);
    expect(find.text('Your answer'), findsOneWidget);
    expect(find.text('Correct answer'), findsOneWidget);
  });

  testWidgets('review filter preserves original question numbering', (tester) async {
    await pumpReview(tester);

    await tester.tap(find.text('Incorrect 1'));
    await tester.pumpAndSettle();

    expect(find.text('Question 2 of 3'), findsOneWidget);
    expect(find.text('Q2. An incorrect sample question?'), findsOneWidget);
    expect(find.text('Finish'), findsOneWidget);
  });

  testWidgets('question palette jumps directly to a visible question', (tester) async {
    await pumpReview(tester);

    await tester.tap(find.byKey(const Key('review-open-palette')));
    await tester.pumpAndSettle();

    expect(find.text('All questions'), findsOneWidget);
    expect(find.byKey(const Key('review-palette-grid')), findsOneWidget);

    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();

    expect(find.text('Question 3 of 3'), findsOneWidget);
    expect(find.text('Q3. An unanswered sample question?'), findsOneWidget);
  });

  testWidgets('review remains usable at 200 percent text scale', (tester) async {
    await pumpReview(tester, textScale: 2);

    final initialException = tester.takeException();
    if (initialException is FlutterError) {
      debugPrint(initialException.toStringDeep());
    }
    expect(initialException, isNull);
    expect(find.text('Question 1 of 3'), findsOneWidget);
    expect(find.byKey(const Key('review-next-finish')), findsOneWidget);
    expect(find.byKey(const Key('review-previous')), findsOneWidget);

    await tester.tap(find.byKey(const Key('review-open-palette')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('review-palette-grid')), findsOneWidget);
  });
}
