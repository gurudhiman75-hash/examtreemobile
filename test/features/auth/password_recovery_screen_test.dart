import 'package:examtree/features/auth/presentation/password_recovery_screen.dart';
import 'package:examtree/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sends a reset request and shows privacy-safe confirmation', (
    tester,
  ) async {
    final session = _FakeAuthSessionGateway();
    final controller = AuthController(session, _NoopProfileProvisioner());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authControllerProvider.overrideWithValue(controller)],
        child: const MaterialApp(
          home: PasswordRecoveryScreen(initialEmail: 'student@example.com'),
        ),
      ),
    );

    await tester.tap(find.text('Send reset email'));
    await tester.pumpAndSettle();

    expect(session.resetCalls, 1);
    expect(session.lastResetEmail, 'student@example.com');
    expect(find.text('Check your email'), findsOneWidget);
    expect(find.textContaining('If an ExamTree account exists'), findsOneWidget);
    expect(find.textContaining('we do not confirm'), findsOneWidget);
  });

  testWidgets('rejects an invalid email before calling Firebase', (tester) async {
    final session = _FakeAuthSessionGateway();
    final controller = AuthController(session, _NoopProfileProvisioner());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authControllerProvider.overrideWithValue(controller)],
        child: const MaterialApp(
          home: PasswordRecoveryScreen(initialEmail: 'invalid-email'),
        ),
      ),
    );

    await tester.tap(find.text('Send reset email'));
    await tester.pump();

    expect(session.resetCalls, 0);
    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });
}

class _FakeAuthSessionGateway implements AuthSessionGateway {
  int resetCalls = 0;
  String? lastResetEmail;

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    resetCalls++;
    lastResetEmail = email;
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {}

  @override
  Future<void> signOut() async {}
}

class _NoopProfileProvisioner implements StudentProfileProvisioner {
  @override
  Future<void> provision() async {}
}
