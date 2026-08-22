import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/companion/domain/daily_companion.dart';
import 'package:examtree/features/companion/presentation/providers/daily_companion_providers.dart';
import 'package:examtree/features/companion/presentation/quick_revision_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  RevisionItem item() => RevisionItem(
        id: 'revision-1',
        sourceAttemptId: 'attempt-1',
        testId: 'test-1',
        testName: 'SSC CGL Practice Test',
        section: 'Quantitative Aptitude',
        questionText:
            'Which option correctly follows from the information in this revision question?',
        options: const [
          'Correct option',
          'Learner selected option',
          'Another option',
          'Final option',
        ],
        selectedIndex: 1,
        correctIndex: 0,
        explanation:
            'Read the condition carefully, identify the required relationship and compare the options.',
        reasons: const {
          RevisionReason.incorrect,
          RevisionReason.slow,
        },
        timeTakenSeconds: 95,
        dueAt: DateTime(2020, 1, 1),
        stage: 0,
        createdAt: DateTime(2020, 1, 1),
      );

  Finder revisionScrollable() => find.descendant(
        of: find.byKey(const Key('quick-revision-scroll')),
        matching: find.byType(Scrollable),
      );

  Future<void> pumpRevision(
    WidgetTester tester, {
    required List<RevisionItem> items,
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
          dailyCompanionSnapshotProvider.overrideWith(
            (ref) async => DailyCompanionSnapshot(
              settings: const StudyCompanionSettings(),
              items: items,
              completedToday: 0,
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              textScaler: TextScaler.linear(textScale),
              disableAnimations: true,
            ),
            child: const QuickRevisionScreen(minutes: 5),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('quick revision reveals answer semantics and explanation', (
    tester,
  ) async {
    await pumpRevision(tester, items: [item()]);

    expect(find.text('Question 1 of 1'), findsOneWidget);
    expect(find.text('Incorrect'), findsOneWidget);
    expect(find.text('Slow'), findsOneWidget);
    expect(find.text('Correct answer'), findsNothing);
    expect(tester.takeException(), isNull);

    final scrollable = revisionScrollable();
    await tester.drag(scrollable, const Offset(0, -420));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('quick-revision-show-answer')), findsOneWidget);
    await tester.tap(find.byKey(const Key('quick-revision-show-answer')));
    await tester.pump();

    expect(find.text('Correct answer'), findsOneWidget);
    expect(find.text('Your answer'), findsOneWidget);

    for (var index = 0; index < 3; index++) {
      await tester.drag(scrollable, const Offset(0, -360));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    expect(find.byKey(const Key('quick-revision-explanation')), findsOneWidget);
    expect(find.byKey(const Key('quick-revision-got-it')), findsOneWidget);
    expect(find.byKey(const Key('quick-revision-review-again')), findsOneWidget);
  });

  testWidgets('empty due queue gives a truthful completion state', (tester) async {
    await pumpRevision(tester, items: const []);

    expect(find.text('You’re caught up'), findsOneWidget);
    expect(find.text('No saved questions are due for review right now.'), findsOneWidget);
    expect(find.text('Nothing due — Done'), findsOneWidget);
  });

  testWidgets('revealed revision remains usable at 200 percent text scaling', (
    tester,
  ) async {
    await pumpRevision(tester, items: [item()], textScale: 2);

    expect(tester.takeException(), isNull);
    final scrollable = revisionScrollable();

    for (var index = 0; index < 8; index++) {
      await tester.drag(scrollable, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    expect(find.byKey(const Key('quick-revision-show-answer')), findsOneWidget);
    await tester.tap(find.byKey(const Key('quick-revision-show-answer')));
    await tester.pump();
    expect(tester.takeException(), isNull);

    for (var index = 0; index < 8; index++) {
      await tester.drag(scrollable, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    expect(find.byKey(const Key('quick-revision-got-it')), findsOneWidget);
    expect(find.byKey(const Key('quick-revision-review-again')), findsOneWidget);
  });
}
