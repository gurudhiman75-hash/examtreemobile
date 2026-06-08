// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Question _$QuestionFromJson(Map<String, dynamic> json) => _Question(
  id: json['id'] as String,
  examId: json['examId'] as String,
  subject: json['subject'] as String,
  topic: json['topic'] as String,
  difficulty: json['difficulty'] as String,
  text: json['text'] as String,
  options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
  correctOptionIndexes: (json['correctOptionIndexes'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  explanation: json['explanation'] as String,
  points: (json['points'] as num).toDouble(),
);

Map<String, dynamic> _$QuestionToJson(_Question instance) => <String, dynamic>{
  'id': instance.id,
  'examId': instance.examId,
  'subject': instance.subject,
  'topic': instance.topic,
  'difficulty': instance.difficulty,
  'text': instance.text,
  'options': instance.options,
  'correctOptionIndexes': instance.correctOptionIndexes,
  'explanation': instance.explanation,
  'points': instance.points,
};
