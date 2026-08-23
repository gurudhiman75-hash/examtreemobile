import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('authenticated APK version matches the declared app version', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final workflow = File(
      '.github/workflows/authenticated-android-apk.yml',
    ).readAsStringSync();

    final match = RegExp(
      r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+[0-9]+\s*$',
      multiLine: true,
    ).firstMatch(pubspec);

    expect(match, isNotNull, reason: 'pubspec.yaml must declare name+build version');
    final versionName = match!.group(1)!;

    expect(workflow, contains('--build-name=$versionName'));
    expect(workflow, contains('ExamTree-$versionName-auth-debug.apk'));
    expect(workflow, contains('ExamTree-$versionName-auth-debug'));
  });
}
