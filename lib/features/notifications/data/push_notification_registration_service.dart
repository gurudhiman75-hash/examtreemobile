import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../core/analytics/mobile_analytics_client.dart';
import '../../../core/network/api_client.dart';
import '../../../core/observability/crash_reporting.dart';

class PushNotificationRegistrationService {
  PushNotificationRegistrationService({
    required ApiClient apiClient,
    MobileAnalyticsClient? analyticsClient,
    this.onOpenDestination,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _apiClient = apiClient,
        _analyticsClient = analyticsClient,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  final ApiClient _apiClient;
  final MobileAnalyticsClient? _analyticsClient;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final void Function(String destinationType, String destinationValue)?
      onOpenDestination;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _openSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  bool _initialized = false;
  final Map<String, DateTime> _recentNotificationOpens = <String, DateTime>{};

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
        final payload = response.payload?.trim() ?? '';
        if (payload.isEmpty) return;
        try {
          final data = jsonDecode(payload);
          if (data is Map) {
            final campaignId = data['campaignId']?.toString().trim() ?? '';
            final destinationType =
                data['destinationType']?.toString().trim() ?? 'none';
            final destinationValue =
                data['destinationValue']?.toString().trim() ?? '';
            final isTest =
                data['isTest']?.toString().trim().toLowerCase() == 'true';
            if (campaignId.isNotEmpty) {
              unawaited(
                _recordOpenByCampaignId(
                  campaignId,
                  destinationType: destinationType,
                  destinationValue: destinationValue,
                  isTest: isTest,
                ),
              );
            }
            return;
          }
        } catch (_) {
          // Older builds stored only the campaign id as the payload.
        }
        unawaited(_recordOpenByCampaignId(payload));
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
    final payload = campaignId.isEmpty
        ? null
        : jsonEncode(<String, String>{
            'campaignId': campaignId,
            'destinationType':
                message.data['destinationType']?.trim() ?? 'none',
            'destinationValue':
                message.data['destinationValue']?.trim() ?? '',
            'isTest': message.data['isTest']?.trim() ?? 'false',
          });
    await _localNotifications.show(
      id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title: notification.title ?? 'ExamTree',
      body: notification.body ?? '',
      notificationDetails: details,
      payload: payload,
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
    await _recordOpenByCampaignId(
      campaignId,
      destinationType: message.data['destinationType']?.trim() ?? 'none',
      destinationValue: message.data['destinationValue']?.trim() ?? '',
      isTest: message.data['isTest']?.trim().toLowerCase() == 'true',
    );
  }

  Future<void> _recordOpenByCampaignId(
    String campaignId, {
    String destinationType = 'none',
    String destinationValue = '',
    bool isTest = false,
  }) async {
    final now = DateTime.now();
    final previous = _recentNotificationOpens[campaignId];
    if (previous != null && now.difference(previous) < const Duration(seconds: 5)) {
      return;
    }
    _recentNotificationOpens[campaignId] = now;
    _recentNotificationOpens.removeWhere(
      (_, openedAt) => now.difference(openedAt) > const Duration(minutes: 1),
    );

    // Navigation is the learner-visible action and must never wait on telemetry.
    onOpenDestination?.call(destinationType, destinationValue);

    if (isTest) return;

    try {
      await _apiClient.dio.post<void>(
        'mobile/notifications/$campaignId/open',
      );
      await _analyticsClient?.track(
        'notification_open',
        entityType: 'notification',
        entityId: campaignId,
        placement: 'push',
        metadata: <String, Object?>{
          'destinationType': destinationType,
        },
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
