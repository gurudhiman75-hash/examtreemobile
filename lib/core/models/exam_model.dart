import 'package:freezed_annotation/freezed_annotation.dart';

part 'exam_model.freezed.dart';
part 'exam_model.g.dart';

@freezed
abstract class Exam with _$Exam {
  const factory Exam({
    required String id,
    required String title,
    required String description,
    required int durationInSeconds,
    required int totalQuestions,
    required double totalMarks,
    required int maxAttempts,
    required double negativeMarking,
    required String difficulty,
    required String status,
    required String category,
    @Default([]) List<String> tags,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Exam;

  factory Exam.fromJson(Map<String, dynamic> json) => _$ExamFromJson(json);
}
