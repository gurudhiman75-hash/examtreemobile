import 'package:examtree/core/models/exam_model.dart';
import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/exams/presentation/exam_details_screen.dart';
import 'package:examtree/features/exams/presentation/providers/exam_providers.dart';
import 'package:examtree/features/results/presentation/providers/result_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 18);
  final exam = Exam(
    id: 'exam-1',
    title: 'SSC CGL Full Mock 1',
    description: 'Full-length practice paper for the SSC CGL exam.',
    durationInSeconds: 3600,
    totalQuestions: 100,
    totalMarks: 200,
    maxAttempts: 3,
    negativeMarking: 0.5,
    difficulty: 'Medium',
    status: 'published',
    category: 'SSC',
    createdAt: now,
    updatedAt: now,
  );

  Future<void> pumpDetails(
    WidgetTester tester, {
    int completedAttempts = 1,
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          examDetailsProvider.overrideWith((ref, id) async => exam),
          completedAttemptCountProvider.overrideWith(
            (ref, id) async => completedAttempts,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: const ExamDetailsScreen(examId: 'exam-1'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('pre-test screen keeps start action persistent and prominent', (
    tester,
  ) async {
    await pumpDetails(tester);

    expect(find.text('SSC CGL Full Mock 1'), findsOneWidget);
    expect(find.text('At a glance'), findsOneWidget);
    expect(find.text('Before you start'), findsOneWidget);
    expect(find.byKey(const Key('exam-details-start')), findsOneWidget);
    expect(find.text('Start or resume test'), findsOneWidget);
    expect(find.text('1 completed · 3 attempts max'), findsOneWidget);
  });

  testWidgets('attempt limit disables the persistent start action', (tester) async {
    await pumpDetails(tester, completedAttempts: 3);

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('exam-details-start')),
    );
    expect(button.onPressed, isNull);
    expect(find.text('Attempt limit reached'), findsWidgets);
  });

  testWidgets('pre-test details remain usable at 200 percent text scale', (
    tester,
  ) async {
    await pumpDetails(tester, textScale: 2);

    expect(tester.takeException(), isNull);
    expect(find.text('At a glance'), findsOneWidget);
    expect(find.byKey(const Key('exam-details-start')), findsOneWidget);
  });
}
