import 'package:examtree/core/models/exam_model.dart';
import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/shared/layouts/app_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 20, 11);

  Exam exam() => Exam(
        id: 'active',
        title: 'Active test',
        description: 'Active test',
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

  Result result(DateTime calculatedAt) => Result(
        id: 'result-1',
        attemptId: 'attempt-1',
        userId: 'student-1',
        examId: 'exam-1',
        score: 70,
        maxScore: 100,
        accuracy: 80,
        correctCount: 70,
        incorrectCount: 20,
        skippedCount: 10,
        calculatedAt: calculatedAt,
        testName: 'Mock',
        percentageScore: 70,
        rawScore: 70,
        totalQuestions: 100,
      );

  test('Home always resets while inactive non-Home branches preserve stack', () {
    expect(
      shouldResetBranchOnSelection(selectedIndex: 0, currentIndex: 2),
      isTrue,
    );
    expect(
      shouldResetBranchOnSelection(selectedIndex: 1, currentIndex: 2),
      isFalse,
    );
    expect(
      shouldResetBranchOnSelection(selectedIndex: 2, currentIndex: 2),
      isTrue,
    );
  });

  test('Daily Companion action appears only on Home when not already primary', () {
    expect(shouldShowDailyAction(0), isTrue);
    expect(shouldShowDailyAction(0, revisionIsPrimary: true), isFalse);
    expect(shouldShowDailyAction(1), isFalse);
    expect(shouldShowDailyAction(2), isFalse);
    expect(shouldShowDailyAction(3), isFalse);
  });

  test('active attempt keeps Daily shortcut available even with revision due', () {
    expect(
      isRevisionPrimaryOnHome(
        activeAsync: AsyncData([exam()]),
        resultsAsync: const AsyncData(<Result>[]),
        dueCount: 4,
        now: now,
      ),
      isFalse,
    );
  });

  test('fresh result keeps Daily shortcut available even with revision due', () {
    expect(
      isRevisionPrimaryOnHome(
        activeAsync: const AsyncData(<Exam>[]),
        resultsAsync: AsyncData([
          result(now.subtract(const Duration(hours: 2))),
        ]),
        dueCount: 4,
        now: now,
      ),
      isFalse,
    );
  });

  test('Daily floating action hides when revision is already Home primary', () {
    expect(
      isRevisionPrimaryOnHome(
        activeAsync: const AsyncData(<Exam>[]),
        resultsAsync: AsyncData([
          result(now.subtract(const Duration(days: 2))),
        ]),
        dueCount: 4,
        now: now,
      ),
      isTrue,
    );
  });

  test('unknown remote priority keeps Daily action visible until resolved', () {
    expect(
      isRevisionPrimaryOnHome(
        activeAsync: const AsyncLoading<List<Exam>>(),
        resultsAsync: const AsyncData(<Result>[]),
        dueCount: 4,
        now: now,
      ),
      isFalse,
    );
  });

  test('Daily Companion action reflects real revision state', () {
    expect(
      dailyActionLabel(dueCount: 4, completedToday: 3, dailyGoal: 10),
      '4 due',
    );
    expect(
      dailyActionLabel(dueCount: 0, completedToday: 10, dailyGoal: 10),
      'Revision done',
    );
    expect(
      dailyActionLabel(dueCount: 0, completedToday: 3, dailyGoal: 10),
      'Daily plan',
    );
  });
}
