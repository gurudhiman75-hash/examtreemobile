import 'package:examtree/features/profile/domain/performance_analytics.dart';
import 'package:examtree/features/profile/presentation/performance_analysis_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final analytics = PerformanceAnalytics(
    userId: 'student',
    totalTestsAttempted: 3,
    averageScore: 68.5,
    averageAccuracy: 75,
    totalCorrect: 90,
    totalIncorrect: 30,
    totalUnanswered: 20,
    averageTimePerQuestion: 42,
    latestAttemptId: 'attempt-3',
    latestTestName: 'SSC CGL Mock 3',
    updatedAt: DateTime.utc(2026, 10, 17),
    scoreTrend: [
      PerformanceTrendPoint(
        attemptId: 'attempt-1',
        testName: 'Mock 1',
        percentageScore: 58,
        accuracy: 68,
        completedAt: DateTime.utc(2026, 10, 12),
      ),
      PerformanceTrendPoint(
        attemptId: 'attempt-2',
        testName: 'Mock 2',
        percentageScore: 65,
        accuracy: 72,
        completedAt: DateTime.utc(2026, 10, 14),
      ),
      PerformanceTrendPoint(
        attemptId: 'attempt-3',
        testName: 'Mock 3',
        percentageScore: 82.5,
        accuracy: 84,
        completedAt: DateTime.utc(2026, 10, 16),
      ),
    ],
    sectionPerformance: const [
      SectionPerformance(
        name: 'English',
        correct: 32,
        incorrect: 8,
        unanswered: 5,
        timedQuestions: 40,
        totalTimeSeconds: 1320,
      ),
      SectionPerformance(
        name: 'Reasoning',
        correct: 25,
        incorrect: 15,
        unanswered: 5,
        timedQuestions: 40,
        totalTimeSeconds: 1720,
      ),
    ],
  );

  testWidgets('shows truthful performance dashboard metrics', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PerformanceAnalysisView(analytics: analytics),
        ),
      ),
    );

    expect(find.byKey(const Key('performance-analysis-hero')), findsOneWidget);
    expect(find.text('68.5%'), findsOneWidget);
    expect(find.text('75%'), findsWidgets);
    expect(find.text('42s'), findsOneWidget);
    expect(find.byKey(const Key('performance-score-trend')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Strengths & focus'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Strongest'), findsOneWidget);
    expect(find.text('Needs focus'), findsOneWidget);
    expect(find.text('English'), findsWidgets);
    expect(find.text('Reasoning'), findsWidgets);
  });

  testWidgets('shows truthful empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PerformanceAnalysisView(
            analytics: PerformanceAnalytics.empty('student'),
          ),
        ),
      ),
    );

    expect(
      find.text('Your analysis starts with your first test'),
      findsOneWidget,
    );
    expect(find.text('Browse Tests'), findsOneWidget);
    expect(find.textContaining('rank'), findsNothing);
    expect(find.textContaining('percentile'), findsNothing);
  });
}
