import 'package:flutter_test/flutter_test.dart';

import 'package:examtree/core/models/exam_api_dto.dart';
import 'package:examtree/core/repositories/attempt_draft_repository.dart';

void main() {
  group('mobile API contracts', () {
    test('test detail payload maps to canonical exam and questions', () {
      final dto = TestDto.fromJson({
        'id': 'test-1',
        'name': 'Sample Test',
        'category': 'SSC',
        'categoryId': 'ssc',
        'duration': 30,
        'totalQuestions': 1,
        'attempts': 0,
        'avgScore': 0,
        'difficulty': 'Medium',
        'marksPerQuestion': 2,
        'negativeMarks': 0.5,
        'sections': [
          {
            'id': 'quant',
            'name': 'Quantitative Aptitude',
            'questions': [
              {
                'id': 101,
                'text': 'What is 2 + 2?',
                'options': ['3', '4', '5', '6'],
                'correct': 1,
                'section': 'Quantitative Aptitude',
                'explanation': '2 + 2 = 4.',
                'textHi': '2 + 2 कितना है?',
                'optionsHi': ['3', '4', '5', '6'],
              },
            ],
          },
        ],
      });

      final exam = dto.toExam();
      final questions = dto.toQuestions();

      expect(exam.id, 'test-1');
      expect(exam.durationInSeconds, 1800);
      expect(exam.totalMarks, 2);
      expect(exam.negativeMarking, 0.5);
      expect(questions, hasLength(1));
      expect(questions.single.id, 101);
      expect(questions.single.correctOptionIndexes, [1]);
      expect(questions.single.textHi, '2 + 2 कितना है?');
    });

    test('attempt submission serializes numeric question IDs as numbers', () {
      const payload = AttemptDraftResponsePayload(
        questionId: '101',
        selectedOption: 2,
        timeTaken: 14,
      );

      expect(payload.toJson(), {
        'questionId': 101,
        'selectedOption': 2,
        'timeTaken': 14,
      });
    });
  });
}
