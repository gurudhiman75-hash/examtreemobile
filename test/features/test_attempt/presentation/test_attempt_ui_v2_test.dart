import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/test_attempt/domain/test_attempt_experience.dart';
import 'package:examtree/features/test_attempt/presentation/widgets/question_palette_sheet.dart';
import 'package:examtree/features/test_attempt/presentation/widgets/test_attempt_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget app(Widget child, {double textScale = 1}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(390, 844),
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(body: child),
      ),
    );
  }

  Color statusColor(BuildContext context, QuestionStatus status) {
    final scheme = Theme.of(context).colorScheme;
    return switch (status) {
      QuestionStatus.notVisited => scheme.surface,
      QuestionStatus.notAnswered => scheme.errorContainer,
      QuestionStatus.answered => scheme.secondaryContainer,
      QuestionStatus.markedForReview => scheme.tertiaryContainer,
      QuestionStatus.answeredAndMarkedForReview => scheme.primaryContainer,
    };
  }

  testWidgets('question palette exposes counts, filters and direct question jumps', (
    tester,
  ) async {
    var selected = -1;
    final states = [
      QuestionState(status: QuestionStatus.answered, selectedOptionIndex: 1),
      QuestionState(status: QuestionStatus.notAnswered),
      QuestionState(status: QuestionStatus.markedForReview),
      QuestionState(
        status: QuestionStatus.answeredAndMarkedForReview,
        selectedOptionIndex: 2,
      ),
    ];

    await tester.pumpWidget(
      app(
        QuestionPaletteSheet(
          states: states,
          currentIndex: 1,
          onQuestionSelected: (index) => selected = index,
          statusColor: statusColor,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Question palette'), findsOneWidget);
    expect(find.text('Answered'), findsOneWidget);
    expect(find.text('Unanswered'), findsOneWidget);
    expect(find.text('Marked'), findsOneWidget);
    expect(find.text('Unanswered 2'), findsOneWidget);
    expect(find.text('Marked 2'), findsOneWidget);

    await tester.tap(find.text('Unanswered 2'));
    await tester.pumpAndSettle();
    expect(find.text('2 of 4 questions shown'), findsOneWidget);

    await tester.tap(find.text('2').last);
    await tester.pumpAndSettle();
    expect(selected, 1);
  });

  testWidgets('submission dialog keeps review, submit and continue decisions distinct', (
    tester,
  ) async {
    const summary = AttemptSubmissionSummary(
      notVisited: 1,
      notAnswered: 1,
      answered: 7,
      markedForReview: 0,
      answeredAndMarkedForReview: 1,
    );

    await tester.pumpWidget(
      app(
        const SubmissionSummaryDialog(
          summary: summary,
          testName: 'SSC CGL full-length mock',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Submit test?'), findsOneWidget);
    expect(find.text('Review unanswered'), findsOneWidget);
    expect(find.text('Submit now'), findsOneWidget);
    expect(find.text('Continue test'), findsOneWidget);
  });

  testWidgets('attempt decision UI remains usable at 200 percent text scaling', (
    tester,
  ) async {
    const summary = AttemptSubmissionSummary(
      notVisited: 2,
      notAnswered: 1,
      answered: 5,
      markedForReview: 1,
      answeredAndMarkedForReview: 1,
    );

    await tester.pumpWidget(
      app(
        const SubmissionSummaryDialog(
          summary: summary,
          testName: 'A deliberately long examination title for accessibility',
        ),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Submit now'), findsOneWidget);
    expect(find.text('Continue test'), findsOneWidget);
  });

  testWidgets('syncing exit dialog disables leaving until the active save finishes', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(const ExitAttemptDialog(syncFailed: false, syncing: true)),
    );
    await tester.pumpAndSettle();

    final saveButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(saveButton.onPressed, isNull);
    expect(find.text('Stay'), findsOneWidget);
  });
}
