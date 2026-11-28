import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../promotions/domain/promotion_campaign.dart';
import '../../promotions/presentation/widgets/promotion_carousel.dart';
import '../domain/auth_error_messages.dart';
import 'providers/auth_providers.dart';
import 'widgets/auth_entry_view.dart';
import '../../../l10n/l10n.dart';

const _loginFallbackCampaigns = <PromotionCampaign>[
  PromotionCampaign(
    id: 'login-feature-learn',
    title: 'Let’s build your exam success',
    subtitle:
        'Master concepts. Practice smarter. Get real results.',
    placements: {PromotionPlacement.login},
    priority: 30,
  ),
  PromotionCampaign(
    id: 'login-feature-practice',
    title: 'Practice the way real exams ask',
    subtitle:
        'Use focused mock tests and detailed solutions to turn preparation into exam readiness.',
    placements: {PromotionPlacement.login},
    priority: 20,
  ),
  PromotionCampaign(
    id: 'login-feature-progress',
    title: 'Know what to revise next',
    subtitle:
        'Continue where you left off and use your progress to keep revision targeted.',
    placements: {PromotionPlacement.login},
    priority: 10,
  ),
];


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _registerMode = false;
  PhoneVerificationSession? _phoneVerificationSession;
  String? _loadingMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_registerMode) {
      await _register();
    } else {
      await _login();
    }
  }

  Future<void> _login() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!AuthErrorMessages.isValidEmail(email)) {
      _showMessage(context.l10n.loginEnterAValidEmailAddress);
      return;
    }
    if (password.isEmpty) {
      _showMessage(context.l10n.loginEnterYourPassword);
      return;
    }

    _beginLoading(context.l10n.loginPreparingSignIn);
    try {
      await ref.read(authControllerProvider).signInWithEmailAndPassword(
            email,
            password,
            onSetupStage: _onSetupStage,
          );
    } on AuthServerStartException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } on AuthEmailVerificationRequiredException catch (error) {
      if (!mounted) return;
      _showMessage(
        '${error.message} Open the link in your email, then return here and sign in again.',
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showMessage(AuthErrorMessages.login(error));
    } on AuthProfileSyncException catch (error) {
      if (!mounted) return;
      _showMessage('${error.message} Please try again.');
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.loginUnableToSignInPlease);
    } finally {
      _endLoading();
    }
  }

  String? _normalizedIndianPhone() {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10 || digits.startsWith('0')) return null;
    return '+91$digits';
  }

  String _phoneErrorMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-phone-number' => context.l10n.loginEnterAValidMobileNumber,
      'too-many-requests' =>
        context.l10n.loginTooManyVerificationAttemptsPlease,
      'quota-exceeded' =>
        context.l10n.loginSmsVerificationIsTemporarilyUnavailable,
      'app-not-authorized' =>
        context.l10n.loginThisExamtreeBuildIsNot,
      'captcha-check-failed' =>
        context.l10n.loginPhoneVerificationCouldNotBe,
      'network-request-failed' =>
        context.l10n.loginCouldNotReachTheVerification,
      'session-expired' =>
        context.l10n.loginThisVerificationSessionHasExpired,
      'invalid-verification-code' => context.l10n.loginTheOtpYouEnteredIs,
      'operation-not-allowed' =>
        context.l10n.loginPhoneSignInIsNot,
      _ => context.l10n.loginUnableToVerifyThisMobile,
    };
  }

  Future<void> _startPhoneSignIn() async {
    if (_isLoading) return;
    final phoneNumber = _normalizedIndianPhone();
    if (phoneNumber == null) {
      _showMessage(context.l10n.loginEnterAValid10Digit);
      return;
    }

    _beginLoading(context.l10n.loginSendingOtp);
    try {
      final result = await ref.read(authControllerProvider).startPhoneVerification(
            phoneNumber,
            onSetupStage: _onSetupStage,
          );
      if (!mounted) return;
      if (result is PhoneVerificationCodeSent) {
        setState(() {
          _phoneVerificationSession = result.session;
          _otpController.clear();
        });
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showMessage(_phoneErrorMessage(error));
    } on AuthProfileSyncException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.loginUnableToSendTheOtp);
    } finally {
      _endLoading();
    }
  }

  Future<void> _verifyPhoneOtp() async {
    if (_isLoading) return;
    final session = _phoneVerificationSession;
    if (session == null) {
      _showMessage(context.l10n.loginRequestANewOtpFirst);
      return;
    }

    final code = _otpController.text.replaceAll(RegExp(r'\D'), '');
    if (code.length != 6) {
      _showMessage(context.l10n.loginEnterThe6DigitOtp);
      return;
    }

    _beginLoading(context.l10n.loginVerifyingOtp);
    try {
      await ref.read(authControllerProvider).confirmPhoneVerification(
            session: session,
            smsCode: code,
            onSetupStage: _onSetupStage,
          );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showMessage(_phoneErrorMessage(error));
    } on AuthProfileSyncException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.loginUnableToVerifyTheOtp);
    } finally {
      _endLoading();
    }
  }

  Future<void> _resendPhoneOtp() async {
    if (_isLoading) return;
    final session = _phoneVerificationSession;
    if (session == null) {
      await _startPhoneSignIn();
      return;
    }

    _beginLoading(context.l10n.loginSendingANewOtp);
    try {
      final result = await ref.read(authControllerProvider).startPhoneVerification(
            session.phoneNumber,
            forceResendingToken: session.forceResendingToken,
            onSetupStage: _onSetupStage,
          );
      if (!mounted) return;
      if (result is PhoneVerificationCodeSent) {
        setState(() {
          _phoneVerificationSession = result.session;
          _otpController.clear();
        });
        _showMessage('A new OTP has been sent.');
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showMessage(_phoneErrorMessage(error));
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.loginUnableToResendTheOtp);
    } finally {
      _endLoading();
    }
  }

  void _changePhoneNumber() {
    if (_isLoading) return;
    setState(() {
      _phoneVerificationSession = null;
      _otpController.clear();
    });
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;
    _beginLoading(context.l10n.loginPreparingGoogleSignIn);
    try {
      await ref.read(authControllerProvider).signInWithGoogle(
            onSetupStage: _onSetupStage,
          );
    } on AuthServerStartException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } on GoogleSignInException catch (error) {
      if (!mounted) return;
      if (error.code == GoogleSignInExceptionCode.canceled) {
        _showMessage(context.l10n.loginGoogleSignInWasCanceled);
        return;
      }
      _showMessage(context.l10n.loginGoogleSignInCouldNot2);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message = switch (error.code) {
        'operation-not-allowed' =>
          context.l10n.loginGoogleSignInIsTemporarily,
        'account-exists-with-different-credential' =>
          context.l10n.loginThisEmailAlreadyHasAn,
        'google-email-unverified' =>
          context.l10n.loginGoogleDidNotProvideA,
        'network-request-failed' =>
          context.l10n.loginGoogleSignInCouldNot,
        _ => context.l10n.loginGoogleSignInCouldNot2,
      };
      _showMessage(message);
    } on AuthProfileSyncException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.loginUnableToSignInWith);
    } finally {
      _endLoading();
    }
  }

  Future<void> _signInWithApple() async {
    if (_isLoading) return;
    _beginLoading(context.l10n.loginPreparingAppleSignIn);
    try {
      await ref.read(authControllerProvider).signInWithApple(
            onSetupStage: _onSetupStage,
          );
    } on AuthServerStartException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message = switch (error.code) {
        'web-context-cancelled' || 'canceled' =>
          context.l10n.loginAppleSignInWasCanceled,
        'operation-not-allowed' =>
          context.l10n.loginAppleSignInIsTemporarily,
        'account-exists-with-different-credential' =>
          context.l10n.loginThisEmailAlreadyHasAn2,
        'apple-email-unavailable' =>
          context.l10n.loginAppleDidNotProvideA,
        'network-request-failed' =>
          context.l10n.loginAppleSignInCouldNot,
        _ => context.l10n.loginAppleSignInCouldNot2,
      };
      _showMessage(message);
    } on AuthProfileSyncException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.loginUnableToSignInWith2);
    } finally {
      _endLoading();
    }
  }

  Future<void> _register() async {
    if (_isLoading) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmation = _confirmPasswordController.text;

    if (name.length < 2) {
      _showMessage(context.l10n.loginEnterYourName);
      return;
    }
    if (name.length > 80) {
      _showMessage(context.l10n.loginNameMustBe80Characters);
      return;
    }
    if (!AuthErrorMessages.isValidEmail(email)) {
      _showMessage(context.l10n.loginEnterAValidEmailAddress);
      return;
    }
    if (password.length < 6) {
      _showMessage(context.l10n.loginUseAtLeast6Characters);
      return;
    }
    if (password != confirmation) {
      _showMessage(context.l10n.loginPasswordsDoNotMatch);
      return;
    }

    _beginLoading(context.l10n.loginPreparingAccountSetup);
    try {
      await ref.read(authControllerProvider).registerWithEmailAndPassword(
            displayName: name,
            email: email,
            password: password,
            onSetupStage: _onSetupStage,
          );
    } on AuthServerStartException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } on AuthEmailVerificationRequiredException catch (error) {
      if (!mounted) return;
      _showMessage(
        '${error.message} Open the link in your email, then return here and sign in.',
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showMessage(AuthErrorMessages.registration(error));
    } on AuthProfileSyncException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.loginUnableToCreateYourAccount);
    } finally {
      _endLoading();
    }
  }

  void _beginLoading(String message) {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadingMessage = message;
    });
  }

  void _onSetupStage(AuthSetupStage stage) {
    if (!mounted) return;
    setState(() => _loadingMessage = stage.message);
  }

  void _endLoading() {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _loadingMessage = null;
    });
  }

  void _toggleMode() {
    if (_isLoading) return;
    setState(() {
      _registerMode = !_registerMode;
      _confirmPasswordController.clear();
    });
  }

  void _openPasswordRecovery() {
    if (_isLoading) return;
    final email = _emailController.text.trim();
    final query = AuthErrorMessages.isValidEmail(email)
        ? '?email=${Uri.encodeQueryComponent(email)}'
        : '';
    context.push('/forgot-password$query');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 8),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final showApple = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    return AuthEntryView(
      registering: _registerMode,
      isLoading: _isLoading,
      obscurePassword: _obscurePassword,
      loadingMessage: _loadingMessage,
      phoneController: _phoneController,
      otpController: _otpController,
      phoneCodeSent: _phoneVerificationSession != null,
      phoneNumber: _phoneVerificationSession?.phoneNumber,
      nameController: _nameController,
      emailController: _emailController,
      passwordController: _passwordController,
      confirmPasswordController: _confirmPasswordController,
      promotionalContent: const PromotionPlacementView(
        placement: PromotionPlacement.login,
        markLoginCampaignsPresented: true,
        visualStyle: PromotionCarouselVisualStyle.loginFeature,
        fallbackCampaigns: _loginFallbackCampaigns,
      ),
      showApple: showApple,
      onPhoneContinue: _startPhoneSignIn,
      onVerifyPhoneCode: _verifyPhoneOtp,
      onResendPhoneCode: _resendPhoneOtp,
      onChangePhone: _changePhoneNumber,
      onApple: _signInWithApple,
      onGoogle: _signInWithGoogle,
      onSubmit: _submit,
      onTogglePassword: () {
        if (_isLoading) return;
        setState(() => _obscurePassword = !_obscurePassword);
      },
      onForgotPassword: _openPasswordRecovery,
      onToggleMode: _toggleMode,
    );
  }
}
