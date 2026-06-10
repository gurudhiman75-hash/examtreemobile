// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'attempt_draft_model.freezed.dart';
part 'attempt_draft_model.g.dart';

enum AttemptDraftStatus {
  @JsonValue('in_progress')
  inProgress,
  paused,
}

@freezed
abstract class AttemptDraftState with _$AttemptDraftState {
  const factory AttemptDraftState({
    required int currentQuestionIndex,
    @Default(0) int currentSectionIndex,
    @Default({}) Map<String, int?> answers,
    @Default({}) Map<String, bool> flags,
    required int timeLeft,
    @Default({}) Map<String, int> sectionTimeLeftByName,
    @Default([]) List<int> lockedSections,
    Map<String, int>? sectionCompletionTimes,
    List<int>? visitedQuestionIds,
    required int updatedAt,
  }) = _AttemptDraftState;

  factory AttemptDraftState.fromJson(Map<String, dynamic> json) =>
      _$AttemptDraftStateFromJson(json);
}

@freezed
abstract class AttemptDraft with _$AttemptDraft {
  const factory AttemptDraft({
    @JsonKey(name: 'id') required String draftId,
    required String testId,
    required String testName,
    required String category,
    required String attemptType,
    String? originalAttemptId,
    required AttemptDraftState state,
    required int version,
    @Default(AttemptDraftStatus.inProgress) AttemptDraftStatus status,
    String? lastDevice,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
  }) = _AttemptDraft;

  factory AttemptDraft.fromJson(Map<String, dynamic> json) =>
      _$AttemptDraftFromJson(json);
}

@freezed
abstract class AttemptDraftListResponse with _$AttemptDraftListResponse {
  const factory AttemptDraftListResponse({
    @Default([]) List<AttemptDraft> drafts,
  }) = _AttemptDraftListResponse;

  factory AttemptDraftListResponse.fromJson(Map<String, dynamic> json) =>
      _$AttemptDraftListResponseFromJson(json);
}

@freezed
abstract class SaveAttemptDraftResult with _$SaveAttemptDraftResult {
  const factory SaveAttemptDraftResult({
    @JsonKey(name: 'id') required String draftId,
    required int version,
    DateTime? updatedAt,
  }) = _SaveAttemptDraftResult;

  factory SaveAttemptDraftResult.fromJson(Map<String, dynamic> json) =>
      _$SaveAttemptDraftResultFromJson(json);
}
