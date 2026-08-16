import 'dart:io';

import 'package:examtree/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGateway implements AuthSessionGateway {
  _FakeGateway({this.verificationRequired = false});

  final bool verificationRequired;
  int signInCalls = 0;
  int signOutCalls = 0;

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    signInCalls += 1;
    if (verificationRequired) {
      throw const AuthEmailVerificationRequiredException('student@example.com');
    }
  }

  @override
  Future<void> createUserWithEmailAndPassword({
    required String displayName,
    required String email,
    required String password,
  }) async {
    if (verificationRequired) {
      throw const AuthEmailVerificationRequiredException('student@example.com');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
  }
}

class _FakeProvisioner implements StudentProfileProvisioner {
  int calls = 0;

  @override
  Future<void> provision() async {
    calls += 1;
  }
}

void main() {
  group('email verification gate', () {
    test('does not provision a canonical profile before verification', () async {
      final gateway = _FakeGateway(verificationRequired: true);
      final provisioner = _FakeProvisioner();
      final controller = AuthController(gateway, provisioner);

      await expectLater(
        controller.signInWithEmailAndPassword('student@example.com', 'secret'),
        throwsA(isA<AuthEmailVerificationRequiredException>()),
      );

      expect(gateway.signInCalls, 1);
      expect(provisioner.calls, 0);
    });

    test('verified sign-in continues to profile provisioning', () async {
      final gateway = _FakeGateway();
      final provisioner = _FakeProvisioner();
      final controller = AuthController(gateway, provisioner);

      await controller.signInWithEmailAndPassword(
        'student@example.com',
        'secret',
      );

      expect(provisioner.calls, 1);
    });

    test('Firebase gateway sends verification and signs out unverified users', () {
      final source = File(
        'lib/features/auth/presentation/providers/auth_providers.dart',
      ).readAsStringSync();

      expect(source, contains('if (refreshed.emailVerified)'));
      expect(source, contains('await refreshed.sendEmailVerification();'));
      expect(source, contains('await _auth.signOut();'));
      expect(source, contains('AuthEmailVerificationRequiredException'));
      expect(source, contains('await refreshed.getIdToken(true);'));
    });
  });
}
