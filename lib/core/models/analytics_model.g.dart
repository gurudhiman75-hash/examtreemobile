// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Analytics _$AnalyticsFromJson(Map<String, dynamic> json) => _Analytics(
  id: json['id'] as String,
  userId: json['userId'] as String,
  totalTestsAttempted: (json['totalTestsAttempted'] as num).toInt(),
  averageScore: (json['averageScore'] as num).toDouble(),
  averageAccuracy: (json['averageAccuracy'] as num).toDouble(),
  topicPerformance:
      (json['topicPerformance'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  strongestTopics:
      (json['strongestTopics'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  weakestTopics:
      (json['weakestTopics'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  averageTimePerQuestion: (json['averageTimePerQuestion'] as num).toInt(),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AnalyticsToJson(_Analytics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'totalTestsAttempted': instance.totalTestsAttempted,
      'averageScore': instance.averageScore,
      'averageAccuracy': instance.averageAccuracy,
      'topicPerformance': instance.topicPerformance,
      'strongestTopics': instance.strongestTopics,
      'weakestTopics': instance.weakestTopics,
      'averageTimePerQuestion': instance.averageTimePerQuestion,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
