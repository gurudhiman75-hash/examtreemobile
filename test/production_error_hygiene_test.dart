import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('production error hygiene', () {
    test('startup diagnostics are only rendered in debug mode', () {
      final source = File('lib/main.dart').readAsStringSync();

      expect(source, contains("import 'package:flutter/foundation.dart';"));
      expect(source, contains('if (kDebugMode) ...['));
      expect(
        source,
        contains('Close and reopen the app. If the problem continues, try again later.'),
      );
    });

    test('Google sign-in does not interpolate raw exception details', () {
      final source = File(
        'lib/features/auth/presentation/login_screen.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('error.description')));
      expect(source, isNot(contains('error.message!.trim()')));
      expect(source, isNot(contains(r'Unable to sign in with Google: $error')));
      expect(source, isNot(contains(r'Google sign-in failed (${error.code}):')));
      expect(
        source,
        contains('Google sign-in could not be completed. Please try again.'),
      );
    });
  });
}
