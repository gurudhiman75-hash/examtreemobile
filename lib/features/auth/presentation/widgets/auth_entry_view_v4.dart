import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_spacing.dart';

class AuthEntryView extends StatefulWidget {
  const AuthEntryView({
    required this.registering,
    required this.isLoading,
    required this.obscurePassword,
    required this.loadingMessage,
    required this.phoneController,
    required this.otpController,
    required this.phoneCodeSent,
    required this.phoneNumber,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.showApple,
    required this.onPhoneContinue,
    required this.onVerifyPhoneCode,
    required this.onResendPhoneCode,
    required this.onChangePhone,
    required this.onApple,
    required this.onGoogle,
    required this.onSubmit,
    required this.onTogglePassword,
    required this.onForgotPassword,
    required this.onToggleMode,
    this.promotionalContent,
    super.key,
  });

  final bool registering;
  final bool isLoading;
  final bool obscurePassword;
  final String? loadingMessage;
  final TextEditingController phoneController;
  final TextEditingController otpController;
  final bool phoneCodeSent;
  final String? phoneNumber;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool showApple;
  final VoidCallback onPhoneContinue;
  final VoidCallback onVerifyPhoneCode;
  final VoidCallback onResendPhoneCode;
  final VoidCallback onChangePhone;
  final VoidCallback onApple;
  final VoidCallback onGoogle;
  final VoidCallback onSubmit;
  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;
  final VoidCallback onToggleMode;
  final Widget? promotionalContent;

  @override
  State<AuthEntryView> createState() => _AuthEntryViewState();
}

class _AuthEntryViewState extends State<AuthEntryView> {
  bool _emailExpanded = false;

