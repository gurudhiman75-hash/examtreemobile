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
      now: now,
    );

    expect(action.kind, HomePrimaryActionKind.resumeTest);
    expect(action.exam?.id, 'active');
  });

  test('recent result is promoted when no attempt is active', () {
    final action = resolveHomePrimaryAction(
      activeTests: const [],
      results: [
        result(
          id: 'recent',
          calculatedAt: now.subtract(const Duration(hours: 3)),
        ),
      ],
      availableTests: [exam(id: 'available', title: 'Available test')],
      now: now,
    );

    expect(action.kind, HomePrimaryActionKind.reviewResult);
    expect(action.result?.attemptId, 'recent');
  });

  test('stale result does not block the next available test', () {
    final action = resolveHomePrimaryAction(
      activeTests: const [],
      results: [
        result(
          id: 'old',
          calculatedAt: now.subtract(const Duration(days: 3)),
        ),
      ],
      availableTests: [exam(id: 'available', title: 'Available test')],
      now: now,
    );

    expect(action.kind, HomePrimaryActionKind.startTest);
    expect(action.exam?.id, 'available');
  });

  test('free tests are recommended before newer paid tests', () {
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
