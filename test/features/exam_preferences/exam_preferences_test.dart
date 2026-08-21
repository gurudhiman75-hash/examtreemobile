import 'package:examtree/features/exam_preferences/domain/exam_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canonical catalogue parser keeps family, languages and live-test truth', () {
    final catalogue = ExamTargetCatalogue.fromJson({
      'maxSelectedExams': 12,
      'families': [
        {
          'id': 'family-1',
          'code': 'SSC',
          'name': 'SSC',
          'description': 'Staff Selection Commission',
          'examCount': 2,
        },
      ],
      'exams': [
        {
          'id': 'exam-1',
          'familyId': 'family-1',
          'code': 'SSC_CGL',
          'name': 'SSC CGL',
          'description': 'Combined Graduate Level',
          'currentVersionId': 'version-1',
          'liveTestCount': 4,
          'languages': [
            {
              'code': 'en',
              'name': 'English',
              'nativeName': 'English',
              'isPrimary': true,
            },
            {
              'code': 'hi',
              'name': 'Hindi',
              'nativeName': 'हिन्दी',
              'isPrimary': false,
            },
          ],
        },
      ],
    });

    expect(catalogue.families.single.name, 'SSC');
    expect(catalogue.exams.single.name, 'SSC CGL');
    expect(catalogue.exams.single.hasLiveTests, isTrue);
    expect(catalogue.exams.single.languages.map((item) => item.code), ['en', 'hi']);
    expect(catalogue.maxSelectedExams, 12);
  });

  test('selected exams preserve server order and ignore unavailable IDs', () {
    const examA = SelectableExamTarget(
      id: 'a',
      familyId: 'f',
      code: 'A',
      name: 'Exam A',
      description: '',
      currentVersionId: 'v1',
      languages: [],
      liveTestCount: 1,
    );
    const examB = SelectableExamTarget(
      id: 'b',
      familyId: 'f',
      code: 'B',
      name: 'Exam B',
      description: '',
      currentVersionId: 'v2',
      languages: [],
      liveTestCount: 0,
    );
    const snapshot = ExamPreferenceSnapshot(
      catalogue: ExamTargetCatalogue(
        families: [],
        exams: [examA, examB],
        maxSelectedExams: 12,
      ),
      preferences: LearnerExamPreferences(
        selectedExamIds: ['b', 'missing', 'a'],
        maxSelectedExams: 12,
      ),
    );

    expect(snapshot.selectedExams.map((exam) => exam.id), ['b', 'a']);
  });
}
