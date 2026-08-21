import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/learning_resource.dart';

class LearningResourcesException implements Exception {
  const LearningResourcesException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

class LearningResourcesRepository {
  LearningResourcesRepository(this._client);

  final ApiClient _client;

  Future<List<LearningResourceSummary>> loadResources({
    String? languageCode,
    LearningResourceCategory? category,
    int limit = 100,
  }) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/learning-resources',
        queryParameters: {
          if (languageCode != null && languageCode.trim().isNotEmpty)
            'language': languageCode.trim().toLowerCase(),
          if (category != null) 'category': category.apiValue,
          'limit': limit.clamp(1, 100),
        },
      );
      final raw = response.data?['resources'];
      if (raw is! List) return const [];
      final resources = <LearningResourceSummary>[];
      for (final item in raw.whereType<Map>()) {
        try {
          resources.add(
            LearningResourceSummary.fromJson(Map<String, dynamic>.from(item)),
          );
        } on FormatException {
          // One malformed editorial row must not hide the rest of Learn.
        }
      }
      return resources;
    } on DioException catch (error) {
      throw _mapDioError(error, 'Unable to load learning resources.');
    } catch (_) {
      throw const LearningResourcesException(
        'Unable to load learning resources.',
      );
    }
  }

  Future<LearningResourceDetail> loadResource(String identifier) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/learning-resources/${Uri.encodeComponent(identifier)}',
      );
      final raw = response.data?['resource'];
      if (raw is! Map) {
        throw const LearningResourcesException('Learning resource is unavailable.');
      }
      return LearningResourceDetail.fromJson(Map<String, dynamic>.from(raw));
    } on LearningResourcesException {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioError(error, 'Unable to load this learning resource.');
    } catch (_) {
      throw const LearningResourcesException(
        'Unable to load this learning resource.',
      );
    }
  }

  LearningResourcesException _mapDioError(
    DioException error,
    String fallback,
  ) {
    final statusCode = error.response?.statusCode;
    final raw = error.response?.data;
    final body = raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
    return LearningResourcesException(
      body['error']?.toString().trim().isNotEmpty == true
          ? body['error'].toString().trim()
          : fallback,
      statusCode: statusCode,
      code: body['code']?.toString(),
    );
  }
}
