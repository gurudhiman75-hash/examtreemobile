import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/daily_companion.dart';

abstract interface class StudyReminderService {
  Future<bool> schedule(StudyCompanionSettings settings);
  Future<void> cancel();
}

class LocalStudyReminderService implements StudyReminderService {
  LocalStudyReminderService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _baseNotificationId = 7310;
  static const _channelId = 'daily_study_reminders';
  static const _channelName = 'Daily study reminders';
  static const _channelDescription =
      'Reminders for the study schedule chosen inside ExamTree.';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final deviceTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(deviceTimezone.identifier));
    } catch (_) {
      // UTC is the timezone package's safe default. A later schedule call can
      // still be replaced when the device timezone becomes available.
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
    if (!Platform.isAndroid) return true;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted != false;
  }

  @override
  Future<bool> schedule(StudyCompanionSettings settings) async {
    await _initialize();
    await cancel();
    if (!settings.reminderEnabled || settings.reminderWeekdays.isEmpty) {
      return true;
    }

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

    for (final weekday in settings.reminderWeekdays) {
      if (weekday < DateTime.monday || weekday > DateTime.sunday) continue;
      await _plugin.zonedSchedule(
        id: _baseNotificationId + weekday,
        title: 'Your ExamTree revision is ready',
        body: 'Open your Daily Companion and clear today’s revision queue.',
        scheduledDate: _nextWeekdayTime(
          weekday: weekday,
          hour: settings.reminderHour,
          minute: settings.reminderMinute,
        ),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: 'daily-companion',
      );
    }
    return true;
  }

  @override
  Future<void> cancel() async {
    await _initialize();
    for (var weekday = DateTime.monday;
        weekday <= DateTime.sunday;
        weekday++) {
      await _plugin.cancel(id: _baseNotificationId + weekday);
    }
  }

  tz.TZDateTime _nextWeekdayTime({
    required int weekday,
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour.clamp(0, 23),
      minute.clamp(0, 59),
    );
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
