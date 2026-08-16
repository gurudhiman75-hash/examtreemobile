import 'dart:io';

import 'package:examtree/routes/app_router.dart';
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
  });
}
