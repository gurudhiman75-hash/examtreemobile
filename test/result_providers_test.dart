import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/features/results/presentation/providers/result_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('countCompletedAttemptsForTest', () {
    test('counts only attempts for the requested canonical test', () {
      final results = [
        _result('attempt-1', 'test-a'),
        _result('attempt-2', 'test-b'),
        _result('attempt-3', 'test-a'),
      ];

      expect(countCompletedAttemptsForTest(results, 'test-a'), 2);
      expect(countCompletedAttemptsForTest(results, 'test-b'), 1);
      expect(countCompletedAttemptsForTest(results, 'test-c'), 0);
    });

    test('rejects a blank test identifier', () {
      expect(countCompletedAttemptsForTest([_result('a', 'test-a')], '  '), 0);
    });
  });
}

Result _result(String attemptId, String testId) {
  return Result(
    id: attemptId,
    attemptId: attemptId,
    userId: 'student-1',
    examId: testId,
    score: 0,
    maxScore: 0,
    accuracy: 0,
    correctCount: 0,
    incorrectCount: 0,
    skippedCount: 0,
    calculatedAt: DateTime.utc(2026, 7, 26),
  );
}
