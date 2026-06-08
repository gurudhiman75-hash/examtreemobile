import 'package:freezed_annotation/freezed_annotation.dart';

part 'attempt_model.freezed.dart';
part 'attempt_model.g.dart';

enum AttemptStatus { inProgress, paused, completed, abandoned }
enum SyncStatus { pending, synced, error }
enum QuestionAttemptStatus { answered, markedForReview, skipped }

@freezed
abstract class AttemptResponse with _$AttemptResponse {
  const factory AttemptResponse({
    required String questionId,
    required List<int> selectedOptionIndexes,
    required QuestionAttemptStatus status,
    required int timeSpentInSeconds,
  }) = _AttemptResponse;

  factory AttemptResponse.fromJson(Map<String, dynamic> json) => _$AttemptResponseFromJson(json);
}

@freezed
abstract class Attempt with _$Attempt {
  const factory Attempt({
    required String id,
    required String userId,
    required String examId,
    required int attemptNumber,
    required AttemptStatus status,
    required DateTime startTime,
    DateTime? endTime,
    required int timeRemainingInSeconds,
    @Default({}) Map<String, AttemptResponse> responses,
    required SyncStatus syncStatus,
    DateTime? lastSyncedAt,
  }) = _Attempt;

  factory Attempt.fromJson(Map<String, dynamic> json) => _$AttemptFromJson(json);
}
