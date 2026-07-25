import 'package:freezed_annotation/freezed_annotation.dart';

part 'question_model.freezed.dart';
part 'question_model.g.dart';

@freezed
abstract class Question with _$Question {
  const factory Question({
    required int id,
    required String examId,
    required String subject,
    required String topic,
    required String difficulty,
    required String text,
    required List<String> options,
    required List<int> correctOptionIndexes,
    required String explanation,
    required double points,
    String? textHi,
    List<String>? optionsHi,
    String? explanationHi,
    String? textPa,
    List<String>? optionsPa,
    String? explanationPa,
    Map<String, dynamic>? seatingDiagram,
    Map<String, dynamic>? seatingExplanationFlow,
    String? imageUrl,
    String? questionType,
    int? diSetId,
    String? diSetTitle,
    String? diSetImageUrl,
    String? diSetDescription,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
}