  @override
  void didUpdateWidget(covariant AuthEntryView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.registering != oldWidget.registering) {
      _emailExpanded = widget.registering;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 520,
                    minHeight: constraints.maxHeight - 32,
                  ),
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _BrandHeader(),
                        if (widget.promotionalContent != null) ...[
                          const SizedBox(height: 10),
                          widget.promotionalContent!,
                        ],
                        const SizedBox(height: 14),
                        if (widget.isLoading &&
                            widget.loadingMessage != null) ...[
                          _LoadingStage(message: widget.loadingMessage!),
                          const SizedBox(height: 10),
                        ],
                        if (!widget.registering) ...[
                          if (widget.phoneCodeSent)
                            _OtpVerificationCard(
                              isLoading: widget.isLoading,
                              phoneNumber: widget.phoneNumber ?? '',
                              otpController: widget.otpController,
                              onVerify: widget.onVerifyPhoneCode,
                              onResend: widget.onResendPhoneCode,
                              onChangePhone: widget.onChangePhone,
                            )
                          else ...[
                            _MobileLoginCard(
                              isLoading: widget.isLoading,
                              phoneController: widget.phoneController,
                              onContinue: widget.onPhoneContinue,
                            ),
                            const SizedBox(height: 10),
                            const _DividerLabel(label: 'or continue with'),
                            const SizedBox(height: 10),
                            _CompactAlternativeRow(
                              showApple: widget.showApple,
                              isLoading: widget.isLoading,
                              onGoogle: widget.onGoogle,
                              onEmail: () {
                                setState(
                                  () => _emailExpanded = !_emailExpanded,
                                );
                              },
                              onApple: widget.onApple,
                            ),
                            if (_emailExpanded) ...[
                              const SizedBox(height: 12),
                              _EmailPanel(
                                registering: false,
                                isLoading: widget.isLoading,
                                obscurePassword: widget.obscurePassword,
                                nameController: widget.nameController,
                                emailController: widget.emailController,
                                passwordController: widget.passwordController,
                                confirmPasswordController:
                                    widget.confirmPasswordController,
                                onSubmit: widget.onSubmit,
                                onTogglePassword: widget.onTogglePassword,
                                onForgotPassword: widget.onForgotPassword,
                              ),
                            ],
                          ],
                        ] else ...[
                          Text(
                            'Create your ExamTree account',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF0B2343),
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.45,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Set up your account and keep your preparation synced.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF6C788B),
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _EmailPanel(
                            registering: true,
                            isLoading: widget.isLoading,
                            obscurePassword: widget.obscurePassword,
                            nameController: widget.nameController,
                            emailController: widget.emailController,
                            passwordController: widget.passwordController,
                            confirmPasswordController:
                                widget.confirmPasswordController,
                            onSubmit: widget.onSubmit,
                            onTogglePassword: widget.onTogglePassword,
                            onForgotPassword: widget.onForgotPassword,
                          ),
                        ],
                        const SizedBox(height: 10),
                        TextButton(
                          key: const Key('auth-toggle-mode'),
                          onPressed: widget.isLoading
                              ? null
                              : widget.onToggleMode,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFB2770D),
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          child: Text(
                            widget.registering
                                ? 'Already have an account? Sign in'
                                : 'New to ExamTree? Create account',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 13,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Secure sign-in. Your progress stays synced.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const SizedBox(
          width: 36,
          height: 36,
          child: CustomPaint(painter: _ExamtreeMarkPainter()),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'ExamTree',
            style: theme.textTheme.titleLarge?.copyWith(
              color: const Color(0xFF0B2343),
              fontWeight: FontWeight.w900,
              letterSpacing: -.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileLoginCard extends StatelessWidget {
  const _MobileLoginCard({
    required this.isLoading,
    required this.phoneController,
    required this.onContinue,
  });

  final bool isLoading;
  final TextEditingController phoneController;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E7EF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10284D).withValues(alpha: .08),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Login with Mobile Number',
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF0B2343),
              fontWeight: FontWeight.w900,
              letterSpacing: -.25,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'We’ll send you a one-time password (OTP)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6E7B90),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFBFCFE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD9E1EC)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                const Text(
                  '+91',
                  style: TextStyle(
                    color: Color(0xFF0D2C52),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF5E6D82),
                  size: 20,
                ),
                const SizedBox(width: 7),
                Container(
                  width: 1,
                  height: 28,
                  color: const Color(0xFFDCE3EC),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    key: const Key('auth-phone'),
                    controller: phoneController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    onSubmitted: (_) {
                      if (!isLoading) onContinue();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter mobile number',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            key: const Key('auth-phone-submit'),
            onPressed: isLoading ? null : onContinue,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: const Color(0xFF073A6A),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  const Color(0xFF073A6A).withValues(alpha: .42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Get OTP'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpVerificationCard extends StatefulWidget {
  const _OtpVerificationCard({
    required this.isLoading,
    required this.phoneNumber,
    required this.otpController,
    required this.onVerify,
    required this.onResend,
    required this.onChangePhone,
  });

  final bool isLoading;
  final String phoneNumber;
  final TextEditingController otpController;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onChangePhone;

  @override
  State<_OtpVerificationCard> createState() => _OtpVerificationCardState();
}

class _OtpVerificationCardState extends State<_OtpVerificationCard> {
  static const _resendDelaySeconds = 30;

  Timer? _resendTimer;
  int _resendSecondsRemaining = _resendDelaySeconds;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    _resendSecondsRemaining = _resendDelaySeconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSecondsRemaining <= 1) {
        timer.cancel();
        setState(() => _resendSecondsRemaining = 0);
        return;
      }
      setState(() => _resendSecondsRemaining--);
    });
  }

  String get _maskedPhone {
    final digits = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return widget.phoneNumber;
    final suffix = digits.substring(digits.length - 4);
    return '+91 ••••••$suffix';
  }

  void _resend() {
    if (widget.isLoading || _resendSecondsRemaining > 0) return;
    widget.onResend();
    _startResendCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canResend = !widget.isLoading && _resendSecondsRemaining == 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E7EF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10284D).withValues(alpha: .08),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2D2),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.sms_outlined,
                  color: Color(0xFFB2770D),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter OTP',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF0B2343),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Code sent to $_maskedPhone',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6E7B90),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: widget.isLoading ? null : widget.onChangePhone,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: const Color(0xFFB2770D),
                ),
                child: const Text('Change'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            key: const Key('auth-phone-otp'),
            controller: widget.otpController,
            enabled: !widget.isLoading,
            autofocus: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) {
              if (!widget.isLoading) widget.onVerify();
            },
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0B2343),
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: 12,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '••••••',
              hintStyle: TextStyle(
                color: const Color(0xFF9AA6B7).withValues(alpha: .72),
                letterSpacing: 12,
              ),
              filled: true,
              fillColor: const Color(0xFFFBFCFE),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFD9E1EC)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFD9E1EC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF0B3565), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            key: const Key('auth-phone-verify'),
            onPressed: widget.isLoading ? null : widget.onVerify,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: const Color(0xFF073A6A),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  const Color(0xFF073A6A).withValues(alpha: .42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Verify & Continue'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            key: const Key('auth-phone-resend'),
            onPressed: canResend ? _resend : null,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4E6077),
              disabledForegroundColor: const Color(0xFF9AA6B7),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            child: Text(
              _resendSecondsRemaining > 0
                  ? 'Resend OTP in ${_resendSecondsRemaining}s'
                  : 'Didn’t receive the code? Resend OTP',
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactAlternativeRow extends StatelessWidget {
  const _CompactAlternativeRow({
    required this.showApple,
    required this.isLoading,
    required this.onGoogle,
    required this.onEmail,
    required this.onApple,
  });

  final bool showApple;
  final bool isLoading;
  final VoidCallback onGoogle;
  final VoidCallback onEmail;
  final VoidCallback onApple;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CompactAuthButton(
          key: const Key('auth-google'),
          icon: const _GoogleMark(),
          tooltip: 'Continue with Google',
          onPressed: isLoading ? null : onGoogle,
        ),
        const SizedBox(width: 12),
        _CompactAuthButton(
          key: const Key('auth-email-toggle'),
          icon: const Icon(
            Icons.mail_outline_rounded,
            color: Color(0xFF153B69),
            size: 21,
          ),
          tooltip: 'Continue with Email',
          onPressed: isLoading ? null : onEmail,
        ),
        if (showApple) ...[
          const SizedBox(width: 12),
          _CompactAuthButton(
            key: const Key('auth-apple'),
            icon: const Icon(Icons.apple, color: Colors.black, size: 22),
            tooltip: 'Continue with Apple',
            onPressed: isLoading ? null : onApple,
          ),
        ],
      ],
    );
  }
}

