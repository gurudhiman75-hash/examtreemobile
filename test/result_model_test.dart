import 'package:examtree/core/models/result_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result.fromJson', () {
    test('parses canonical question review and summary fields', () {
      final result = Result.fromJson({
        'id': '7e1d6a4d-d245-4e73-87f4-9e844cf1d2cf',
        'userId': 'student-1',
        'testId': 'test-1',
        'testName': 'SSC Practice Test',
        'category': 'SSC',
        'score': 50,
        'actualScore': 1.5,
        'correct': 1,
        'wrong': 1,
        'unanswered': 1,
        'totalQuestions': 3,
        'submittedAt': '2026-07-26T02:00:00.000Z',
        'sectionStats': [
          {
            'name': 'Quantitative Aptitude',
            'correct': 1,
            'wrong': 1,
            'unanswered': 1,
            'totalQuestions': 3,
            'accuracy': 50,
          },
        ],
        'questionReview': [
          {
            'questionId': 101,
            'questionVersionId': 'question-version-1',
            'testQuestionId': 'test-1:question-version-1',
            'testSectionId': 'section-1',
            'section': 'Quantitative Aptitude',
            'text': 'What is 2 + 2?',
            'options': ['3', '4', '5', '6'],
            'optionKeys': ['A', 'B', 'C', 'D'],
            'selected': 1,
            'selectedOptionKey': 'B',
            'correct': 1,
            'correctOptionKey': 'B',
            'timeTakenSeconds': 14,
            'flagged': true,
            'explanation': 'Two plus two equals four.',
          },
          {
            'questionId': 102,
            'questionVersionId': 'question-version-2',
            'testQuestionId': 'test-1:question-version-2',
            'testSectionId': 'section-1',
            'section': 'Quantitative Aptitude',
            'text': 'What is 3 + 3?',
            'options': ['5', '6', '7', '8'],
            'selected': null,
            'correct': 1,
            'correctOptionKey': 'B',
            'flagged': false,
            'explanation': '',
          },
        ],
      });

      expect(result.attemptId, '7e1d6a4d-d245-4e73-87f4-9e844cf1d2cf');
      expect(result.testName, 'SSC Practice Test');
      expect(result.percentageScore, 50);
      expect(result.rawScore, 1.5);
      expect(result.accuracy, 50);
      expect(result.questionReview, hasLength(2));
      expect(result.sectionStats.single.name, 'Quantitative Aptitude');

      final answered = result.questionReview.first;
      expect(answered.selected, 1);
      expect(answered.isAnswered, isTrue);
      expect(answered.isCorrect, isTrue);
      expect(answered.flagged, isTrue);
      expect(answered.timeTakenSeconds, 14);

      final unanswered = result.questionReview.last;
      expect(unanswered.selected, isNull);
      expect(unanswered.isAnswered, isFalse);
      expect(unanswered.isCorrect, isFalse);
      expect(unanswered.optionKeys, ['A', 'B', 'C', 'D']);
    });

    test('calculates accuracy when the API omits it', () {
      final result = Result.fromJson({
        'id': 'attempt-2',
        'testId': 'test-2',
        'actualScore': 2,
        'correct': 2,
        'wrong': 1,
        'unanswered': 1,
        'totalQuestions': 4,
      });

      expect(result.accuracy, closeTo(66.666, 0.01));
      expect(result.percentageScore, 50);
    });
  });
}
