import 'dart:io';

import 'package:examtree/core/observability/crash_reporting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Crashlytics privacy-safe context', () {
    test('records route path without query parameters or fragments', () {
      final route = Uri.parse(
        '/review?id=result-secret&email=student%40example.com#answer-4',
      );

      expect(sanitizeCrashRoute(route), '/review');
    });

    test('does not accept non-app URI payloads as route context', () {
      expect(
        sanitizeCrashRoute(Uri.parse('mailto:student@example.com')),
        'unknown',
      );
    });

    test('keeps the observability version baseline aligned with pubspec', () {
      final versionLine = File('pubspec.yaml')
          .readAsLinesSync()
          .firstWhere((line) => line.trimLeft().startsWith('version:'));
      final declared = versionLine.split(':').last.trim().split('+').first;

      expect(examtreeCrashDefaultAppVersion, declared);
    });

    test('router reports only the sanitized URI boundary', () {
      final routerSource = File('lib/routes/app_router.dart').readAsStringSync();

      expect(routerSource, contains('recordCrashRoute(state.uri)'));
      expect(routerSource, isNot(contains('recordCrashRoute(state.extra)')));
      expect(routerSource, isNot(contains("setCustomKey('route_query'")));
    });
  });
}
