import 'package:dio/dio.dart';

import '../models/attempt_session_model.dart';
import '../network/api_client.dart';
import 'attempt_session_repository.dart';

class AttemptSessionRepositoryException implements Exception {
  const AttemptSessionRepositoryException(
    this.message, {
    this.code,
    this.statusCode,
  });

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiAttemptSessionRepository implements AttemptSessionRepository {
  ApiAttemptSessionRepository(this._apiClient);

  final ApiClient _apiClient;

  Dio get _dio => _apiClient.dio;

  @override
  Future<AttemptSession> startOrResume({
    required String testId,
    String? seriesId,
  }) async {
    return _request(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/attempt-sessions',
        data: {
          'testId': testId,
          if (seriesId != null && seriesId.isNotEmpty) 'seriesId': seriesId,
        },
      );
      return AttemptSession.fromJson(response.data ?? <String, dynamic>{});
    });
  }

  @override
  Future<AttemptSession> getSession(String attemptId) async {
    return _request(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/attempt-sessions/$attemptId',
      );
      return AttemptSession.fromJson(response.data ?? <String, dynamic>{});
    });
  }

  @override
  Future<AttemptSession> saveSession({
    required String attemptId,
    required int expectedRevision,
    required AttemptSessionState state,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/attempt-sessions/$attemptId',
        data: {
          'expectedRevision': expectedRevision,
          'state': state.toJson(),
        },
      );
      return AttemptSession.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      final data = error.response?.data;
      if (error.response?.statusCode == 409 && data is Map) {
        final body = Map<String, dynamic>.from(data);
        final rawSession = body['session'];
        if (rawSession is Map) {
          throw AttemptSessionConflict(
            AttemptSession.fromJson(Map<String, dynamic>.from(rawSession)),
          );
        }
      }
      throw _mapDioError(error);
    }
  }

  @override
  Future<AttemptSubmitResponse> submitAttempt({
    required String attemptId,
    required String testId,
    required int timeSpentMinutes,
    required List<AttemptResponsePayload> responses,
    required Map<String, bool> flags,
    String attemptType = 'REAL',
    String? seriesId,
  }) async {
    return _request(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/attempts',
        data: {
          'attemptId': attemptId,
          'testId': testId,
          'timeSpent': timeSpentMinutes,
          'responses': responses.map((item) => item.toJson()).toList(),
          'flags': flags,
          'attemptType': attemptType,
          if (seriesId != null && seriesId.isNotEmpty) 'seriesId': seriesId,
        },
      );
      return AttemptSubmitResponse.fromJson(
        response.data ?? <String, dynamic>{},
      );
    });
  }

  Future<T> _request<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AttemptSessionConflict {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioError(error);
    } catch (error) {
      if (error is AttemptSessionRepositoryException) rethrow;
      throw AttemptSessionRepositoryException(
        'Unable to synchronise this attempt: $error',
      );
    }
  }

  AttemptSessionRepositoryException _mapDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    final body = data is Map
        ? Map<String, dynamic>.from(data)
        : const <String, dynamic>{};
    return AttemptSessionRepositoryException(
      body['error']?.toString() ??
          error.message ??
          'Unable to synchronise this attempt',
      code: body['code']?.toString(),
      statusCode: statusCode,
    );
  }
}
