// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attempt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttemptResponse _$AttemptResponseFromJson(Map<String, dynamic> json) =>
    _AttemptResponse(
      questionId: json['questionId'] as String,
      selectedOptionIndexes: (json['selectedOptionIndexes'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      status: $enumDecode(_$QuestionAttemptStatusEnumMap, json['status']),
      timeSpentInSeconds: (json['timeSpentInSeconds'] as num).toInt(),
    );

Map<String, dynamic> _$AttemptResponseToJson(_AttemptResponse instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'selectedOptionIndexes': instance.selectedOptionIndexes,
      'status': _$QuestionAttemptStatusEnumMap[instance.status]!,
      'timeSpentInSeconds': instance.timeSpentInSeconds,
    };

const _$QuestionAttemptStatusEnumMap = {
  QuestionAttemptStatus.answered: 'answered',
  QuestionAttemptStatus.markedForReview: 'markedForReview',
  QuestionAttemptStatus.skipped: 'skipped',
};

_Attempt _$AttemptFromJson(Map<String, dynamic> json) => _Attempt(
  id: json['id'] as String,
  userId: json['userId'] as String,
  examId: json['examId'] as String,
  attemptNumber: (json['attemptNumber'] as num).toInt(),
  status: $enumDecode(_$AttemptStatusEnumMap, json['status']),
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  timeRemainingInSeconds: (json['timeRemainingInSeconds'] as num).toInt(),
  responses:
      (json['responses'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, AttemptResponse.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  syncStatus: $enumDecode(_$SyncStatusEnumMap, json['syncStatus']),
  lastSyncedAt: json['lastSyncedAt'] == null
      ? null
      : DateTime.parse(json['lastSyncedAt'] as String),
);

Map<String, dynamic> _$AttemptToJson(_Attempt instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'examId': instance.examId,
  'attemptNumber': instance.attemptNumber,
  'status': _$AttemptStatusEnumMap[instance.status]!,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
  'timeRemainingInSeconds': instance.timeRemainingInSeconds,
  'responses': instance.responses,
  'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
  'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
};

const _$AttemptStatusEnumMap = {
  AttemptStatus.inProgress: 'inProgress',
  AttemptStatus.paused: 'paused',
  AttemptStatus.completed: 'completed',
  AttemptStatus.abandoned: 'abandoned',
};

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.synced: 'synced',
  SyncStatus.error: 'error',
};
