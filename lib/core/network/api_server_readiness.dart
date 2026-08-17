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

class DioApiServerReadiness implements ApiServerReadiness {
  DioApiServerReadiness({
    required String apiBaseUrl,
    Dio? probeClient,
    this.readyTtl = const Duration(minutes: 3),
  })  : healthUri = apiHealthUriForBase(apiBaseUrl),
        _probeClient = probeClient ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 90),
                sendTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 90),
                headers: const {
                  'Accept': 'application/json',
                  'x-examtree-device': 'android-warmup',
                },
              ),
            ),
        _ownsProbeClient = probeClient == null;

  final Uri healthUri;
  final Duration readyTtl;
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
    await _probeClient.getUri<Object?>(healthUri);
    _lastReadyAt = DateTime.now();
  }

  void close() {
    if (_ownsProbeClient) {
      _probeClient.close(force: true);
    }
  }
}
