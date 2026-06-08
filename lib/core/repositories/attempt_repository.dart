import '../models/attempt_model.dart';

abstract class AttemptRepository {
  Future<Attempt> startAttempt(String examId, String userId);
  Future<Attempt> getActiveAttempt(String examId, String userId);
  Future<Attempt> getAttempt(String attemptId);
  Future<void> saveAttemptProgress(Attempt attempt);
  Future<void> submitAttempt(String attemptId);
}
