import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/auth/presentation/widgets/auth_entry_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TextEditingController phone;
  late TextEditingController name;
  late TextEditingController email;
  late TextEditingController password;
  late TextEditingController confirmation;

  setUp(() {
    phone = TextEditingController();
    name = TextEditingController();
    email = TextEditingController();
    password = TextEditingController();
    confirmation = TextEditingController();
  });

  tearDown(() {
    phone.dispose();
    name.dispose();
    email.dispose();
    password.dispose();
    confirmation.dispose();
  });

  Widget view({
    bool registering = false,
    bool loading = false,
    bool showApple = false,
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
          phoneController: phone,
          nameController: name,
          emailController: email,
          passwordController: password,
          confirmPasswordController: confirmation,
          showApple: showApple,
          onPhoneContinue: () {},
          onApple: () {},
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
    expect(find.text('Login with Mobile Number'), findsOneWidget);
    expect(find.byKey(const Key('auth-phone')), findsOneWidget);
    expect(find.byKey(const Key('auth-phone-submit')), findsOneWidget);
    expect(find.byKey(const Key('auth-google')), findsOneWidget);
    expect(find.byKey(const Key('auth-email-toggle')), findsOneWidget);
    expect(find.text('Email'), findsNothing);
    expect(find.text('Password'), findsNothing);
    expect(find.text('Name'), findsNothing);
  });

  testWidgets('Apple sign-in is an equivalent iOS auth action when enabled', (
    tester,
  ) async {
    await tester.pumpWidget(view(showApple: true));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth-apple')), findsOneWidget);
    expect(find.byKey(const Key('auth-apple')), findsOneWidget);
    expect(find.byKey(const Key('auth-google')), findsOneWidget);
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
        showApple: true,
        loadingMessage: 'Starting ExamTree server…',
      ),
    );
    // The loading surface intentionally contains an indeterminate progress
    // indicator, so pumpAndSettle would wait forever for animation to stop.
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Starting ExamTree server…'), findsOneWidget);
    final phoneSubmit = tester.widget<FilledButton>(
      find.byKey(const Key('auth-phone-submit')),
    );
    final google = tester.widget<OutlinedButton>(
      find.byKey(const Key('auth-google')),
    );
    expect(phoneSubmit.onPressed, isNull);
    expect(google.onPressed, isNull);
  });
}
