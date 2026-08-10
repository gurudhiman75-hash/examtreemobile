import 'package:dio/dio.dart';
import 'package:examtree/core/network/network_failure_guidance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('networkFailureGuidance', () {
    test('distinguishes offline and timeout failures', () {
      expect(
        networkFailureGuidance(_dio(DioExceptionType.connectionError)).kind,
        NetworkFailureKind.offline,
      );
      expect(
        networkFailureGuidance(_dio(DioExceptionType.receiveTimeout)).kind,
        NetworkFailureKind.timeout,
      );
    });

    test('explains an exhausted authentication refresh', () {
      final guidance = networkFailureGuidance(_response(401));

      expect(guidance.kind, NetworkFailureKind.session);
      expect(guidance.title, contains('Session'));
      expect(guidance.message, contains('sign out'));
    });

    test('classifies access, rate limit and server failures', () {
      expect(networkFailureGuidance(_response(403)).kind, NetworkFailureKind.forbidden);
      expect(networkFailureGuidance(_response(429)).kind, NetworkFailureKind.rateLimited);
      expect(networkFailureGuidance(_response(503)).kind, NetworkFailureKind.server);
    });

    test('uses the screen fallback for unknown failures', () {
      final guidance = networkFailureGuidance(
        StateError('unexpected'),
        fallbackTitle: 'Unable to load results',
      );

      expect(guidance.kind, NetworkFailureKind.unknown);
      expect(guidance.title, 'Unable to load results');
      expect(guidance.message, 'Please try again.');
    });
  });
}

DioException _dio(DioExceptionType type) {
  return DioException(
    requestOptions: RequestOptions(path: '/test'),
    type: type,
  );
}

DioException _response(int statusCode) {
  final request = RequestOptions(path: '/test');
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response<void>(
      requestOptions: request,
      statusCode: statusCode,
    ),
  );
}
