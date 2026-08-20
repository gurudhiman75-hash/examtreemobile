import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/features/results/presentation/review_retry_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('review learning handoff', () {
    test('hides revision action when no result is available', () {
      expect(shouldOfferRevisionAction(null), isFalse);
    });

    test('shows revision action for an incorrect reviewed question', () {
      expect(shouldOfferRevisionAction(_result(selected: 1)), isTrue);
    });

    test('hides revision action when every reviewed question is clean', () {
      expect(shouldOfferRevisionAction(_result(selected: 0)), isFalse);
    });
  });
}

Result _result({required int selected}) {
  return Result(
    id: 'attempt-1',
    attemptId: 'attempt-1',
    userId: 'user-1',
    examId: 'exam-1',
    score: selected == 0 ? 20 : 0,
    maxScore: 20,
    accuracy: selected == 0 ? 100 : 0,
    correctCount: selected == 0 ? 1 : 0,
    incorrectCount: selected == 0 ? 0 : 1,
    skippedCount: 0,
    calculatedAt: DateTime.utc(2026, 8, 10),
    testName: 'Mock Test',
    questionReview: [
      ResultQuestionReview(
        questionId: 1,
        questionVersionId: 'qv-1',
        testQuestionId: 'tq-1',
        testSectionId: 'section-1',
        section: 'Quantitative Aptitude',
        text: 'Sample question',
        options: const ['A', 'B'],
        optionKeys: const ['A', 'B'],
        selected: selected,
        selectedOptionKey: selected == 0 ? 'A' : 'B',
        correct: 0,
        correctOptionKey: 'A',
        timeTakenSeconds: 30,
        flagged: false,
        explanation: 'A is correct.',
      ),
    ],
  );
}
