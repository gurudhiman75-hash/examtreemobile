import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/auth/presentation/widgets/auth_entry_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TextEditingController name;
  late TextEditingController email;
  late TextEditingController password;
  late TextEditingController confirmation;

  setUp(() {
    name = TextEditingController();
    email = TextEditingController();
    password = TextEditingController();
    confirmation = TextEditingController();
  });

  tearDown(() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirmation.dispose();
  });

  Widget view({
    bool registering = false,
    bool loading = false,
    String? loadingMessage,
    double textScale = 1,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(390, 844),
          textScaler: TextScaler.linear(textScale),
        ),
        child: AuthEntryView(
          registering: registering,
          isLoading: loading,
          obscurePassword: true,
          loadingMessage: loadingMessage,
          nameController: name,
          emailController: email,
          passwordController: password,
          confirmPasswordController: confirmation,
          onGoogle: () {},
          onSubmit: () {},
          onTogglePassword: () {},
          onForgotPassword: () {},
          onToggleMode: () {},
        ),
      ),
    );
  }

  testWidgets('sign-in hierarchy keeps Google and email paths obvious', (
    tester,
  ) async {
    await tester.pumpWidget(view());
    await tester.pumpAndSettle();

    expect(find.text('ExamTree'), findsOneWidget);
    expect(find.text('Sign in to ExamTree'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.byKey(const Key('auth-submit')), findsOneWidget);
    expect(find.text('Name'), findsNothing);
  });

  testWidgets('registration remains usable at 200 percent text scaling', (
    tester,
  ) async {
    await tester.pumpWidget(view(registering: true, textScale: 2));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Join ExamTree'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);

    final toggle = find.byKey(const Key('auth-toggle-mode'));
    await tester.ensureVisible(toggle);
    expect(toggle, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading state disables auth actions and exposes progress copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      view(
        loading: true,
        loadingMessage: 'Starting ExamTree server…',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Starting ExamTree server…'), findsOneWidget);
    final google = tester.widget<OutlinedButton>(
      find.byKey(const Key('auth-google')),
    );
    final submit = tester.widget<FilledButton>(
      find.byKey(const Key('auth-submit')),
    );
    expect(google.onPressed, isNull);
    expect(submit.onPressed, isNull);
  });
}
