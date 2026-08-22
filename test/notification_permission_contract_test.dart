import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const reminderServices = <String>[
    'lib/features/companion/services/study_reminder_service.dart',
    'lib/features/exam_day/services/exam_day_reminder_service.dart',
  ];

  test('reminder services request notification permission on Android and Darwin', () {
    for (final path in reminderServices) {
      final source = File(path).readAsStringSync();

      expect(source, contains('AndroidFlutterLocalNotificationsPlugin'));
      expect(source, contains('requestNotificationsPermission()'));
      expect(source, contains('Platform.isIOS'));
      expect(source, contains('IOSFlutterLocalNotificationsPlugin'));
      expect(source, contains('Platform.isMacOS'));
      expect(source, contains('MacOSFlutterLocalNotificationsPlugin'));
      expect(source, contains('requestPermissions('));
      expect(source, contains('alert: true'));
      expect(source, contains('sound: true'));
    }
  });

  test('Darwin notification prompts stay tied to learner reminder actions', () {
    for (final path in reminderServices) {
      final source = File(path).readAsStringSync();

      expect(source, contains('requestAlertPermission: false'));
      expect(source, contains('requestBadgePermission: false'));
      expect(source, contains('requestSoundPermission: false'));
      expect(source, contains('if (!permissionGranted) return false;'));
    }
  });
}
