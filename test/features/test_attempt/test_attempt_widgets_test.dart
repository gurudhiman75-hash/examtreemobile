import 'package:examtree/features/test_attempt/domain/test_attempt_experience.dart';
import 'package:examtree/features/test_attempt/presentation/widgets/test_attempt_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('submission dialog shows canonical attempt counts', (tester) async {
    const summary = AttemptSubmissionSummary(
      notVisited: 2,
      notAnswered: 1,
      answered: 4,
      markedForReview: 1,
      answeredAndMarkedForReview: 2,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SubmissionSummaryDialog(
            summary: summary,
            testName: 'SSC Mock Test 1',
          ),
        ),
      ),
    );

    expect(find.text('Submit test?'), findsOneWidget);
    expect(find.text('SSC Mock Test 1'), findsOneWidget);
    expect(find.text('Answered'), findsOneWidget);
    expect(find.text('Unanswered'), findsOneWidget);
    expect(find.text('Marked for review'), findsOneWidget);
    expect(find.text('Review unanswered'), findsOneWidget);
    expect(find.text('Submit now'), findsOneWidget);
  });

  testWidgets('complete attempt hides review unanswered action', (tester) async {
    const summary = AttemptSubmissionSummary(
      notVisited: 0,
      notAnswered: 0,
      answered: 8,
      markedForReview: 0,
      answeredAndMarkedForReview: 2,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SubmissionSummaryDialog(
            summary: summary,
            testName: 'Complete mock',
          ),
        ),
      ),
    );

    expect(find.text('Review unanswered'), findsNothing);
    expect(find.text('Submit now'), findsOneWidget);
  });

  testWidgets('failed sync banner exposes retry action', (tester) async {
    var retries = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SyncStatusBanner(
            syncing: false,
            syncFailed: true,
            lastSavedAt: DateTime.utc(2026, 8, 7),
            onRetry: () => retries++,
          ),
        ),
      ),
    );

    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
  });

  testWidgets('exit dialog blocks leave action while saving', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExitAttemptDialog(syncFailed: false, syncing: true),
        ),
      ),
    );

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(find.text('Stay'), findsOneWidget);
  });
}
