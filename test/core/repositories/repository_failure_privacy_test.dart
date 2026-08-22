import 'package:dio/dio.dart';
import 'package:examtree/core/network/api_client.dart';
import 'package:examtree/core/repositories/api_attempt_session_repository.dart';
import 'package:examtree/core/repositories/api_exam_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoAuthTokenProvider implements AuthTokenProvider {
  @override
  bool get hasAuthenticatedUser => false;

  @override
  Future<String?> getToken({bool forceRefresh = false}) async => null;
}

Dio _rejectingDio({
  required String internalMessage,
  String code = 'INTERNAL_FAILURE',
  int statusCode = 500,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            message: internalMessage,
            response: Response<dynamic>(
              requestOptions: options,
              statusCode: statusCode,
              data: <String, dynamic>{
                'error': internalMessage,
                'code': code,
              },
            ),
          ),
        );
      },
    ),
  );
  return dio;
}

void main() {
  const secret = 'INTERNAL_API_TOKEN_SHOULD_NEVER_RENDER';

  test('exam repository never exposes backend error text', () async {
    final repository = ApiExamRepository(
      _rejectingDio(internalMessage: secret),
    );

    try {
      await repository.getExamDetails('exam-1');
      fail('Expected ExamRepositoryException');
    } on ExamRepositoryException catch (error) {
      expect(error.toString(), isNot(contains(secret)));
      expect(error.message, isNot(contains(secret)));
      expect(error.statusCode, 500);
      expect(error.code, 'INTERNAL_FAILURE');
      expect(error.toString(), contains('temporarily unavailable'));
    }
  });

  test('attempt repository never exposes backend error text', () async {
    final dio = _rejectingDio(internalMessage: secret);
    final client = ApiClient(
      dio: dio,
      authTokenProvider: _NoAuthTokenProvider(),
    );
    final repository = ApiAttemptSessionRepository(client);

    try {
      await repository.startOrResume(testId: 'test-1');
      fail('Expected AttemptSessionRepositoryException');
    } on AttemptSessionRepositoryException catch (error) {
      expect(error.toString(), isNot(contains(secret)));
      expect(error.message, isNot(contains(secret)));
      expect(error.statusCode, 500);
      expect(error.code, 'INTERNAL_FAILURE');
      expect(error.toString(), contains('temporarily unavailable'));
    }
  });
}
