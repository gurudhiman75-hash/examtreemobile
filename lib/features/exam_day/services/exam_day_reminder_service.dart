import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/exam_day_mode.dart';

abstract interface class ExamDayReminderService {
  Future<bool> schedule(ExamDayTarget target);
  Future<void> cancel();
}

class LocalExamDayReminderService implements ExamDayReminderService {
  LocalExamDayReminderService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _notification24h = 7424;
  static const _notification2h = 7402;
  static const _channelId = 'exam_day_reminders';
  static const _channelName = 'Exam-day reminders';
  static const _channelDescription =
      'Local reminders based on the exam target saved on this device.';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      final deviceTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(deviceTimezone.identifier));
    } catch (_) {
      // UTC remains a safe fallback until the device timezone is available.
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
    );
    _initialized = true;
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted != false;
    }
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        sound: true,
      );
      return granted != false;
    }
    if (Platform.isMacOS) {
      final macos = _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();
      final granted = await macos?.requestPermissions(
        alert: true,
        sound: true,
      );
      return granted != false;
    }
    return true;
  }

  @override
  Future<bool> schedule(ExamDayTarget target) async {
    await _initialize();
    await cancel();
    if (!target.remindersEnabled) return true;

    final permissionGranted = await _requestPermission();
    if (!permissionGranted) return false;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    final anchor = target.reportingAt ?? target.examAt;
    final now = DateTime.now();
    final reminder24h = anchor.subtract(const Duration(hours: 24));
    final reminder2h = anchor.subtract(const Duration(hours: 2));

    if (reminder24h.isAfter(now)) {
      await _plugin.zonedSchedule(
        id: _notification24h,
        title: '${target.examName} is approaching',
        body: 'About 24 hours remain until your saved exam-day time. Re-check the official instructions and your checklist.',
        scheduledDate: tz.TZDateTime.from(reminder24h, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'exam-day',
      );
    }
    if (reminder2h.isAfter(now)) {
      await _plugin.zonedSchedule(
        id: _notification2h,
        title: '${target.examName} — saved exam-day reminder',
        body: 'About 2 hours remain until your saved reporting/exam time. Follow the official venue and reporting instructions.',
        scheduledDate: tz.TZDateTime.from(reminder2h, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'exam-day',
      );
    }
    return true;
  }

  @override
  Future<void> cancel() async {
    await _initialize();
    await _plugin.cancel(id: _notification24h);
    await _plugin.cancel(id: _notification2h);
  }
}
