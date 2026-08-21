import 'package:examtree/core/models/exam_model.dart';
import 'package:examtree/features/home/presentation/home_exam_priority.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 21, 8);

  Exam exam(String id, String code) => Exam(
        id: id,
        title: id,
        description: '$id description',
        durationInSeconds: 3600,
        totalQuestions: 100,
        totalMarks: 100,
        maxAttempts: 10,
        negativeMarking: 0.25,
        difficulty: 'Medium',
        status: 'published',
        category: 'SSC',
        tags: ['exam-code:$code'],
        createdAt: now,
        updatedAt: now,
      );

  test('selected exam codes are moved first in learner order', () {
    final result = prioritizeHomeExams(
      exams: [
        exam('railways', 'RRB_NTPC'),
        exam('cgl-1', 'SSC_CGL'),
        exam('bank', 'IBPS_PO'),
        exam('cgl-2', 'SSC_CGL'),
      ],
      selectedExamCodes: const ['IBPS_PO', 'SSC_CGL'],
    );

    expect(
      result.map((item) => item.id),
      ['bank', 'cgl-1', 'cgl-2', 'railways'],
    );
    expect(result.take(3).every(isHomeSelectedExam), isTrue);
    expect(isHomeSelectedExam(result.last), isFalse);
  });

  test('empty selections preserve existing catalogue order and tags', () {
    final source = [exam('one', 'SSC_CGL'), exam('two', 'RRB_NTPC')];
    final result = prioritizeHomeExams(
      exams: source,
      selectedExamCodes: const [],
    );

    expect(result.map((item) => item.id), ['one', 'two']);
    expect(result.any(isHomeSelectedExam), isFalse);
  });

  test('canonical exam code lookup ignores unrelated tags', () {
    final target = exam('one', 'SSC_CGL').copyWith(
      tags: const ['free', 'full-length', 'exam-code:SSC_CGL'],
    );

    expect(canonicalExamCodeFor(target), 'SSC_CGL');
  });
}
