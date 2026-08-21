import 'package:examtree/core/models/analytics_model.dart';
import 'package:examtree/core/models/exam_model.dart';
import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/auth/presentation/providers/auth_providers.dart';
import 'package:examtree/features/companion/domain/daily_companion.dart';
import 'package:examtree/features/companion/presentation/providers/daily_companion_providers.dart';
import 'package:examtree/features/exams/presentation/providers/exam_providers.dart';
import 'package:examtree/features/home/presentation/home_screen.dart';
import 'package:examtree/features/profile/presentation/providers/analytics_providers.dart';
import 'package:examtree/features/promotions/presentation/providers/promotion_providers.dart';
import 'package:examtree/features/results/presentation/providers/result_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 18, 9, 30);

  Exam exam(String id, String title) => Exam(
        id: id,
        title: title,
        description: '$title description',
        durationInSeconds: 3600,
        totalQuestions: 100,
        totalMarks: 100,
        maxAttempts: 5,
        negativeMarking: 0.25,
        difficulty: 'Medium',
        status: 'published',
        category: 'SSC',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
      );

  Result result() => Result(
        id: 'result-1',
        attemptId: 'attempt-1',
        userId: 'student-1',
        examId: 'exam-complete',
        score: 74,
        maxScore: 100,
        accuracy: 82,
        correctCount: 74,
        incorrectCount: 16,
        skippedCount: 10,
        calculatedAt: now.subtract(const Duration(days: 2)),
        testName: 'SSC diagnostic mock',
        percentageScore: 74,
        rawScore: 74,
        totalQuestions: 100,
      );

  Analytics analytics() => Analytics(
        id: 'analytics-1',
        userId: 'student-1',
        totalTestsAttempted: 8,
        averageScore: 71,
        averageAccuracy: 81,
        weakestTopics: const ['Time and Work'],
        averageTimePerQuestion: 44,
        updatedAt: now,
      );

  RevisionItem revisionItem(int index) => RevisionItem(
        id: 'revision-$index',
        sourceAttemptId: 'attempt-$index',
        testId: 'test-$index',
        testName: 'Mock $index',
        section: 'Quantitative Aptitude',
        questionText: 'Question $index',
        options: const ['A', 'B', 'C', 'D'],
        selectedIndex: 0,
        correctIndex: 1,
        explanation: 'Explanation $index',
        reasons: const {RevisionReason.incorrect},
        timeTakenSeconds: 45,
        dueAt: now.subtract(const Duration(minutes: 5)),
        stage: 0,
        createdAt: now.subtract(const Duration(days: 1)),
      );

  DailyCompanionSnapshot companionSnapshot({int dueCount = 0}) {
    return DailyCompanionSnapshot(
      settings: const StudyCompanionSettings(dailyQuestionGoal: 10),
      items: List.generate(dueCount, revisionItem),
      completedToday: 0,
    );
  }

  Future<void> pumpHome(
    WidgetTester tester, {
    required List<Exam> active,
    required List<Exam> available,
    required List<Result> results,
    int dueRevisionCount = 0,
    double textScale = 1,
  }) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        authStateChangesProvider.overrideWith(
          (ref) => Stream<User?>.value(null),
        ),
        promotionAudienceExamIdsProvider.overrideWith(
          (ref) => const AsyncData<List<String>>(<String>[]),
        ),
        userAnalyticsProvider.overrideWith((ref) async => analytics()),
        inProgressExamsProvider.overrideWith((ref) async => active),
        availableExamsProvider.overrideWith((ref) async => available),
        userResultsProvider.overrideWith((ref) async => results),
        dailyCompanionSnapshotProvider.overrideWith(
          (ref) async => companionSnapshot(dueCount: dueRevisionCount),
        ),
      ],
    );
    addTearDown(container.dispose);

    await Future.wait<Object?>([
      container.read(userAnalyticsProvider.future),
      container.read(inProgressExamsProvider.future),
      container.read(availableExamsProvider.future),
      container.read(userResultsProvider.future),
      container.read(dailyCompanionSnapshotProvider.future),
    ]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              textScaler: TextScaler.linear(textScale),
              disableAnimations: true,
            ),
            child: HomeScreen(now: () => now),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> scrollHome(WidgetTester tester, double distance) async {
    await tester.drag(
      find.byType(CustomScrollView),
      Offset(0, -distance),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('active learner sees one dominant resume action first', (tester) async {
    await pumpHome(
      tester,
      active: [
        exam('active-1', 'SSC CGL full mock'),
        exam('active-2', 'Quant speed sectional'),
      ],
      available: [exam('available-1', 'Reasoning mixed practice')],
      results: [result()],
      dueRevisionCount: 4,
    );

    expect(find.text('Resume test'), findsOneWidget);
    expect(find.text('SSC CGL full mock'), findsOneWidget);
    expect(find.text('Performance pulse'), findsOneWidget);
    expect(find.text('Continue learning'), findsOneWidget);

    await scrollHome(tester, 620);
    expect(find.byKey(const Key('home-context-tests')), findsOneWidget);
    expect(find.byKey(const Key('home-context-results')), findsOneWidget);
  });

  testWidgets('due revision becomes primary before generic test discovery', (tester) async {
    await pumpHome(
      tester,
      active: const [],
      available: [exam('available-1', 'Reasoning mixed practice')],
      results: [result()],
      dueRevisionCount: 3,
    );

    expect(find.text('DUE FOR REVISION'), findsOneWidget);
    expect(find.text('3 questions to revisit'), findsOneWidget);
    expect(find.text('Start revision'), findsOneWidget);
    expect(find.text('Next test'), findsNothing);
  });

  testWidgets('new learner stays truthful when catalogue is empty', (tester) async {
    await pumpHome(
      tester,
      active: const [],
      available: const [],
      results: const [],
    );

    expect(find.text('Choose your next test'), findsOneWidget);
    expect(find.text('Browse tests'), findsOneWidget);
    expect(find.textContaining('streak', findRichText: true), findsNothing);
    expect(find.textContaining('readiness', findRichText: true), findsNothing);

    await scrollHome(tester, 900);
    expect(find.text('No tests are available right now.'), findsOneWidget);
  });

  testWidgets('home remains usable at 200 percent text scaling', (tester) async {
    await pumpHome(
      tester,
      active: [exam('active-1', 'SSC CGL full mock')],
      available: [exam('available-1', 'Reasoning mixed practice')],
      results: [result()],
      dueRevisionCount: 2,
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Resume test'), findsOneWidget);
  });
}
