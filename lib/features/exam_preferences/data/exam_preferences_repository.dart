import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/exam_preferences.dart';

class ExamPreferencesException implements Exception {
  const ExamPreferencesException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class ExamPreferencesRepository {
  const ExamPreferencesRepository(this._client);

  final ApiClient _client;

  Future<ExamTargetCatalogue> loadCatalogue() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/users/exam-catalog',
      );
      return ExamTargetCatalogue.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw _mapError(error, 'Unable to load exams right now.');
    }
  }

  Future<LearnerExamPreferences> loadPreferences() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/users/me/exam-preferences',
      );
      return LearnerExamPreferences.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw _mapError(error, 'Unable to load your selected exams.');
    }
  }

  Future<LearnerExamPreferences> savePreferences(List<String> examIds) async {
    try {
      final response = await _client.dio.put<Map<String, dynamic>>(
        '/users/me/exam-preferences',
        data: {'examIds': examIds},
      );
      return LearnerExamPreferences.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw _mapError(error, 'Unable to save your selected exams.');
    }
  }

  ExamPreferencesException _mapError(DioException error, String fallback) {
    final raw = error.response?.data;
    final body = raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
    final code = body['code']?.toString();
    final serverMessage = body['error']?.toString().trim();
    final safeMessage = switch (code) {
      'STUDENT_PROFILE_REQUIRED' =>
        'Finish account setup, then choose the exams you are preparing for.',
      'EXAM_PREFERENCE_UNAVAILABLE' =>
        'One of those exams is no longer available. Refresh the list and try again.',
      'INVALID_EXAM_PREFERENCES' =>
        'Choose only exams from the current ExamTree catalogue.',
      _ => serverMessage == null || serverMessage.isEmpty ? fallback : serverMessage,
    };
    return ExamPreferencesException(safeMessage, code: code);
  }
}
