import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/auth/presentation/login_screen.dart';
import 'package:examtree/features/auth/presentation/password_recovery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login and registration remain scrollable at 320 px and 200% text', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(320, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 800),
              devicePixelRatio: 1,
              textScaler: TextScaler.linear(2),
            ),
            child: LoginScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Sign in to ExamTree'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final createAccount = find.text('New to ExamTree? Create account');
    await tester.ensureVisible(createAccount);
    await tester.tap(createAccount);
    await tester.pumpAndSettle();

    expect(find.text('Join ExamTree'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('password recovery remains scrollable at 320 px and 200% text', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(320, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 800),
              devicePixelRatio: 1,
              textScaler: TextScaler.linear(2),
            ),
            child: PasswordRecoveryScreen(
              initialEmail: 'student@example.com',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Recover your account'), findsOneWidget);
    expect(find.text('Send reset email'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
