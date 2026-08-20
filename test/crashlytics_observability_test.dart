import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Crashlytics observability', () {
    test('uses current Firebase Crashlytics Flutter and Android plugins', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final settings = File('android/settings.gradle.kts').readAsStringSync();
      final appGradle = File('android/app/build.gradle.kts').readAsStringSync();

      expect(pubspec, contains('firebase_crashlytics: ^5.2.7'));
      expect(
        settings,
        contains('id("com.google.firebase.crashlytics") version "3.0.7" apply false'),
      );
      expect(appGradle, contains('id("com.google.firebase.crashlytics")'));
    });

    test('captures framework and uncaught platform failures only in release', () {
      final source = File(
        'lib/core/observability/crash_reporting.dart',
      ).readAsStringSync();
      final main = File('lib/main.dart').readAsStringSync();

      expect(source, contains('setCrashlyticsCollectionEnabled(!kDebugMode)'));
      expect(source, contains('FlutterError.onError ='));
      expect(source, contains('PlatformDispatcher.instance.onError ='));
      expect(source, contains('fatal: true'));
      expect(main, contains('await configureCrashReporting()'));
    });

    test('does not send raw exception messages or learner identifiers', () {
      final source = File(
        'lib/core/observability/crash_reporting.dart',
      ).readAsStringSync();

      expect(source, contains('SanitizedUnhandledError'));
      expect(source, contains('error.runtimeType.toString()'));
      expect(source, contains('details.exception.runtimeType.toString()'));
      expect(source, isNot(contains('error.toString()')));
      expect(source, isNot(contains('details.exception.toString()')));
      expect(source, isNot(contains('setUserIdentifier')));
      expect(source, isNot(contains("setCustomKey('email'")));
      expect(source, isNot(contains("setCustomKey('question'")));
      expect(source, isNot(contains("setCustomKey('answer'")));
      expect(source, contains("setCustomKey('error_payload_policy', 'sanitized')"));
    });

    test('CI publishes the resolver-generated lockfile', () {
      final workflow = File('.github/workflows/flutter-ci.yml').readAsStringSync();
      expect(workflow, contains('pubspec.lock'));
    });
  });
}
