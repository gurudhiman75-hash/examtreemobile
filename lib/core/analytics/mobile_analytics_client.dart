import 'dart:math';

import 'package:flutter/foundation.dart';

import '../network/api_client.dart';
import '../observability/crash_reporting.dart';

class MobileAnalyticsClient {
  MobileAnalyticsClient(this._apiClient)
      : _sessionId =
            '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';

  final ApiClient _apiClient;
  final String _sessionId;
  final Set<String> _once = <String>{};

  Future<void> track(
    String eventName, {
    String entityType = '',
    String entityId = '',
    String placement = '',
    Map<String, Object?> metadata = const <String, Object?>{},
  }) async {
    try {
      await _apiClient.dio.post<void>(
        'mobile/analytics/events',
        data: <String, Object?>{
          'eventName': eventName,
          'sessionId': _sessionId,
          'entityType': entityType,
          'entityId': entityId,
          'placement': placement,
          'appVersion': examtreeCrashAppVersion,
          'platform': examtreeDeviceLabel(defaultTargetPlatform),
          'locale': PlatformDispatcher.instance.locale.toLanguageTag(),
          'metadata': metadata,
          'occurredAt': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (_) {
      // Analytics is deliberately non-blocking. Product interactions must
      // never fail because telemetry is unavailable.
    }
  }

  Future<void> trackOnce(
    String key,
    String eventName, {
    String entityType = '',
    String entityId = '',
    String placement = '',
    Map<String, Object?> metadata = const <String, Object?>{},
  }) async {
    if (!_once.add(key)) return;
    await track(
      eventName,
      entityType: entityType,
      entityId: entityId,
      placement: placement,
      metadata: metadata,
    );
  }
}
