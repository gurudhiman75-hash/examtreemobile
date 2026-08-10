import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/features/results/presentation/review_retry_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('retryExamId', () {
    test('returns a normalized exam id for a retryable result', () {
      expect(retryExamId(_result(' exam-1 ')), 'exam-1');
    });

    test('hides retry when the result has no usable exam id', () {
      expect(retryExamId(_result('   ')), isNull);
      expect(retryExamId(null), isNull);
    });
  });
}

Result _result(String examId) {
  return Result(
    id: 'attempt-1',
    attemptId: 'attempt-1',
    userId: 'user-1',
    examId: examId,
    score: 10,
    maxScore: 20,
    accuracy: 50,
    correctCount: 10,
    incorrectCount: 10,
    skippedCount: 0,
    calculatedAt: DateTime.utc(2026, 8, 10),
    testName: 'Mock Test',
  );
}
