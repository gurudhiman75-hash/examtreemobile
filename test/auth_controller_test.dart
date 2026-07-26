import 'package:examtree/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthController', () {
    test('provisions the canonical profile after authentication', () async {
      final session = _FakeAuthSessionGateway();
      final profile = _FakeStudentProfileProvisioner();
      final controller = AuthController(session, profile);

      await controller.signInWithEmailAndPassword(
        'student@example.com',
        'password',
      );

      expect(session.signInCalls, 1);
      expect(session.lastEmail, 'student@example.com');
      expect(profile.provisionCalls, 1);
      expect(session.signOutCalls, 0);
    });

    test('does not provision when Firebase authentication fails', () async {
      final session = _FakeAuthSessionGateway(
        signInError: StateError('invalid credentials'),
      );
      final profile = _FakeStudentProfileProvisioner();
      final controller = AuthController(session, profile);

      await expectLater(
        controller.signInWithEmailAndPassword(
          'student@example.com',
          'wrong-password',
        ),
        throwsA(isA<StateError>()),
      );

      expect(profile.provisionCalls, 0);
      expect(session.signOutCalls, 0);
    });

    test('signs out when canonical profile provisioning fails', () async {
      final session = _FakeAuthSessionGateway();
      final profile = _FakeStudentProfileProvisioner(
        error: StateError('backend unavailable'),
      );
      final controller = AuthController(session, profile);

      await expectLater(
        controller.signInWithEmailAndPassword(
          'student@example.com',
          'password',
        ),
        throwsA(
          isA<AuthProfileSyncException>().having(
            (error) => error.message,
            'message',
            'Unable to prepare your ExamTree student profile.',
          ),
        ),
      );

      expect(profile.provisionCalls, 1);
      expect(session.signOutCalls, 1);
    });

    test('preserves provisioning error when sign-out also fails', () async {
      final session = _FakeAuthSessionGateway(
        signOutError: StateError('sign-out failed'),
      );
      final profile = _FakeStudentProfileProvisioner(
        error: StateError('backend unavailable'),
      );
      final controller = AuthController(session, profile);

      await expectLater(
        controller.signInWithEmailAndPassword(
          'student@example.com',
          'password',
        ),
        throwsA(isA<AuthProfileSyncException>()),
      );

      expect(session.signOutCalls, 1);
    });

    test('delegates explicit sign-out', () async {
      final session = _FakeAuthSessionGateway();
      final controller = AuthController(
        session,
        _FakeStudentProfileProvisioner(),
      );

      await controller.signOut();

      expect(session.signOutCalls, 1);
    });
  });
}

class _FakeAuthSessionGateway implements AuthSessionGateway {
  _FakeAuthSessionGateway({this.signInError, this.signOutError});

  final Object? signInError;
  final Object? signOutError;

  int signInCalls = 0;
  int signOutCalls = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    signInCalls++;
    lastEmail = email;
    lastPassword = password;
    final error = signInError;
    if (error != null) throw error;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    final error = signOutError;
    if (error != null) throw error;
  }
}

class _FakeStudentProfileProvisioner implements StudentProfileProvisioner {
  _FakeStudentProfileProvisioner({this.error});

  final Object? error;
  int provisionCalls = 0;

  @override
  Future<void> provision() async {
    provisionCalls++;
    final provisionError = error;
    if (provisionError != null) throw provisionError;
  }
}
