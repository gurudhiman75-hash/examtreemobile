import 'dart:async';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../core/network/api_client.dart';
import '../../../core/observability/crash_reporting.dart';

class PushNotificationRegistrationService {
  PushNotificationRegistrationService({
    required ApiClient apiClient,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _apiClient = apiClient,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  final ApiClient _apiClient;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _openSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  bool _initialized = false;

  Future<void> initializeForAuthenticatedUser() async {
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await _messaging.getToken();
      if (token != null && token.trim().isNotEmpty) {
        await _registerToken(token);
      }

      if (!_initialized) {
        await _initializeLocalNotifications();
        _initialized = true;
        _tokenSubscription = _messaging.onTokenRefresh.listen(
          (token) => unawaited(_registerToken(token)),
        );
        _openSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
          (message) => unawaited(_recordOpen(message)),
        );
        _foregroundSubscription = FirebaseMessaging.onMessage.listen(
          (message) => unawaited(_showForegroundNotification(message)),
        );
        final initial = await _messaging.getInitialMessage();
        if (initial != null) {
          await _recordOpen(initial);
        }
      }
    } catch (_) {
      // Push is optional. Auth, tests and learning must remain usable when FCM
      // registration or permission is unavailable.
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const android = AndroidInitializationSettings('ic_notification');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
      onDidReceiveNotificationResponse: (response) {
        final campaignId = response.payload?.trim() ?? '';
        if (campaignId.isNotEmpty) {
          unawaited(_recordOpenByCampaignId(campaignId));
        }
      },
    );
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'examtree_push',
        'ExamTree updates',
        channelDescription: 'ExamTree test, learning and account updates.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );
    final campaignId = message.data['campaignId']?.trim() ?? '';
    await _localNotifications.show(
      id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title: notification.title ?? 'ExamTree',
      body: notification.body ?? '',
      notificationDetails: details,
      payload: campaignId.isEmpty ? null : campaignId,
    );
  }

  Future<void> _registerToken(String token) async {
    final platform = switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => '',
    };
    if (platform.isEmpty || token.trim().isEmpty) return;

    try {
      await _apiClient.dio.post<void>(
        'mobile/push-devices',
        data: <String, Object?>{
          'token': token.trim(),
          'platform': platform,
          'appVersion': examtreeCrashAppVersion,
          'locale': PlatformDispatcher.instance.locale.toLanguageTag(),
        },
      );
    } catch (_) {
      // Canonical profile provisioning may still be completing immediately
      // after sign-in. A later auth/app lifecycle sync will retry safely.
    }
  }

  Future<void> _recordOpen(RemoteMessage message) async {
    final campaignId = message.data['campaignId']?.trim() ?? '';
    if (campaignId.isEmpty) return;
    await _recordOpenByCampaignId(campaignId);
  }

  Future<void> _recordOpenByCampaignId(String campaignId) async {
    try {
      await _apiClient.dio.post<void>(
        'mobile/notifications/$campaignId/open',
      );
    } catch (_) {
      // Open telemetry is best-effort and never blocks notification routing.
    }
  }

  Future<void> dispose() async {
    await _tokenSubscription?.cancel();
    await _openSubscription?.cancel();
    await _foregroundSubscription?.cancel();
  }
}
