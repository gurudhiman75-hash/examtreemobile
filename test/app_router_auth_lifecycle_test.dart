import 'dart:io';

import 'package:examtree/routes/app_router.dart';
import 'package:examtree/routes/route_extra.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('auth router lifecycle', () {
    test('waits for Firebase restoration before redirecting', () {
      expect(
        resolveAuthRedirect(
          authReady: false,
          isAuthenticated: false,
          matchedLocation: '/home',
          uri: Uri.parse('/home'),
        ),
        isNull,
      );
    });

    test('signed-out protected route preserves its continuation', () {
      final redirect = resolveAuthRedirect(
        authReady: true,
        isAuthenticated: false,
        matchedLocation: '/exam-details',
        uri: Uri.parse('/exam-details?source=home'),
      );

      expect(redirect, startsWith('/login?continue='));
      final login = Uri.parse(redirect!);
      expect(
        login.queryParameters['continue'],
        '/exam-details?source=home',
      );
    });

    test('signed-out protected route carries extra identifier into continuation', () {
      final redirect = resolveAuthRedirect(
        authReady: true,
        isAuthenticated: false,
        matchedLocation: '/exam-details',
        uri: Uri.parse('/exam-details?source=home'),
        routeExtra: 'exam-123',
      );

      final login = Uri.parse(redirect!);
      expect(
        login.queryParameters['continue'],
        '/exam-details?source=home&id=exam-123',
      );
    });

    test('existing URI identifier remains authoritative during continuation', () {
      final redirect = resolveAuthRedirect(
        authReady: true,
        isAuthenticated: false,
        matchedLocation: '/review',
        uri: Uri.parse('/review?id=result-from-uri'),
        routeExtra: 'stale-result-extra',
      );

      final login = Uri.parse(redirect!);
      expect(
        login.queryParameters['continue'],
        '/review?id=result-from-uri',
      );
    });

    test('route identifier can be restored from the durable URI', () {
      expect(
        readRequiredRouteId(
          null,
          uri: Uri.parse('/test-attempt?id=attempt-exam-42'),
        ),
        'attempt-exam-42',
      );
    });

    test('URI identifier takes precedence over transient extra', () {
      expect(
        readRequiredRouteId(
          'old-extra',
          uri: Uri.parse('/exam-details?id=current-uri-id'),
        ),
        'current-uri-id',
      );
    });

    test('authenticated login continuation resumes the requested route', () {
      expect(
        resolveAuthRedirect(
          authReady: true,
          isAuthenticated: true,
          matchedLocation: '/login',
          uri: Uri.parse('/login?continue=%2Fexams'),
        ),
        '/exams',
      );
    });

    test('GoRouter is refreshed instead of rebuilt by auth stream emissions', () {
      final source = File('lib/routes/app_router.dart').readAsStringSync();

      expect(source, contains('refreshListenable: authRefresh'));
      expect(source, contains('auth.authStateChanges().listen'));
      expect(source, isNot(contains('ref.watch(authStateChangesProvider)')));
    });

    test('restored unverified Firebase sessions cannot enter protected routes', () {
      final source = File('lib/routes/app_router.dart').readAsStringSync();

      expect(source, contains('_user!.emailVerified'));
    });

    test('Google auth stays on login until canonical profile sync finishes', () {
      final source = File('lib/routes/app_router.dart').readAsStringSync();

      expect(
        source,
        contains('!_navigationGate.blocksAuthenticatedRedirect'),
      );
      expect(source, contains('_navigationGate.addListener'));
      expect(source, contains('_navigationGate.removeListener'));
    });
  });
}
