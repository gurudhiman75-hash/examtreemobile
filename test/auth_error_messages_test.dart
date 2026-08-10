import 'package:examtree/features/auth/domain/auth_error_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthErrorMessages', () {
    test('maps invalid credentials without revealing account existence', () {
      for (final code in ['wrong-password', 'invalid-credential', 'user-not-found']) {
        expect(
          AuthErrorMessages.login(FirebaseAuthException(code: code)),
          'Email or password is incorrect.',
        );
      }
    });

    test('maps network and rate-limit failures to useful messages', () {
      expect(
        AuthErrorMessages.login(
          FirebaseAuthException(code: 'network-request-failed'),
        ),
        contains('internet connection'),
      );
      expect(
        AuthErrorMessages.login(FirebaseAuthException(code: 'too-many-requests')),
        contains('Too many'),
      );
    });

    test('registration explains existing account and weak password cases', () {
      expect(
        AuthErrorMessages.registration(
          FirebaseAuthException(code: 'email-already-in-use'),
        ),
        contains('Sign in or reset'),
      );
      expect(
        AuthErrorMessages.registration(
          FirebaseAuthException(code: 'weak-password'),
        ),
        contains('too weak'),
      );
    });

    test('treats user-not-found reset as privacy-safe success', () {
      final failure = AuthErrorMessages.passwordReset(
        FirebaseAuthException(code: 'user-not-found'),
      );

      expect(failure.shouldShowSuccess, isTrue);
      expect(failure.message, isEmpty);
    });

    test('validates practical email addresses', () {
      expect(AuthErrorMessages.isValidEmail('student@example.com'), isTrue);
      expect(AuthErrorMessages.isValidEmail(' student@example.com '), isTrue);
      expect(AuthErrorMessages.isValidEmail('student@example'), isFalse);
      expect(AuthErrorMessages.isValidEmail('student@@example.com'), isFalse);
      expect(AuthErrorMessages.isValidEmail(''), isFalse);
    });
  });
}
