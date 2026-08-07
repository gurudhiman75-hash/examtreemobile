import 'package:examtree/features/profile/domain/performance_analytics.dart';
import 'package:examtree/features/profile/presentation/widgets/performance_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows canonical overview, trend, sections and actions', (
    tester,
  ) async {
    var reviewedLatest = false;
    var openedResults = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PerformanceDashboard(
              analytics: _populatedAnalytics(),
              onOpenResults: () => openedResults = true,
              onReviewLatest: () => reviewedLatest = true,
              onBrowseTests: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Performance overview'), findsOneWidget);
    expect(find.text('Recent progress'), findsOneWidget);
    expect(find.text('Section performance'), findsOneWidget);
    expect(find.text('Reasoning'), findsWidgets);
    expect(find.text('75%'), findsWidgets);

    final reviewButton = find.text('Review Reasoning Mock 2');
    await tester.ensureVisible(reviewButton);
    await tester.tap(reviewButton);
    await tester.pump();
    expect(reviewedLatest, isTrue);

    final resultsButton = find.text('Open complete result history');
    await tester.ensureVisible(resultsButton);
    await tester.tap(resultsButton);
    await tester.pump();
    expect(openedResults, isTrue);
  });

  testWidgets('shows a useful empty state without fabricated metrics', (
    tester,
  ) async {
    var browsedTests = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PerformanceDashboard(
            analytics: PerformanceAnalytics.empty('student-2'),
            onOpenResults: () {},
            onReviewLatest: null,
            onBrowseTests: () => browsedTests = true,
          ),
        ),
      ),
    );

    expect(
      find.text('Your progress starts with a completed test'),
      findsOneWidget,
    );
    expect(find.text('Performance overview'), findsNothing);

    await tester.tap(find.text('Browse tests'));
    await tester.pump();
    expect(browsedTests, isTrue);
  });
}

PerformanceAnalytics _populatedAnalytics() {
  return PerformanceAnalytics(
    userId: 'student-1',
    totalTestsAttempted: 2,
    averageScore: 70,
    averageAccuracy: 75,
    totalCorrect: 3,
    totalIncorrect: 1,
    totalUnanswered: 1,
    averageTimePerQuestion: 25,
    latestAttemptId: 'attempt-2',
    latestTestName: 'Reasoning Mock 2',
    updatedAt: DateTime.utc(2026, 8, 2),
    scoreTrend: [
      PerformanceTrendPoint(
        attemptId: 'attempt-1',
        testName: 'Reasoning Mock 1',
        percentageScore: 60,
        accuracy: 50,
        completedAt: DateTime.utc(2026, 8, 1),
      ),
      PerformanceTrendPoint(
        attemptId: 'attempt-2',
        testName: 'Reasoning Mock 2',
        percentageScore: 80,
        accuracy: 100,
        completedAt: DateTime.utc(2026, 8, 2),
      ),
    ],
    sectionPerformance: const [
      SectionPerformance(
        name: 'Quantitative Aptitude',
        correct: 1,
        incorrect: 1,
        unanswered: 0,
        timedQuestions: 2,
        totalTimeSeconds: 60,
      ),
      SectionPerformance(
        name: 'Reasoning',
        correct: 2,
        incorrect: 0,
        unanswered: 1,
        timedQuestions: 2,
        totalTimeSeconds: 40,
      ),
    ],
  );
}
