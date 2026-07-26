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
    final response = await _dio.get<Map<String, dynamic>>(
      '/attempts/$attemptId',
    );
    return Result.fromJson(response.data ?? <String, dynamic>{});
  }

  @override
  Future<List<Result>> getUserResults(String userId) async {
    final response = await _dio.get<List<dynamic>>('/attempts');
    return (response.data ?? const <dynamic>[])
        .whereType<Map>()
        .map((item) => Result.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }
}
