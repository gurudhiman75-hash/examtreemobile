import 'package:examtree/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('auth screen switches between sign-in and account creation', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Sign in to ExamTree'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Name'), findsNothing);
    expect(find.text('Confirm password'), findsNothing);

    final createAccount = find.text('New to ExamTree? Create account');
    await tester.ensureVisible(createAccount);
    await tester.tap(createAccount);
    await tester.pumpAndSettle();

    expect(find.text('Join ExamTree'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
    expect(find.text('Forgot password?'), findsNothing);
    expect(find.text('Create Account'), findsOneWidget);

    final signIn = find.text('Already have an account? Sign in');
    await tester.ensureVisible(signIn);
    await tester.tap(signIn);
    await tester.pumpAndSettle();

    expect(find.text('Sign in to ExamTree'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
  });
}
