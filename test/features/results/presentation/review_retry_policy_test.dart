import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/features/results/presentation/review_retry_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Result resultWithQuestion({required bool correct}) {
    return Result(
      id: 'result-1',
      attemptId: 'attempt-1',
      userId: 'student-1',
      examId: 'exam-1',
      score: correct ? 1 : 0,
      maxScore: 1,
      accuracy: correct ? 100 : 0,
      correctCount: correct ? 1 : 0,
      incorrectCount: correct ? 0 : 1,
      skippedCount: 0,
      calculatedAt: DateTime(2026, 8, 20),
      testName: 'Practice test',
      percentageScore: correct ? 100 : 0,
      rawScore: correct ? 1 : 0,
      totalQuestions: 1,
      questionReview: [
        ResultQuestionReview(
          questionId: 1,
          questionVersionId: 'qv-1',
          testQuestionId: 'tq-1',
          testSectionId: 'section-1',
          section: 'Reasoning',
          text: 'Sample question',
          options: const ['A', 'B'],
          optionKeys: const ['A', 'B'],
          selected: correct ? 0 : 1,
          selectedOptionKey: correct ? 'A' : 'B',
          correct: 0,
          correctOptionKey: 'A',
          timeTakenSeconds: 30,
          flagged: false,
          explanation: 'A is correct.',
        ),
      ],
    );
  }

  test('review learning action becomes compact when navigation stacks', () {
    expect(useCompactReviewLearningAction(1), isFalse);
    expect(useCompactReviewLearningAction(1.49), isFalse);
    expect(useCompactReviewLearningAction(1.5), isTrue);
    expect(useCompactReviewLearningAction(2), isTrue);
  });

  test('large-text learning action clears the taller review navigation', () {
    expect(
      reviewLearningBottomOffset(textScale: 1, safeBottom: 24),
      112,
    );
    expect(
      reviewLearningBottomOffset(textScale: 2, safeBottom: 24),
      180,
    );
  });

  test('revision handoff appears only when the result has revision candidates', () {
    expect(shouldOfferRevisionAction(null), isFalse);
    expect(shouldOfferRevisionAction(resultWithQuestion(correct: true)), isFalse);
    expect(shouldOfferRevisionAction(resultWithQuestion(correct: false)), isTrue);
  });
}
