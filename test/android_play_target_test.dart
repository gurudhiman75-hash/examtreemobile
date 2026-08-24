import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android release contract targets API 36 explicitly', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(gradle, contains('compileSdk = 36'));
    expect(gradle, contains('targetSdk = 36'));
    expect(gradle, isNot(contains('targetSdk = flutter.targetSdkVersion')));
  });

  test('Production AAB build pins the release Flutter SDK', () {
    final workflow =
        File('.github/workflows/release-android-aab.yml').readAsStringSync();

    expect(workflow, contains("flutter-version: '3.47.0'"));
    expect(workflow, contains('flutter build appbundle --release'));
    expect(workflow, contains('Verify release bundle certificate'));
  });
}
