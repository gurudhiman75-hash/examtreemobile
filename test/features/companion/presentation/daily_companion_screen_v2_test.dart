import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/companion/domain/daily_companion.dart';
import 'package:examtree/features/companion/presentation/daily_companion_screen.dart';
import 'package:examtree/features/companion/presentation/providers/daily_companion_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 19, 7, 30);

  RevisionItem item({
    required String id,
    required DateTime dueAt,
    Set<RevisionReason> reasons = const {RevisionReason.incorrect},
  }) {
    return RevisionItem(
      id: id,
      sourceAttemptId: 'attempt-1',
      testId: 'test-1',
      testName: 'SSC CGL Practice Test',
      section: 'Quantitative Aptitude',
      questionText: 'A revision question that should remain easy to scan on a phone.',
      options: const ['A', 'B', 'C', 'D'],
      selectedIndex: 1,
      correctIndex: 0,
      explanation: 'Use the canonical explanation stored with the result.',
      reasons: reasons,
      timeTakenSeconds: 75,
      dueAt: dueAt,
      stage: 0,
      createdAt: now.subtract(const Duration(days: 1)),
    );
  }

  Finder dailyScrollable() => find.descendant(
        of: find.byKey(const Key('daily-companion-scroll')),
        matching: find.byType(Scrollable),
      );

  Future<void> pumpDaily(
    WidgetTester tester, {
    required DailyCompanionSnapshot snapshot,
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
          dailyCompanionClockProvider.overrideWithValue(() => now),
          dailyCompanionSnapshotProvider.overrideWith((ref) async => snapshot),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              textScaler: TextScaler.linear(textScale),
              disableAnimations: true,
            ),
            child: const DailyCompanionScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('daily companion prioritizes today and due revision actions', (
    tester,
  ) async {
    await pumpDaily(
      tester,
      snapshot: DailyCompanionSnapshot(
        settings: const StudyCompanionSettings(dailyQuestionGoal: 10),
        items: [
          item(
            id: 'due-1',
            dueAt: now.subtract(const Duration(minutes: 5)),
            reasons: const {
              RevisionReason.incorrect,
              RevisionReason.flagged,
            },
          ),
          item(id: 'later-1', dueAt: now.add(const Duration(days: 1))),
        ],
        completedToday: 3,
      ),
    );

    expect(find.byKey(const Key('daily-summary')), findsOneWidget);
    expect(find.text('1 question is due now.'), findsOneWidget);
    expect(find.text('3 of 10 reviews completed today'), findsOneWidget);
    expect(find.text('Exam-Day Mode'), findsOneWidget);
    expect(find.byKey(const Key('quick-revision-5')), findsOneWidget);
    expect(find.byKey(const Key('revision-item-due-1')), findsOneWidget);

    final quick = tester.widget<FilledButton>(
      find.byKey(const Key('quick-revision-5')),
    );
    expect(quick.onPressed, isNotNull);
  });

  testWidgets('empty queue is truthful and disables quick revision', (
    tester,
  ) async {
    await pumpDaily(
      tester,
      snapshot: const DailyCompanionSnapshot(
        settings: StudyCompanionSettings(dailyQuestionGoal: 8),
        items: [],
        completedToday: 2,
      ),
    );

    expect(find.text('You are caught up for now.'), findsOneWidget);
    expect(find.byKey(const Key('revision-queue-empty')), findsOneWidget);
    expect(find.textContaining('Complete tests to build'), findsOneWidget);

    final quick = tester.widget<FilledButton>(
      find.byKey(const Key('quick-revision-5')),
    );
    expect(quick.onPressed, isNull);
  });

  testWidgets('daily companion remains usable at 200 percent text scaling', (
    tester,
  ) async {
    await pumpDaily(
      tester,
      textScale: 2,
      snapshot: DailyCompanionSnapshot(
        settings: const StudyCompanionSettings(
          dailyQuestionGoal: 10,
          reminderEnabled: true,
          reminderHour: 19,
        ),
        items: [
          item(
            id: 'due-1',
            dueAt: now,
            reasons: const {
              RevisionReason.incorrect,
              RevisionReason.slow,
              RevisionReason.flagged,
            },
          ),
        ],
        completedToday: 4,
      ),
    );

    expect(tester.takeException(), isNull);

    final scrollable = dailyScrollable();
    await tester.drag(scrollable, const Offset(0, -420));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('quick-revision-5')), findsOneWidget);

    for (var index = 0; index < 4; index++) {
      await tester.drag(scrollable, const Offset(0, -520));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    expect(find.byKey(const Key('study-plan')), findsOneWidget);
    expect(find.text('Daily question goal'), findsOneWidget);
    expect(find.text('Change reminder time'), findsOneWidget);
  });
}
