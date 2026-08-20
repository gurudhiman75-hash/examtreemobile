import 'package:examtree/core/models/exam_model.dart';
import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/features/home/presentation/home_primary_action.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 7, 29, 10);

  Exam exam({
    required String id,
    required String title,
    String status = 'published',
    DateTime? updatedAt,
  }) {
    final updated = updatedAt ?? now;
    return Exam(
      id: id,
      title: title,
      description: '$title description',
      durationInSeconds: 3600,
      totalQuestions: 100,
      totalMarks: 100,
      maxAttempts: 10,
      negativeMarking: 0.25,
      difficulty: 'Medium',
      status: status,
      category: 'SSC',
      createdAt: updated.subtract(const Duration(days: 1)),
      updatedAt: updated,
    );
  }

  Result result({required String id, required DateTime calculatedAt}) {
    return Result(
      id: id,
      attemptId: id,
      userId: 'student-1',
      examId: 'exam-$id',
      score: 70,
      maxScore: 100,
      accuracy: 80,
      correctCount: 70,
      incorrectCount: 20,
      skippedCount: 10,
      calculatedAt: calculatedAt,
      testName: 'Recent mock',
      percentageScore: 70,
      rawScore: 70,
      totalQuestions: 100,
    );
  }

  test('active attempt always receives first priority', () {
    final action = resolveHomePrimaryAction(
      activeTests: [exam(id: 'active', title: 'Active test')],
      results: [result(id: 'recent', calculatedAt: now)],
      availableTests: [exam(id: 'available', title: 'Available test')],
      dueRevisionCount: 8,
      now: now,
    );

    expect(action.kind, HomePrimaryActionKind.resumeTest);
    expect(action.exam?.id, 'active');
  });

  test('recent result outranks due revision when no attempt is active', () {
    final action = resolveHomePrimaryAction(
      activeTests: const [],
      results: [
        result(
          id: 'recent',
          calculatedAt: now.subtract(const Duration(hours: 3)),
        ),
      ],
      availableTests: [exam(id: 'available', title: 'Available test')],
      dueRevisionCount: 8,
      now: now,
    );

    expect(action.kind, HomePrimaryActionKind.reviewResult);
    expect(action.result?.attemptId, 'recent');
  });

  test('due revision outranks a generic new test after fresh review window', () {
    final action = resolveHomePrimaryAction(
      activeTests: const [],
      results: [
        result(
          id: 'old',
          calculatedAt: now.subtract(const Duration(days: 3)),
        ),
      ],
      availableTests: [exam(id: 'available', title: 'Available test')],
      dueRevisionCount: 6,
      now: now,
    );

    expect(action.kind, HomePrimaryActionKind.reviseDue);
    expect(action.dueRevisionCount, 6);
    expect(action.title, '6 questions to revisit');
    expect(action.actionLabel, 'Start revision');
  });

  test('available test is next when nothing is due for revision', () {
    final action = resolveHomePrimaryAction(
      activeTests: const [],
      results: [
        result(
          id: 'old',
          calculatedAt: now.subtract(const Duration(days: 3)),
        ),
      ],
      availableTests: [exam(id: 'available', title: 'Available test')],
      dueRevisionCount: 0,
      now: now,
    );

    expect(action.kind, HomePrimaryActionKind.startTest);
    expect(action.exam?.id, 'available');
    expect(action.eyebrow, 'Next test');
  });

  test('free tests are ordered before newer paid tests', () {
    final action = resolveHomePrimaryAction(
      activeTests: const [],
      results: const [],
      availableTests: [
        exam(
          id: 'paid',
          title: 'Paid test',
          status: 'paid',
          updatedAt: now,
        ),
        exam(
          id: 'free',
          title: 'Free test',
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
      ],
      now: now,
    );

    expect(action.kind, HomePrimaryActionKind.startTest);
    expect(action.exam?.id, 'free');
  });

  test('negative due count is treated as no revision work', () {
    final action = resolveHomePrimaryAction(
      activeTests: const [],
      results: const [],
      availableTests: [exam(id: 'available', title: 'Available test')],
      dueRevisionCount: -2,
      now: now,
    );

    expect(action.kind, HomePrimaryActionKind.startTest);
  });

  test('falls back to browse when no actionable data exists', () {
    final action = resolveHomePrimaryAction(
      activeTests: const [],
      results: const [],
      availableTests: const [],
      now: now,
    );

    expect(action.kind, HomePrimaryActionKind.browseTests);
    expect(action.exam, isNull);
    expect(action.result, isNull);
  });
}
