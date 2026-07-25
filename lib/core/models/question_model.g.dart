// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Question _$QuestionFromJson(Map<String, dynamic> json) => _Question(
  id: (json['id'] as num).toInt(),
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
  textHi: json['textHi'] as String?,
  optionsHi:
      (json['optionsHi'] as List<dynamic>?)?.map((e) => e as String).toList(),
  explanationHi: json['explanationHi'] as String?,
  textPa: json['textPa'] as String?,
  optionsPa:
      (json['optionsPa'] as List<dynamic>?)?.map((e) => e as String).toList(),
  explanationPa: json['explanationPa'] as String?,
  seatingDiagram: json['seatingDiagram'] as Map<String, dynamic>?,
  seatingExplanationFlow:
      json['seatingExplanationFlow'] as Map<String, dynamic>?,
  imageUrl: json['imageUrl'] as String?,
  questionType: json['questionType'] as String?,
  diSetId: (json['diSetId'] as num?)?.toInt(),
  diSetTitle: json['diSetTitle'] as String?,
  diSetImageUrl: json['diSetImageUrl'] as String?,
  diSetDescription: json['diSetDescription'] as String?,
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
  'textHi': instance.textHi,
  'optionsHi': instance.optionsHi,
  'explanationHi': instance.explanationHi,
  'textPa': instance.textPa,
  'optionsPa': instance.optionsPa,
  'explanationPa': instance.explanationPa,
  'seatingDiagram': instance.seatingDiagram,
  'seatingExplanationFlow': instance.seatingExplanationFlow,
  'imageUrl': instance.imageUrl,
  'questionType': instance.questionType,
  'diSetId': instance.diSetId,
  'diSetTitle': instance.diSetTitle,
  'diSetImageUrl': instance.diSetImageUrl,
  'diSetDescription': instance.diSetDescription,
};
