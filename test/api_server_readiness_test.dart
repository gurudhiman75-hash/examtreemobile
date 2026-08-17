import 'package:dio/dio.dart';
import 'package:examtree/core/network/api_server_readiness.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('apiHealthUriForBase', () {
    test('targets the root health route from the production API base', () {
      final health = apiHealthUriForBase(
        'https://examtree-new.onrender.com/api',
      );

      expect(health.toString(), 'https://examtree-new.onrender.com/health');
    });

    test('preserves a development host and explicit port', () {
      final health = apiHealthUriForBase('http://127.0.0.1:3001/api');

      expect(health.toString(), 'http://127.0.0.1:3001/health');
    });

    test('rejects a relative API base', () {
      expect(
        () => apiHealthUriForBase('/api'),
        throwsArgumentError,
      );
    });
  });

  group('isRetryableApiReadinessError', () {
    final request = RequestOptions(
      path: 'https://examtree-new.onrender.com/health',
    );

    test('retries connection and timeout failures', () {
      for (final type in <DioExceptionType>[
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
        DioExceptionType.unknown,
      ]) {
        expect(
          isRetryableApiReadinessError(
            DioException(requestOptions: request, type: type),
          ),
          isTrue,
          reason: '$type should be retryable during a Render cold start',
        );
      }
    });

    test('retries transient gateway and throttling responses', () {
      for (final status in <int>[408, 425, 429, 500, 502, 503, 504]) {
        final error = DioException(
          requestOptions: request,
          type: DioExceptionType.badResponse,
          response: Response<void>(
            requestOptions: request,
            statusCode: status,
          ),
        );

        expect(
          isRetryableApiReadinessError(error),
          isTrue,
          reason: '$status should be retryable during a Render cold start',
        );
      }
    });

    test('does not retry real client/configuration failures', () {
      for (final status in <int>[400, 401, 403, 404, 422]) {
        final error = DioException(
          requestOptions: request,
          type: DioExceptionType.badResponse,
          response: Response<void>(
            requestOptions: request,
            statusCode: status,
          ),
        );

        expect(
          isRetryableApiReadinessError(error),
          isFalse,
          reason: '$status should fail promptly',
        );
      }

      expect(
        isRetryableApiReadinessError(
          DioException(
            requestOptions: request,
            type: DioExceptionType.badCertificate,
          ),
        ),
        isFalse,
      );
      expect(
        isRetryableApiReadinessError(
          DioException(
            requestOptions: request,
            type: DioExceptionType.cancel,
          ),
        ),
        isFalse,
      );
    });
  });
}
