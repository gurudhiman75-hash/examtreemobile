// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attempt_draft_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttemptDraftState _$AttemptDraftStateFromJson(Map<String, dynamic> json) =>
    _AttemptDraftState(
      currentQuestionIndex: (json['currentQuestionIndex'] as num).toInt(),
      currentSectionIndex: (json['currentSectionIndex'] as num?)?.toInt() ?? 0,
      answers:
          (json['answers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num?)?.toInt()),
          ) ??
          const {},
      flags:
          (json['flags'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const {},
      timeLeft: (json['timeLeft'] as num).toInt(),
      sectionTimeLeftByName:
          (json['sectionTimeLeftByName'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      lockedSections:
          (json['lockedSections'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      sectionCompletionTimes:
          (json['sectionCompletionTimes'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ),
      visitedQuestionIds: (json['visitedQuestionIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      updatedAt: (json['updatedAt'] as num).toInt(),
    );

Map<String, dynamic> _$AttemptDraftStateToJson(_AttemptDraftState instance) =>
    <String, dynamic>{
      'currentQuestionIndex': instance.currentQuestionIndex,
      'currentSectionIndex': instance.currentSectionIndex,
      'answers': instance.answers,
      'flags': instance.flags,
      'timeLeft': instance.timeLeft,
      'sectionTimeLeftByName': instance.sectionTimeLeftByName,
      'lockedSections': instance.lockedSections,
      'sectionCompletionTimes': instance.sectionCompletionTimes,
      'visitedQuestionIds': instance.visitedQuestionIds,
      'updatedAt': instance.updatedAt,
    };

_AttemptDraft _$AttemptDraftFromJson(Map<String, dynamic> json) =>
    _AttemptDraft(
      draftId: json['id'] as String,
      testId: json['testId'] as String,
      testName: json['testName'] as String,
      category: json['category'] as String,
      attemptType: json['attemptType'] as String,
      originalAttemptId: json['originalAttemptId'] as String?,
      state: AttemptDraftState.fromJson(json['state'] as Map<String, dynamic>),
      version: (json['version'] as num).toInt(),
      status:
          $enumDecodeNullable(_$AttemptDraftStatusEnumMap, json['status']) ??
          AttemptDraftStatus.inProgress,
      lastDevice: json['lastDevice'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$AttemptDraftToJson(_AttemptDraft instance) =>
    <String, dynamic>{
      'id': instance.draftId,
      'testId': instance.testId,
      'testName': instance.testName,
      'category': instance.category,
      'attemptType': instance.attemptType,
      'originalAttemptId': instance.originalAttemptId,
      'state': instance.state,
      'version': instance.version,
      'status': _$AttemptDraftStatusEnumMap[instance.status]!,
      'lastDevice': instance.lastDevice,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };

const _$AttemptDraftStatusEnumMap = {
  AttemptDraftStatus.inProgress: 'in_progress',
  AttemptDraftStatus.paused: 'paused',
};

_AttemptDraftListResponse _$AttemptDraftListResponseFromJson(
  Map<String, dynamic> json,
) => _AttemptDraftListResponse(
  drafts:
      (json['drafts'] as List<dynamic>?)
          ?.map((e) => AttemptDraft.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$AttemptDraftListResponseToJson(
  _AttemptDraftListResponse instance,
) => <String, dynamic>{'drafts': instance.drafts};

_SaveAttemptDraftResult _$SaveAttemptDraftResultFromJson(
  Map<String, dynamic> json,
) => _SaveAttemptDraftResult(
  draftId: json['id'] as String,
  version: (json['version'] as num).toInt(),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SaveAttemptDraftResultToJson(
  _SaveAttemptDraftResult instance,
) => <String, dynamic>{
  'id': instance.draftId,
  'version': instance.version,
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
