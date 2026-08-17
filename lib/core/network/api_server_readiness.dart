import 'package:dio/dio.dart';

abstract interface class ApiServerReadiness {
  Future<void> ensureReady();
}

Uri apiHealthUriForBase(String apiBaseUrl) {
  final apiUri = Uri.parse(apiBaseUrl);
  if (!apiUri.hasScheme || apiUri.host.isEmpty) {
    throw ArgumentError.value(apiBaseUrl, 'apiBaseUrl', 'Must be an absolute URL');
  }

  return Uri(
    scheme: apiUri.scheme,
    userInfo: apiUri.userInfo,
    host: apiUri.host,
    port: apiUri.hasPort ? apiUri.port : null,
    path: '/health',
  );
}

bool isRetryableApiReadinessError(Object error) {
  if (error is! DioException) return false;

  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.connectionError ||
    DioExceptionType.unknown => true,
    DioExceptionType.badResponse => switch (error.response?.statusCode) {
        408 || 425 || 429 => true,
        final status? when status >= 500 => true,
        _ => false,
      },
    DioExceptionType.badCertificate || DioExceptionType.cancel => false,
  };
}

class DioApiServerReadiness implements ApiServerReadiness {
  DioApiServerReadiness({
    required String apiBaseUrl,
    Dio? probeClient,
    this.readyTtl = const Duration(minutes: 3),
    this.startupTimeout = const Duration(minutes: 3),
    this.retryDelay = const Duration(seconds: 2),
  })  : healthUri = apiHealthUriForBase(apiBaseUrl),
        _probeClient = probeClient ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 20),
                sendTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 35),
                headers: const {
                  'Accept': 'application/json',
                  'x-examtree-device': 'android-warmup',
                },
              ),
            ),
        _ownsProbeClient = probeClient == null;

  final Uri healthUri;
  final Duration readyTtl;
  final Duration startupTimeout;
  final Duration retryDelay;
  final Dio _probeClient;
  final bool _ownsProbeClient;

  Future<void>? _inFlight;
  DateTime? _lastReadyAt;

  @override
  Future<void> ensureReady() {
    final lastReadyAt = _lastReadyAt;
    if (lastReadyAt != null &&
        DateTime.now().difference(lastReadyAt) < readyTtl) {
      return Future<void>.value();
    }

    final activeProbe = _inFlight;
    if (activeProbe != null) return activeProbe;

    late final Future<void> probe;
    probe = _probe().whenComplete(() {
      if (identical(_inFlight, probe)) {
        _inFlight = null;
      }
    });
    _inFlight = probe;
    return probe;
  }

  Future<void> _probe() async {
    final stopwatch = Stopwatch()..start();
    Object? lastError;

    while (true) {
      try {
        await _probeClient.getUri<Object?>(healthUri);
        _lastReadyAt = DateTime.now();
        return;
      } catch (error) {
        lastError = error;
        if (!isRetryableApiReadinessError(error)) {
          rethrow;
        }
      }

      final remaining = startupTimeout - stopwatch.elapsed;
      if (remaining <= Duration.zero) {
        throw lastError;
      }

      final wait = remaining < retryDelay ? remaining : retryDelay;
      await Future<void>.delayed(wait);
    }
  }

  void close() {
    if (_ownsProbeClient) {
      _probeClient.close(force: true);
    }
  }
}
