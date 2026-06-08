// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Exam _$ExamFromJson(Map<String, dynamic> json) => _Exam(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  durationInSeconds: (json['durationInSeconds'] as num).toInt(),
  totalQuestions: (json['totalQuestions'] as num).toInt(),
  totalMarks: (json['totalMarks'] as num).toDouble(),
  maxAttempts: (json['maxAttempts'] as num).toInt(),
  negativeMarking: (json['negativeMarking'] as num).toDouble(),
  difficulty: json['difficulty'] as String,
  status: json['status'] as String,
  category: json['category'] as String,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ExamToJson(_Exam instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'durationInSeconds': instance.durationInSeconds,
  'totalQuestions': instance.totalQuestions,
  'totalMarks': instance.totalMarks,
  'maxAttempts': instance.maxAttempts,
  'negativeMarking': instance.negativeMarking,
  'difficulty': instance.difficulty,
  'status': instance.status,
  'category': instance.category,
  'tags': instance.tags,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
