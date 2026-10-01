import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/auth/presentation/widgets/auth_entry_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TextEditingController phone;
  late TextEditingController otp;
  late TextEditingController name;
  late TextEditingController email;
  late TextEditingController password;
  late TextEditingController confirmation;

  setUp(() {
    phone = TextEditingController();
    otp = TextEditingController();
    name = TextEditingController();
    email = TextEditingController();
    password = TextEditingController();
    confirmation = TextEditingController();
  });

  tearDown(() {
    phone.dispose();
    otp.dispose();
    name.dispose();
    email.dispose();
    password.dispose();
    confirmation.dispose();
  });

  Widget view({
    bool registering = false,
    bool loading = false,
    bool showApple = false,
    bool phoneCodeSent = false,
    String? phoneNumber,
    String? loadingMessage,
    double textScale = 1,
    VoidCallback? onVerifyPhoneCode,
    VoidCallback? onResendPhoneCode,
    VoidCallback? onChangePhone,
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
          otpController: otp,
          phoneCodeSent: phoneCodeSent,
          phoneNumber: phoneNumber,
          nameController: name,
          emailController: email,
          passwordController: password,
          confirmPasswordController: confirmation,
          showApple: showApple,
          onPhoneContinue: () {},
          onVerifyPhoneCode: onVerifyPhoneCode ?? () {},
          onResendPhoneCode: onResendPhoneCode ?? () {},
          onChangePhone: onChangePhone ?? () {},
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
    expect(find.byKey(const Key('auth-google')), findsOneWidget);
  });

  testWidgets('OTP state masks the number and rate-limits resend', (
    tester,
  ) async {
    var resendCalls = 0;
    var changeCalls = 0;

    await tester.pumpWidget(
      view(
        phoneCodeSent: true,
        phoneNumber: '+919876543210',
        onResendPhoneCode: () => resendCalls++,
        onChangePhone: () => changeCalls++,
      ),
    );
    await tester.pump();

    expect(find.text('Enter OTP'), findsOneWidget);
    expect(find.text('Code sent to +91 ••••••3210'), findsOneWidget);
    expect(find.byKey(const Key('auth-phone-otp')), findsOneWidget);
    expect(find.byKey(const Key('auth-phone-verify')), findsOneWidget);

    final resendFinder = find.byKey(const Key('auth-phone-resend'));
    var resend = tester.widget<TextButton>(resendFinder);
    expect(resend.onPressed, isNull);

    await tester.pump(const Duration(seconds: 30));
    resend = tester.widget<TextButton>(resendFinder);
    expect(resend.onPressed, isNotNull);

    await tester.ensureVisible(resendFinder);
    await tester.tap(resendFinder);
    await tester.pump();
    expect(resendCalls, 1);
    resend = tester.widget<TextButton>(resendFinder);
    expect(resend.onPressed, isNull);

    await tester.ensureVisible(find.text('Change'));
    await tester.tap(find.text('Change'));
    expect(changeCalls, 1);
  });

  testWidgets('registration remains usable at 200 percent text scaling', (
    tester,
  ) async {
    await tester.pumpWidget(view(registering: true, textScale: 2));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Create your ExamTree account'), findsOneWidget);
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
      find.descendant(
        of: find.byKey(const Key('auth-google')),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(phoneSubmit.onPressed, isNull);
    expect(google.onPressed, isNull);
  });
}
