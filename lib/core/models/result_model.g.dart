// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Result _$ResultFromJson(Map<String, dynamic> json) => _Result(
  id: json['id'] as String,
  attemptId: json['attemptId'] as String,
  userId: json['userId'] as String,
  examId: json['examId'] as String,
  score: (json['score'] as num).toDouble(),
  maxScore: (json['maxScore'] as num).toDouble(),
  accuracy: (json['accuracy'] as num).toDouble(),
  correctCount: (json['correctCount'] as num).toInt(),
  incorrectCount: (json['incorrectCount'] as num).toInt(),
  skippedCount: (json['skippedCount'] as num).toInt(),
  rank: (json['rank'] as num?)?.toInt(),
  percentile: (json['percentile'] as num?)?.toDouble(),
  calculatedAt: DateTime.parse(json['calculatedAt'] as String),
);

Map<String, dynamic> _$ResultToJson(_Result instance) => <String, dynamic>{
  'id': instance.id,
  'attemptId': instance.attemptId,
  'userId': instance.userId,
  'examId': instance.examId,
  'score': instance.score,
  'maxScore': instance.maxScore,
  'accuracy': instance.accuracy,
  'correctCount': instance.correctCount,
  'incorrectCount': instance.incorrectCount,
  'skippedCount': instance.skippedCount,
  'rank': instance.rank,
  'percentile': instance.percentile,
  'calculatedAt': instance.calculatedAt.toIso8601String(),
};
