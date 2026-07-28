import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/features/results/presentation/review_question_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ResultQuestionReview question({
    required int id,
    required int? selected,
    required int correct,
    bool flagged = false,
  }) {
    return ResultQuestionReview(
      questionId: id,
      questionVersionId: 'version-$id',
      testQuestionId: 'test-question-$id',
      testSectionId: 'section-1',
      section: 'Reasoning',
      text: 'Question $id',
      options: const ['A', 'B', 'C', 'D'],
      optionKeys: const ['A', 'B', 'C', 'D'],
      selected: selected,
      selectedOptionKey: selected == null ? null : String.fromCharCode(65 + selected),
      correct: correct,
      correctOptionKey: String.fromCharCode(65 + correct),
      timeTakenSeconds: 20,
      flagged: flagged,
      explanation: 'Explanation',
    );
  }

  late List<ResultQuestionReview> questions;

  setUp(() {
    questions = [
      question(id: 1, selected: 0, correct: 0),
      question(id: 2, selected: 1, correct: 2),
      question(id: 3, selected: null, correct: 3, flagged: true),
      question(id: 4, selected: 2, correct: 1, flagged: true),
    ];
  });

  test('all filter preserves canonical question order', () {
    expect(
      reviewQuestionIndexes(questions, ReviewQuestionFilter.all),
      [0, 1, 2, 3],
    );
  });

  test('incorrect filter excludes correct and unanswered questions', () {
    expect(
      reviewQuestionIndexes(questions, ReviewQuestionFilter.incorrect),
      [1, 3],
    );
  });

  test('unanswered filter returns only unanswered questions', () {
    expect(
      reviewQuestionIndexes(questions, ReviewQuestionFilter.unanswered),
      [2],
    );
  });

  test('flagged filter can include answered and unanswered questions', () {
    expect(
      reviewQuestionIndexes(questions, ReviewQuestionFilter.flagged),
      [2, 3],
    );
  });

  test('count helper matches filtered indexes', () {
    for (final filter in ReviewQuestionFilter.values) {
      expect(
        reviewQuestionCount(questions, filter),
        reviewQuestionIndexes(questions, filter).length,
      );
    }
  });
}
