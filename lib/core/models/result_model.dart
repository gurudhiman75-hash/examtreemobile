import 'package:freezed_annotation/freezed_annotation.dart';

part 'result_model.freezed.dart';
part 'result_model.g.dart';

@freezed
abstract class Result with _$Result {
  const factory Result({
    required String id,
    required String attemptId,
    required String userId,
    required String examId,
    required double score,
    required double maxScore,
    required double accuracy,
    required int correctCount,
    required int incorrectCount,
    required int skippedCount,
    int? rank,
    double? percentile,
    required DateTime calculatedAt,
  }) = _Result;

  factory Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);
}