class _CompactAuthButton extends StatelessWidget {
  const _CompactAuthButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 62,
        height: 44,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFDDE4ED)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
          child: icon,
        ),
      ),
    );
  }
}

class _EmailPanel extends StatelessWidget {
  const _EmailPanel({
    required this.registering,
    required this.isLoading,
    required this.obscurePassword,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onSubmit,
    required this.onTogglePassword,
    required this.onForgotPassword,
  });

  final bool registering;
  final bool isLoading;
  final bool obscurePassword;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSubmit;
  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffix,
    String? helper,
  }) {
    const border = Color(0xFFDDE4ED);
    return InputDecoration(
      labelText: label,
      helperText: helper,
      prefixIcon: Icon(icon, color: const Color(0xFF50647C)),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFFBFCFE),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF0B3565), width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E7EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!registering)
            Text(
              'Sign in with Email',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF0B2343),
                    fontWeight: FontWeight.w900,
                  ),
            ),
          if (!registering) const SizedBox(height: 8),
          if (registering) ...[
            TextField(
              controller: nameController,
              enabled: !isLoading,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              decoration: _decoration(
                label: 'Name',
                icon: Icons.person_outline_rounded,
              ),
            ),
            const SizedBox(height: 10),
          ],
          TextField(
            controller: emailController,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            autocorrect: false,
            decoration: _decoration(
              label: 'Email',
              icon: Icons.mail_outline_rounded,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: passwordController,
            enabled: !isLoading,
            obscureText: obscurePassword,
            textInputAction:
                registering ? TextInputAction.next : TextInputAction.done,
            autofillHints: [
              registering ? AutofillHints.newPassword : AutofillHints.password,
            ],
            onSubmitted: (_) {
              if (!isLoading && !registering) onSubmit();
            },
            decoration: _decoration(
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              helper: registering ? 'Use at least 6 characters.' : null,
              suffix: IconButton(
                tooltip: obscurePassword ? 'Show password' : 'Hide password',
                onPressed: isLoading ? null : onTogglePassword,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          if (registering) ...[
            const SizedBox(height: 10),
            TextField(
              controller: confirmPasswordController,
              enabled: !isLoading,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onSubmitted: (_) {
                if (!isLoading) onSubmit();
              },
              decoration: _decoration(
                label: 'Confirm password',
                icon: Icons.lock_reset_rounded,
              ),
            ),
          ] else ...[
            const SizedBox(height: 3),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isLoading ? null : onForgotPassword,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFB2770D),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Forgot password?'),
              ),
            ),
          ],
          SizedBox(height: registering ? 12 : 9),
          FilledButton(
            key: const Key('auth-submit'),
            onPressed: isLoading ? null : onSubmit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: const Color(0xFF0B3565),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
            child: Text(registering ? 'Create Account' : 'Sign In'),
          ),
        ],
      ),
    );
  }
}

