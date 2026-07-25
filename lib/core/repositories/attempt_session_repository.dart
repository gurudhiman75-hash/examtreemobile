import '../models/attempt_session_model.dart';

abstract class AttemptSessionRepository {
  Future<AttemptSession> startOrResume({
    required String testId,
    String? seriesId,
  });

  Future<AttemptSession> getSession(String attemptId);

  Future<AttemptSession> saveSession({
    required String attemptId,
    required int expectedRevision,
    required AttemptSessionState state,
  });

  Future<AttemptSubmitResponse> submitAttempt({
    required String attemptId,
    required String testId,
    required int timeSpentMinutes,
    required List<AttemptResponsePayload> responses,
    required Map<String, bool> flags,
    String attemptType = 'REAL',
    String? seriesId,
  });
}
