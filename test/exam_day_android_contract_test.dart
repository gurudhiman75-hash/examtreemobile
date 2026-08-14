import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exam-day route is protected and launcher shortcut targets it', () {
    final router = File('lib/routes/app_router.dart').readAsStringSync();
    final shortcuts = File(
      'android/app/src/main/res/xml/shortcuts.xml',
    ).readAsStringSync();
    final strings = File(
      'android/app/src/main/res/values/strings.xml',
    ).readAsStringSync();

    expect(router, contains("path: '/exam-day'"));
    expect(router, contains('const ExamDayScreen()'));
    expect(shortcuts, contains('android:shortcutId="exam_day"'));
    expect(shortcuts, contains('android:data="examtree://app/exam-day"'));
    expect(strings, contains('shortcut_exam_day_short'));
  });

  test('logout cancels exam-day reminders', () {
    final mainSource = File('lib/main.dart').readAsStringSync();
    expect(
      mainSource,
      contains('examDayControllerProvider).cancelReminders()'),
    );
  });

  test('exam-day mode keeps official instructions authoritative', () {
    final source = File(
      'lib/features/exam_day/presentation/exam_day_screen.dart',
    ).readAsStringSync();
    expect(source, contains('Official instructions remain authoritative'));
    expect(source, contains('not an academic readiness score'));
  });
}
