import 'package:dio/dio.dart';

import '../models/result_model.dart';
import '../network/api_client.dart';
import 'result_repository.dart';

class ApiResultRepository implements ResultRepository {
  ApiResultRepository(this._apiClient);

  final ApiClient _apiClient;

  Dio get _dio => _apiClient.dio;

  @override
  Future<Result> getResult(String attemptId) async {
    final response = await _dio.get<Map<String, dynamic>>('/attempts/$attemptId');
    return _toResult(response.data ?? <String, dynamic>{});
  }

  @override
  Future<List<Result>> getUserResults(String userId) async {
    final response = await _dio.get<List<dynamic>>('/attempts');
    return (response.data ?? const <dynamic>[])
        .whereType<Map>()
        .map((item) => _toResult(Map<String, dynamic>.from(item)))
        .toList();
  }

  Result _toResult(Map<String, dynamic> json) {
    final correct = _asInt(json['correct']);
    final incorrect = _asInt(json['wrong'] ?? json['incorrect']);
    final skipped = _asInt(json['unanswered'] ?? json['skipped']);
    final totalQuestions = _asInt(
      json['totalQuestions'],
      fallback: correct + incorrect + skipped,
    );
    final answered = correct + incorrect;
    final accuracy = answered == 0 ? 0.0 : (correct / answered) * 100;
    final attemptId = json['id']?.toString() ?? '';

    return Result(
      id: attemptId,
      attemptId: attemptId,
      userId: json['userId']?.toString() ?? '',
      examId: json['testId']?.toString() ?? '',
      score: _asDouble(json['actualScore'] ?? json['score']),
      maxScore: totalQuestions.toDouble(),
      accuracy: accuracy,
      correctCount: correct,
      incorrectCount: incorrect,
      skippedCount: skipped,
      rank: json['rank'] == null ? null : _asInt(json['rank']),
      percentile: json['percentile'] == null
          ? null
          : _asDouble(json['percentile']),
      calculatedAt: DateTime.tryParse(
            json['submittedAt']?.toString() ??
                json['createdAt']?.toString() ??
                '',
          ) ??
          DateTime.now(),
    );
  }
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _asDouble(Object? value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}
