import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Android release signing', () {
    test('release build never falls back to the debug signing config', () {
      final source = File('android/app/build.gradle.kts').readAsStringSync();
      final releaseBlock = RegExp(
        r'release\s*\{([\s\S]*?)\n\s{8}\}',
      ).firstMatch(source)?.group(1);

      expect(releaseBlock, isNotNull);
      expect(releaseBlock, contains('signingConfigs.getByName("release")'));
      expect(releaseBlock, isNot(contains('signingConfigs.getByName("debug")')));
      expect(source, contains('verifyReleaseSigning'));
      expect(source, contains('name == "preReleaseBuild"'));
    });

    test('release signing material is loaded from ignored key properties', () {
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();
      final gitignore = File('.gitignore').readAsStringSync();

      expect(gradle, contains('rootProject.file("key.properties")'));
      for (final property in [
        'storeFile',
        'storePassword',
        'keyAlias',
        'keyPassword',
      ]) {
        expect(gradle, contains('getProperty("$property")'));
      }
      expect(gitignore, contains('/android/key.properties'));
      expect(gitignore, contains('/android/*.jks'));
      expect(gitignore, contains('/android/*.keystore'));
    });

    test('release workflow requires private key inputs and verifies certificate', () {
      final workflow = File(
        '.github/workflows/release-android-aab.yml',
      ).readAsStringSync();

      expect(workflow, contains('workflow_dispatch:'));
      expect(workflow, contains('flutter build appbundle --release'));
      for (final secret in [
        'ANDROID_RELEASE_KEYSTORE_BASE64',
        'ANDROID_RELEASE_STORE_PASSWORD',
        'ANDROID_RELEASE_KEY_ALIAS',
        'ANDROID_RELEASE_KEY_PASSWORD',
        'ANDROID_RELEASE_CERT_SHA1',
      ]) {
        expect(workflow, contains(secret));
      }
      expect(workflow, contains('keytool -printcert -jarfile'));
      expect(workflow, contains('Remove signing material'));
    });
  });
}
