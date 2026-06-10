import '../models/attempt_draft_model.dart';

class AttemptDraftSubmitResponse {
  const AttemptDraftSubmitResponse({required this.attemptId});

  final String attemptId;
}

class AttemptDraftResponsePayload {
  const AttemptDraftResponsePayload({
    required this.questionId,
    required this.selectedOption,
    this.timeTaken = 0,
  });

  final String questionId;
  final int? selectedOption;
  final int timeTaken;

  Map<String, dynamic> toJson() => {
    'questionId': int.tryParse(questionId) ?? questionId,
    'selectedOption': selectedOption,
    'timeTaken': timeTaken,
  };
}

abstract class AttemptDraftRepository {
  Future<AttemptDraft?> getDraft(String testId);
  Future<List<AttemptDraft>> listDrafts();
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
  });
  Future<void> deleteDraft(String draftId);
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
  });
}
