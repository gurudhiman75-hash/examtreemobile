import '../models/attempt_model.dart';
import 'attempt_repository.dart';

class MockAttemptRepository implements AttemptRepository {
  final Map<String, Attempt> _attempts = {};

  @override
  Future<Attempt> startAttempt(String examId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final attempt = Attempt(
      id: 'attempt_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      examId: examId,
      attemptNumber: 1,
      status: AttemptStatus.inProgress,
      startTime: DateTime.now(),
      timeRemainingInSeconds: 7200,
      syncStatus: SyncStatus.pending,
    );
    _attempts[attempt.id] = attempt;
    return attempt;
  }

  @override
  Future<Attempt> getActiveAttempt(String examId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _attempts.values.firstWhere(
      (a) => a.examId == examId && a.userId == userId && a.status == AttemptStatus.inProgress,
      orElse: () => throw Exception('No active attempt found for this exam.'),
    );
  }

  @override
  Future<Attempt> getAttempt(String attemptId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_attempts.containsKey(attemptId)) {
      return _attempts[attemptId]!;
    }
    throw Exception('Attempt not found.');
  }

  @override
  Future<void> saveAttemptProgress(Attempt attempt) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _attempts[attempt.id] = attempt;
  }

  @override
  Future<void> submitAttempt(String attemptId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (_attempts.containsKey(attemptId)) {
      _attempts[attemptId] = _attempts[attemptId]!.copyWith(
        status: AttemptStatus.completed,
        endTime: DateTime.now(),
      );
    }
  }
}
