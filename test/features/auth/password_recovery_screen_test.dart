import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/auth/presentation/password_recovery_screen.dart';
import 'package:examtree/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<({ _FakeAuthSessionGateway session, AuthController controller })>
      pumpRecovery(
    WidgetTester tester, {
    required String initialEmail,
    double textScale = 1,
  }) async {
    final session = _FakeAuthSessionGateway();
    final controller = AuthController(session, _NoopProfileProvisioner());

    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authControllerProvider.overrideWithValue(controller)],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              textScaler: TextScaler.linear(textScale),
              disableAnimations: true,
            ),
            child: PasswordRecoveryScreen(initialEmail: initialEmail),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    return (session: session, controller: controller);
  }

  testWidgets('sends a reset request and shows privacy-safe confirmation', (
    tester,
  ) async {
    final harness = await pumpRecovery(
      tester,
      initialEmail: 'student@example.com',
    );

    await tester.tap(find.byKey(const Key('password-recovery-send')));
    await tester.pumpAndSettle();

    expect(harness.session.resetCalls, 1);
    expect(harness.session.lastResetEmail, 'student@example.com');
    expect(find.text('Check your email'), findsOneWidget);
    expect(find.textContaining('If an ExamTree account exists'), findsOneWidget);
    expect(find.textContaining('we do not confirm'), findsOneWidget);
    expect(find.byKey(const Key('password-recovery-back')), findsOneWidget);
  });

  testWidgets('rejects an invalid email before calling Firebase', (tester) async {
    final harness = await pumpRecovery(
      tester,
      initialEmail: 'invalid-email',
    );

    await tester.tap(find.byKey(const Key('password-recovery-send')));
    await tester.pump();

    expect(harness.session.resetCalls, 0);
    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });

  testWidgets('recovery form remains usable at 200 percent text scaling', (
    tester,
  ) async {
    await pumpRecovery(
      tester,
      initialEmail: 'student@example.com',
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Recover your account'), findsOneWidget);
    expect(find.byKey(const Key('password-recovery-email')), findsOneWidget);

    final send = find.byKey(const Key('password-recovery-send'));
    await tester.ensureVisible(send);
    expect(send, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('success state remains usable at 200 percent text scaling', (
    tester,
  ) async {
    await pumpRecovery(
      tester,
      initialEmail: 'student@example.com',
      textScale: 2,
    );

    final send = find.byKey(const Key('password-recovery-send'));
    await tester.ensureVisible(send);
    await tester.tap(send);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Check your email'), findsOneWidget);
    final back = find.byKey(const Key('password-recovery-back'));
    await tester.ensureVisible(back);
    expect(back, findsOneWidget);
    expect(find.byKey(const Key('password-recovery-edit')), findsOneWidget);
    expect(find.byKey(const Key('password-recovery-resend')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeAuthSessionGateway implements AuthSessionGateway {
  int resetCalls = 0;
  String? lastResetEmail;

  @override
  Future<void> createUserWithEmailAndPassword({
    required String displayName,
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    resetCalls++;
    lastResetEmail = email;
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}
}

class _NoopProfileProvisioner implements StudentProfileProvisioner {
  @override
  Future<void> provision() async {}
}
