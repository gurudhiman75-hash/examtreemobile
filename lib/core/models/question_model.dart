import 'package:freezed_annotation/freezed_annotation.dart';

part 'question_model.freezed.dart';
part 'question_model.g.dart';

@freezed
abstract class Question with _$Question {
  const factory Question({
    required String id,
    required String examId,
    required String subject,
    required String topic,
    required String difficulty,
    required String text,
    required List<String> options,
    required List<int> correctOptionIndexes,
    required String explanation,
    required double points,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
}
