import 'package:flutter_test/flutter_test.dart';

import 'package:examtree/core/models/attempt_draft_model.dart';
import 'package:examtree/core/models/exam_api_dto.dart';
import 'package:examtree/core/repositories/attempt_draft_repository.dart';
import 'package:examtree/features/test_attempt/presentation/providers/draft_providers.dart';

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

    test('autosave cannot overwrite a draft before resume is resolved', () async {
      final repository = _FakeAttemptDraftRepository(
        existingDraft: AttemptDraft(
          draftId: 'draft-1',
          testId: 'test-1',
          testName: 'Sample Test',
          category: 'SSC',
          attemptType: 'REAL',
          state: _sampleState,
          version: 3,
        ),
      );
      final controller = DraftSaveController(repository);

      await expectLater(
        controller.save(
          testId: 'test-1',
          testName: 'Sample Test',
          category: 'SSC',
          state: _sampleState,
        ),
        throwsA(isA<ExistingAttemptDraftRequiresResolution>()),
      );
      expect(repository.saveCalls, 0);
    });
  });
}

const _sampleState = AttemptDraftState(
  currentQuestionIndex: 0,
  answers: {},
  flags: {},
  timeLeft: 1200,
  updatedAt: 1,
);

class _FakeAttemptDraftRepository implements AttemptDraftRepository {
  _FakeAttemptDraftRepository({this.existingDraft});

  AttemptDraft? existingDraft;
  int saveCalls = 0;

  @override
  Future<AttemptDraft?> getDraft(String testId) async => existingDraft;

  @override
  Future<List<AttemptDraft>> listDrafts() async => [
        if (existingDraft != null) existingDraft!,
      ];

  @override
  Future<SaveAttemptDraftResult> saveDraft({
    required String testId,
    required String testName,
    required String category,
    required AttemptDraftState state,
    String attemptType = 'REAL',
    String? originalAttemptId,
    int? expectedVersion,
    AttemptDraftStatus status = AttemptDraftStatus.inProgress,
    String lastDevice = 'android',
  }) async {
    saveCalls++;
    return const SaveAttemptDraftResult(draftId: 'draft-new', version: 1);
  }

  @override
  Future<void> deleteDraft(String draftId) async {
    existingDraft = null;
  }

  @override
  Future<AttemptDraftSubmitResponse> submitAttempt({
    required String testId,
    required String testName,
    required String category,
    required int timeSpent,
    required List<AttemptDraftResponsePayload> responses,
    Map<String, bool> flags = const {},
    String attemptType = 'REAL',
    String? draftId,
    int? expectedDraftVersion,
  }) async {
    return const AttemptDraftSubmitResponse(attemptId: 'attempt-1');
  }
}
