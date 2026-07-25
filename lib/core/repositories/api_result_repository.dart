import 'package:dio/dio.dart';

import '../models/result_model.dart';
import 'result_repository.dart';

class ApiResultRepository implements ResultRepository {
  ApiResultRepository(this._dio);

  final Dio _dio;

  @override
  Future<Result> getResult(String attemptId) async {
    final response = await _dio.get<Map<String, dynamic>>('/attempts/$attemptId');
    return _toResult(response.data ?? const <String, dynamic>{});
  }

  @override
  Future<List<Result>> getUserResults(String userId) async {
    final response = await _dio.get<List<dynamic>>('/attempts');
    final payload = response.data ?? const <dynamic>[];
    return payload
        .whereType<Map>()
        .map((item) => _toResult(Map<String, dynamic>.from(item)))
        .toList()
      ..sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));
  }

  Result _toResult(Map<String, dynamic> json) {
    final correct = _asInt(json['correct']);
    final incorrect = _asInt(json['wrong']);
    final skipped = _asInt(json['unanswered']);
    final attempted = correct + incorrect;
    final accuracy = attempted == 0 ? 0.0 : (correct / attempted) * 100;
    final attemptId = json['id']?.toString() ?? '';

    return Result(
      id: attemptId,
      attemptId: attemptId,
      userId: json['userId']?.toString() ?? '',
      examId: json['testId']?.toString() ?? '',
      score: _asDouble(json['score']),
      maxScore: 100,
      accuracy: _round2(accuracy),
      correctCount: correct,
      incorrectCount: incorrect,
      skippedCount: skipped,
      calculatedAt: _asDateTime(json['createdAt']),
    );
  }

  int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  DateTime _asDateTime(Object? value) {
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }

  double _round2(double value) => (value * 100).roundToDouble() / 100;
}
