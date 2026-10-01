import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class AuthEntryView extends StatelessWidget {
  const AuthEntryView({
    required this.registering,
    required this.isLoading,
    required this.obscurePassword,
    required this.loadingMessage,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.showApple,
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
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool showApple;
  final VoidCallback onApple;
  final VoidCallback onGoogle;
  final VoidCallback onSubmit;
  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;
  final VoidCallback onToggleMode;
  final Widget? promotionalContent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 520,
                    minHeight: constraints.maxHeight - 38,
                  ),
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _PremiumBrandHeader(),
                        if (promotionalContent != null) ...[
                          const SizedBox(height: 14),
                          promotionalContent!,
                        ],
                        const SizedBox(height: 18),
                        Text(
                          registering ? 'Join ExamTree' : 'Sign in to ExamTree',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF0A2546),
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.55,
                            height: 1.06,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          registering
                              ? 'Save your preparation, progress and test history in one place.'
                              : 'Welcome back. Continue your preparation from where you left off.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF687487),
                            height: 1.35,
                          ),
                        ),
                        if (isLoading && loadingMessage != null) ...[
                          const SizedBox(height: 10),
                          _LoadingStage(message: loadingMessage!),
                        ],
                        const SizedBox(height: 15),
                        _AuthPanel(
                          registering: registering,
                          isLoading: isLoading,
                          obscurePassword: obscurePassword,
                          nameController: nameController,
                          emailController: emailController,
                          passwordController: passwordController,
                          confirmPasswordController: confirmPasswordController,
                          showApple: showApple,
                          onApple: onApple,
                          onGoogle: onGoogle,
                          onSubmit: onSubmit,
                          onTogglePassword: onTogglePassword,
                          onForgotPassword: onForgotPassword,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          key: const Key('auth-toggle-mode'),
                          onPressed: isLoading ? null : onToggleMode,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF0B3565),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: Text(
                            registering
                                ? 'Already have an account? Sign in'
                                : 'New to ExamTree? Create account',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Your attempts and progress stay synced across ExamTree.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.3,
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

class _PremiumBrandHeader extends StatelessWidget {
  const _PremiumBrandHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const SizedBox(
          width: 38,
          height: 38,
          child: CustomPaint(painter: _ExamtreeMarkPainter()),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ExamTree',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF0B2343),
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.45,
                ),
              ),
              Text(
                'LEARN · PRACTICE · EXCEL',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF8B6A26),
                  fontWeight: FontWeight.w800,
                  letterSpacing: .65,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthPanel extends StatelessWidget {
  const _AuthPanel({
    required this.registering,
    required this.isLoading,
    required this.obscurePassword,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.showApple,
    required this.onApple,
    required this.onGoogle,
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
  final bool showApple;
  final VoidCallback onApple;
  final VoidCallback onGoogle;
  final VoidCallback onSubmit;
  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    InputDecoration fieldDecoration({
      required String label,
      required IconData icon,
      Widget? suffix,
      String? helper,
    }) {
      const borderColor = Color(0xFFDDD7CC);
      return InputDecoration(
        labelText: label,
        helperText: helper,
        prefixIcon: Icon(icon, color: const Color(0xFF526378)),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: .88),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF0B3565),
            width: 1.5,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showApple) ...[
          FilledButton.icon(
            key: const Key('auth-apple'),
            onPressed: isLoading ? null : onApple,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.black.withValues(alpha: .35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            icon: const Icon(Icons.apple, size: 22),
            label: const Text('Continue with Apple'),
          ),
          const SizedBox(height: 10),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10264A).withValues(alpha: .07),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: OutlinedButton.icon(
            key: const Key('auth-google'),
            onPressed: isLoading ? null : onGoogle,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF17243A),
              side: const BorderSide(color: Color(0xFFE1DDD5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            icon: const _GoogleMark(),
            label: const Text('Continue with Google'),
          ),
        ),
        const SizedBox(height: 15),
        const _DividerLabel(label: 'or continue with email'),
        const SizedBox(height: 13),
        if (registering) ...[
          TextField(
            controller: nameController,
            enabled: !isLoading,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            decoration: fieldDecoration(
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
          decoration: fieldDecoration(
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
          decoration: fieldDecoration(
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
            decoration: fieldDecoration(
              label: 'Confirm password',
              icon: Icons.lock_reset_rounded,
            ),
          ),
        ] else ...[
          const SizedBox(height: 1),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: isLoading ? null : onForgotPassword,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFB27B10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
              child: const Text('Forgot password?'),
            ),
          ),
        ],
        SizedBox(height: registering ? 15 : 10),
        FilledButton(
          key: const Key('auth-submit'),
          onPressed: isLoading ? null : onSubmit,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            backgroundColor: const Color(0xFF0B3565),
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                const Color(0xFF0B3565).withValues(alpha: .42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          child: isLoading
              ? const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(registering ? 'Create Account' : 'Sign In'),
                    const SizedBox(width: 7),
                    const Icon(Icons.arrow_forward_rounded, size: 19),
                  ],
                ),
        ),
      ],
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
          color: const Color(0xFFFFF1CB),
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
    final theme = Theme.of(context);
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFDCD6CC))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFF7A8088),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFDCD6CC))),
      ],
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD8DEE7)),
      ),
      child: Text(
        'G',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF4285F4),
              fontWeight: FontWeight.w900,
            ),
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
