import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExamTree launcher assets', () {
    const densitySizes = <String, int>{
      'mdpi': 48,
      'hdpi': 72,
      'xhdpi': 96,
      'xxhdpi': 144,
      'xxxhdpi': 192,
    };

    for (final entry in densitySizes.entries) {
      test('${entry.key} launcher is a branded PNG at the expected size', () {
        final file = File(
          'android/app/src/main/res/mipmap-${entry.key}/ic_launcher.png',
        );
        final bytes = file.readAsBytesSync();

        expect(bytes.length, greaterThan(1000));
        expect(_pngDimension(bytes, 16), entry.value);
        expect(_pngDimension(bytes, 20), entry.value);
      });
    }

    test('adaptive launcher uses canonical brand and themed-icon layers', () {
      final adaptive = File(
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
      ).readAsStringSync();
      final colors = File(
        'android/app/src/main/res/values/examtree_launcher_colors.xml',
      ).readAsStringSync();
      final foreground = File(
        'android/app/src/main/res/drawable/examtree_launcher_foreground.xml',
      ).readAsStringSync();

      expect(adaptive, contains('@color/examtree_launcher_background'));
      expect(adaptive, contains('@drawable/examtree_launcher_foreground'));
      expect(adaptive, contains('@drawable/examtree_launcher_monochrome'));
      expect(colors, contains('#4F46E5'));
      expect(foreground, contains('android:width="108dp"'));
      expect(foreground, contains('android:height="108dp"'));
      expect(foreground, contains('android:translateX="27"'));
      expect(foreground, contains('android:translateY="27"'));
      expect(foreground, contains('android:scaleX="2.25"'));
      expect(foreground, contains('android:scaleY="2.25"'));
    });

    test('Play Console icon is a branded 512 by 512 PNG', () {
      final bytes = File(
        'docs/store-assets/examtree-play-icon-512.png',
      ).readAsBytesSync();

      expect(bytes.length, greaterThan(500));
      expect(_pngDimension(bytes, 16), 512);
      expect(_pngDimension(bytes, 20), 512);
    });

    test('Android reminders use a dedicated monochrome drawable', () {
      final notificationIcon = File(
        'android/app/src/main/res/drawable/ic_notification.xml',
      ).readAsStringSync();
      final daily = File(
        'lib/features/companion/services/study_reminder_service.dart',
      ).readAsStringSync();
      final examDay = File(
        'lib/features/exam_day/services/exam_day_reminder_service.dart',
      ).readAsStringSync();

      expect(notificationIcon, contains('android:viewportWidth="24"'));
      expect(notificationIcon, contains('android:fillColor="#FFFFFFFF"'));
      expect(daily, contains("AndroidInitializationSettings('ic_notification')"));
      expect(examDay, contains("AndroidInitializationSettings('ic_notification')"));
      expect(daily, isNot(contains('@mipmap/ic_launcher')));
      expect(examDay, isNot(contains('@mipmap/ic_launcher')));
    });
  });
}

int _pngDimension(Uint8List bytes, int offset) {
  expect(utf8.decode(bytes.sublist(1, 4)), 'PNG');
  return ByteData.sublistView(bytes).getUint32(offset, Endian.big);
}
