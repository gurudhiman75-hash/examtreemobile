import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/auth/presentation/providers/auth_providers.dart';
import 'package:examtree/features/profile/domain/performance_analytics.dart';
import 'package:examtree/features/profile/presentation/profile_screen.dart';
import 'package:examtree/features/profile/presentation/providers/analytics_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final updatedAt = DateTime(2026, 8, 18, 12);

  PerformanceAnalytics populatedAnalytics() {
    return PerformanceAnalytics(
      userId: 'student-1',
      totalTestsAttempted: 8,
      averageScore: 74,
      averageAccuracy: 82,
      totalCorrect: 410,
      totalIncorrect: 90,
      totalUnanswered: 50,
      averageTimePerQuestion: 43,
      latestAttemptId: 'attempt-8',
      latestTestName: 'SSC CGL Mock 8',
      updatedAt: updatedAt,
      scoreTrend: [
        PerformanceTrendPoint(
          attemptId: 'attempt-6',
          testName: 'SSC CGL Mock 6',
          percentageScore: 68,
          accuracy: 77,
          completedAt: updatedAt.subtract(const Duration(days: 6)),
        ),
        PerformanceTrendPoint(
          attemptId: 'attempt-7',
          testName: 'SSC CGL Mock 7',
          percentageScore: 72,
          accuracy: 80,
          completedAt: updatedAt.subtract(const Duration(days: 3)),
        ),
        PerformanceTrendPoint(
          attemptId: 'attempt-8',
          testName: 'SSC CGL Mock 8',
          percentageScore: 78,
          accuracy: 85,
          completedAt: updatedAt,
        ),
      ],
      sectionPerformance: const [
        SectionPerformance(
          name: 'Reasoning',
          correct: 90,
          incorrect: 10,
          unanswered: 5,
          timedQuestions: 100,
          totalTimeSeconds: 3500,
        ),
        SectionPerformance(
          name: 'Quantitative Aptitude',
          correct: 55,
          incorrect: 35,
          unanswered: 10,
          timedQuestions: 90,
          totalTimeSeconds: 4500,
        ),
      ],
    );
  }

  Future<void> pumpProfile(
    WidgetTester tester, {
    required PerformanceAnalytics analytics,
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateChangesProvider.overrideWith(
            (ref) => Stream<User?>.value(null),
          ),
          performanceAnalyticsProvider.overrideWith((ref) async => analytics),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: const ProfileScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('profile prioritizes compact performance and focus signals', (
    tester,
  ) async {
    await pumpProfile(tester, analytics: populatedAnalytics());

    expect(find.text('Your profile'), findsOneWidget);
    expect(find.text('Performance'), findsOneWidget);
    expect(find.text('74%'), findsOneWidget);
    expect(find.text('82%'), findsOneWidget);
    expect(find.text('What to focus on'), findsOneWidget);
    expect(find.text('Reasoning'), findsWidgets);
    expect(find.text('Quantitative Aptitude'), findsWidgets);
    expect(find.byKey(const Key('profile-review-latest')), findsOneWidget);
    expect(find.text('Recent trend'), findsOneWidget);
  });

  testWidgets('profile shows truthful first-test empty state', (tester) async {
    await pumpProfile(
      tester,
      analytics: PerformanceAnalytics.empty('student-1'),
    );

    expect(
      find.text('Your performance starts with your first test'),
      findsOneWidget,
    );
    expect(find.text('Browse tests'), findsOneWidget);
    expect(find.text('Recent trend'), findsNothing);
  });

  testWidgets('profile remains usable at 200 percent text scale', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      analytics: populatedAnalytics(),
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Performance'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
  });
}
