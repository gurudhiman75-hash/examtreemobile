import 'package:examtree/core/models/exam_api_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('published test maxAttempts flows into the Exam model', () {
    final dto = TestDto.fromJson({
      'id': 'test-1',
      'name': 'SSC Mock',
      'category': 'SSC',
      'categoryId': 'ssc',
      'duration': 60,
      'totalQuestions': 100,
      'attempts': 2,
      'avgScore': 62,
      'difficulty': 'Medium',
      'sections': const [],
      'maxAttempts': 3,
    });

    expect(dto.maxAttempts, 3);
    expect(dto.toExam().maxAttempts, 3);
  });

  test('missing or invalid maxAttempts keeps the safe legacy fallback', () {
    final missing = TestDto.fromJson({
      'id': 'test-1',
      'name': 'SSC Mock',
      'category': 'SSC',
      'categoryId': 'ssc',
      'duration': 60,
      'totalQuestions': 100,
      'attempts': 0,
      'avgScore': 0,
      'difficulty': 'Medium',
      'sections': const [],
    });
    final invalid = TestDto.fromJson({
      'id': 'test-2',
      'name': 'Bank Mock',
      'category': 'BANK',
      'categoryId': 'bank',
      'duration': 60,
      'totalQuestions': 100,
      'attempts': 0,
      'avgScore': 0,
      'difficulty': 'Medium',
      'sections': const [],
      'maxAttempts': 0,
    });

    expect(missing.toExam().maxAttempts, 99);
    expect(invalid.toExam().maxAttempts, 99);
  });
}
