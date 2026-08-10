import 'package:dio/dio.dart';

enum NetworkFailureKind {
  offline,
  timeout,
  session,
  forbidden,
  rateLimited,
  server,
  secureConnection,
  unknown,
}

class NetworkFailureGuidance {
  const NetworkFailureGuidance({
    required this.kind,
    required this.title,
    required this.message,
  });

  final NetworkFailureKind kind;
  final String title;
  final String message;

  String get combinedMessage => '$title $message';
}

NetworkFailureGuidance networkFailureGuidance(
  Object error, {
  String fallbackTitle = 'Unable to load this content',
}) {
  if (error is! DioException) {
    return NetworkFailureGuidance(
      kind: NetworkFailureKind.unknown,
      title: fallbackTitle,
      message: 'Please try again.',
    );
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const NetworkFailureGuidance(
        kind: NetworkFailureKind.timeout,
        title: 'Request timed out',
        message: 'The connection was too slow. Check your network and try again.',
      );
    case DioExceptionType.connectionError:
      return const NetworkFailureGuidance(
        kind: NetworkFailureKind.offline,
        title: 'No internet connection',
        message: 'Check Wi-Fi or mobile data, then try again.',
      );
    case DioExceptionType.badCertificate:
      return const NetworkFailureGuidance(
        kind: NetworkFailureKind.secureConnection,
        title: 'Secure connection failed',
        message: 'ExamTree could not verify the server connection. Try again later.',
      );
    case DioExceptionType.badResponse:
      return _responseGuidance(
        error.response?.statusCode,
        fallbackTitle: fallbackTitle,
      );
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      return NetworkFailureGuidance(
        kind: NetworkFailureKind.unknown,
        title: fallbackTitle,
        message: 'Please try again.',
      );
  }
}

NetworkFailureGuidance _responseGuidance(
  int? statusCode, {
  required String fallbackTitle,
}) {
  if (statusCode == 401) {
    return const NetworkFailureGuidance(
      kind: NetworkFailureKind.session,
      title: 'Session needs attention',
      message: 'Your session could not be refreshed. Retry once, then sign out and sign in again if it continues.',
    );
  }
  if (statusCode == 403) {
    return const NetworkFailureGuidance(
      kind: NetworkFailureKind.forbidden,
      title: 'Access unavailable',
      message: 'This content is not available to your account right now.',
    );
  }
  if (statusCode == 429) {
    return const NetworkFailureGuidance(
      kind: NetworkFailureKind.rateLimited,
      title: 'Too many requests',
      message: 'Wait a little before trying again.',
    );
  }
  if (statusCode != null && statusCode >= 500) {
    return const NetworkFailureGuidance(
      kind: NetworkFailureKind.server,
      title: 'ExamTree is temporarily unavailable',
      message: 'Your saved work is unchanged. Please try again shortly.',
    );
  }

  return NetworkFailureGuidance(
    kind: NetworkFailureKind.unknown,
    title: fallbackTitle,
    message: 'Please try again.',
  );
}
