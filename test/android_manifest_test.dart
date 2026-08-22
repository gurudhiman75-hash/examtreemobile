import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production Android manifest permits network access', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(
      manifest,
      contains('android.permission.INTERNET'),
    );
    expect(manifest, contains('android:label="ExamTree"'));
  });

  test('production Android manifest disables backup and cleartext traffic', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:usesCleartextTraffic="false"'));
  });

  test('Android manifest registers Companion widget and deep links', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('.CompanionWidgetProvider'));
    expect(manifest, contains('android.appwidget.action.APPWIDGET_UPDATE'));
    expect(manifest, contains('@xml/companion_widget_info'));
    expect(manifest, contains('@xml/shortcuts'));
    expect(manifest, contains('android:scheme="examtree"'));
    expect(manifest, contains('android:host="app"'));
    expect(manifest, contains('flutter_deeplinking_enabled'));
  });

  test('launcher shortcuts target canonical mobile destinations', () {
    final shortcuts = File(
      'android/app/src/main/res/xml/shortcuts.xml',
    ).readAsStringSync();

    expect(shortcuts, contains('examtree://app/daily'));
    expect(
      shortcuts,
      contains('examtree://app/quick-revision?minutes=5'),
    );
    expect(shortcuts, contains('examtree://app/exams'));
  });

  test('home widget exposes revision and test actions', () {
    final layout = File(
      'android/app/src/main/res/layout/companion_widget.xml',
    ).readAsStringSync();
    final metadata = File(
      'android/app/src/main/res/xml/companion_widget_info.xml',
    ).readAsStringSync();

    expect(layout, contains('@+id/widget_quick_revision'));
    expect(layout, contains('@+id/widget_tests'));
    expect(layout, contains('@+id/widget_due'));
    expect(metadata, contains('@layout/companion_widget'));
    expect(metadata, contains('android:updatePeriodMillis="0"'));
  });
}
