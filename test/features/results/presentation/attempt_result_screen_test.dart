import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/results/domain/attempt_result_summary.dart';
import 'package:examtree/features/results/presentation/attempt_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ResultQuestionReview question(String section, int? selected, int? seconds) {
  return ResultQuestionReview(
    questionId: 1,
    questionVersionId: 'qv',
    testQuestionId: 'tq',
    testSectionId: section,
    section: section,
    text: 'Question',
    options: const ['A', 'B', 'C', 'D'],
    optionKeys: const ['A', 'B', 'C', 'D'],
    selected: selected,
    selectedOptionKey: selected == null ? null : 'ABCD'[selected],
    correct: 1,
    correctOptionKey: 'B',
    timeTakenSeconds: seconds,
    flagged: false,
    explanation: '',
  );
}

Result result({
  required String id,
  required DateTime at,
  required double percentage,
  List<ResultQuestionReview> review = const [],
  int? rank,
  double? percentile,
}) {
  return Result(
    id: id,
    attemptId: id,
    userId: 'u',
    examId: 'exam',
    score: percentage,
    maxScore: 100,
    accuracy: 0,
    correctCount: 0,
    incorrectCount: 0,
    skippedCount: 0,
    calculatedAt: at,
    testName: 'SSC CGL Mock 12',
    percentageScore: percentage,
    rawScore: percentage,
    totalQuestions: review.length,
    rank: rank,
    percentile: percentile,
    questionReview: review,
  );
}

void main() {
  Future<void> pump(WidgetTester tester, AttemptResultSummary summary) async {
    tester.view
      ..physicalSize = const Size(390, 6000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: AttemptResultView(summary: summary)),
      ),
    );
    await tester.pump();
  }

  final review = [
    question('Reasoning', 1, 30),
    question('Reasoning', 0, 60),
    question('Reasoning', null, 0),
    question('Quant', 1, 90),
    question('Quant', null, 0),
    question('Quant', null, 0),
  ];

  testWidgets('shows score, rank and every chart when data exists', (tester) async {
    final current = result(
      id: 'current',
      at: DateTime.utc(2026, 11, 22),
      percentage: 56.75,
      review: review,
      rank: 1284,
      percentile: 93,
    );
    final summary = AttemptResultSummary.fromResult(
      current,
      history: [
        result(id: 'old', at: DateTime.utc(2026, 11, 10), percentage: 52.5),
        current,
      ],
    );
    await pump(tester, summary);

    expect(find.text('SSC CGL Mock 12'), findsOneWidget);
    expect(find.text('56.8'), findsOneWidget);
    expect(find.text('1,284'), findsOneWidget);
    expect(find.text('percentile'), findsOneWidget);
    expect(find.textContaining('vs your last attempt'), findsOneWidget);
    expect(find.byKey(const Key('attempt-result-trend')), findsOneWidget);
    expect(find.byKey(const Key('attempt-result-outcome')), findsOneWidget);
    expect(find.byKey(const Key('attempt-result-accuracy-time')), findsOneWidget);
    expect(find.byKey(const Key('attempt-result-pacing')), findsOneWidget);
    expect(find.byKey(const Key('attempt-result-map')), findsOneWidget);
    expect(find.byKey(const Key('attempt-result-review')), findsOneWidget);
  });

  testWidgets('omits rank, trend and timing charts when unavailable', (tester) async {
    final current = result(
      id: 'current',
      at: DateTime.utc(2026, 11, 22),
      percentage: 40,
      review: [
        question('Reasoning', 1, null),
        question('Reasoning', 0, null),
        question('Quant', null, null),
      ],
    );
    await pump(tester, AttemptResultSummary.fromResult(current));

    expect(find.text('Rank'), findsNothing);
    expect(find.text('percentile'), findsNothing);
    expect(find.text('score'), findsOneWidget);
    expect(find.byKey(const Key('attempt-result-trend')), findsNothing);
    expect(find.byKey(const Key('attempt-result-accuracy-time')), findsNothing);
    expect(find.byKey(const Key('attempt-result-pacing')), findsNothing);
    expect(find.byKey(const Key('attempt-result-map')), findsOneWidget);
    expect(find.textContaining('vs your last attempt'), findsNothing);
  });
}
