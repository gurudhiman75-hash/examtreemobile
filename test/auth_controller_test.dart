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

    test('provisions the canonical profile after registration', () async {
      final session = _FakeAuthSessionGateway();
      final profile = _FakeStudentProfileProvisioner();
      final controller = AuthController(session, profile);

      await controller.registerWithEmailAndPassword(
        displayName: ' Student Name ',
        email: ' student@example.com ',
        password: 'password',
      );

      expect(session.registrationCalls, 1);
      expect(session.lastDisplayName, 'Student Name');
      expect(session.lastEmail, 'student@example.com');
      expect(profile.provisionCalls, 1);
      expect(session.signOutCalls, 0);
    });

    test('does not provision when Firebase registration fails', () async {
      final session = _FakeAuthSessionGateway(
        registrationError: StateError('registration failed'),
      );
      final profile = _FakeStudentProfileProvisioner();
      final controller = AuthController(session, profile);

      await expectLater(
        controller.registerWithEmailAndPassword(
          displayName: 'Student',
          email: 'student@example.com',
          password: 'password',
        ),
        throwsA(isA<StateError>()),
      );

      expect(profile.provisionCalls, 0);
      expect(session.signOutCalls, 0);
    });

    test('registration signs out and explains partial setup failure', () async {
      final session = _FakeAuthSessionGateway();
      final profile = _FakeStudentProfileProvisioner(
        error: StateError('backend unavailable'),
      );
      final controller = AuthController(session, profile);

      await expectLater(
        controller.registerWithEmailAndPassword(
          displayName: 'Student',
          email: 'student@example.com',
          password: 'password',
        ),
        throwsA(
          isA<AuthProfileSyncException>().having(
            (error) => error.message,
            'message',
            contains('account was created'),
          ),
        ),
      );

      expect(profile.provisionCalls, 1);
      expect(session.signOutCalls, 1);
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

    test('delegates password reset with a trimmed email', () async {
      final session = _FakeAuthSessionGateway();
      final controller = AuthController(
        session,
        _FakeStudentProfileProvisioner(),
      );

      await controller.sendPasswordResetEmail(' student@example.com ');

      expect(session.passwordResetCalls, 1);
      expect(session.lastResetEmail, 'student@example.com');
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
  _FakeAuthSessionGateway({
    this.signInError,
    this.registrationError,
    this.passwordResetError,
    this.signOutError,
  });

  final Object? signInError;
  final Object? registrationError;
  final Object? passwordResetError;
  final Object? signOutError;

  int signInCalls = 0;
  int registrationCalls = 0;
  int passwordResetCalls = 0;
  int signOutCalls = 0;
  String? lastDisplayName;
  String? lastEmail;
  String? lastPassword;
  String? lastResetEmail;

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
  Future<void> createUserWithEmailAndPassword({
    required String displayName,
    required String email,
    required String password,
  }) async {
    registrationCalls++;
    lastDisplayName = displayName;
    lastEmail = email;
    lastPassword = password;
    final error = registrationError;
    if (error != null) throw error;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    passwordResetCalls++;
    lastResetEmail = email;
    final error = passwordResetError;
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