class _LoadingStage extends StatelessWidget {
  const _LoadingStage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3D8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF0B3565),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF294866),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFDDE4ED))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF7A8799),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFDDE4ED))),
      ],
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Text(
      'G',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF4285F4),
            fontWeight: FontWeight.w900,
          ),
    );
  }
}

class _ExamtreeMarkPainter extends CustomPainter {
  const _ExamtreeMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final navy = Paint()..color = const Color(0xFF0756A5);
    final deep = Paint()..color = const Color(0xFF073A78);
    final gold = Paint()..color = const Color(0xFFF4A21B);

    final left = Path()
      ..moveTo(size.width * .08, size.height * .18)
      ..quadraticBezierTo(
        size.width * .30,
        size.height * .22,
        size.width * .48,
        size.height * .38,
      )
      ..lineTo(size.width * .48, size.height * .92)
      ..quadraticBezierTo(
        size.width * .28,
        size.height * .73,
        size.width * .08,
        size.height * .70,
      )
      ..close();
    canvas.drawPath(left, navy);

    final right = Path()
      ..moveTo(size.width * .92, size.height * .18)
      ..quadraticBezierTo(
        size.width * .70,
        size.height * .22,
        size.width * .52,
        size.height * .38,
      )
      ..lineTo(size.width * .52, size.height * .92)
      ..quadraticBezierTo(
        size.width * .72,
        size.height * .73,
        size.width * .92,
        size.height * .70,
      )
      ..close();
    canvas.drawPath(right, deep);

    final flame = Path()
      ..moveTo(size.width * .50, size.height * .12)
      ..cubicTo(
        size.width * .62,
        size.height * .04,
        size.width * .72,
        size.height * .17,
        size.width * .67,
        size.height * .31,
      )
      ..cubicTo(
        size.width * .63,
        size.height * .43,
        size.width * .55,
        size.height * .48,
        size.width * .50,
        size.height * .55,
      )
      ..cubicTo(
        size.width * .45,
        size.height * .48,
        size.width * .37,
        size.height * .43,
        size.width * .33,
        size.height * .31,
      )
      ..cubicTo(
        size.width * .28,
        size.height * .17,
        size.width * .38,
        size.height * .04,
        size.width * .50,
        size.height * .12,
      )
      ..close();
    canvas.drawPath(flame, gold);
  }

  @override
  bool shouldRepaint(covariant _ExamtreeMarkPainter oldDelegate) => false;
}
