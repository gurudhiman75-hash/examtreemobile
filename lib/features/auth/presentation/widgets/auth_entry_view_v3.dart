import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class AuthEntryView extends StatefulWidget {
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
  State<AuthEntryView> createState() => _AuthEntryViewState();
}

class _AuthEntryViewState extends State<AuthEntryView> {
  final PageController _pageController = PageController();
  int _featureIndex = 0;

  static const _features = <_LoginFeature>[
    _LoginFeature(
      eyebrow: 'EXAM PREPARATION',
      title: 'Prepare for the exams that matter',
      body:
          'Punjab Govt., SSC, Banking, Railway and more — organised in one focused app.',
      icon: Icons.workspace_premium_rounded,
    ),
    _LoginFeature(
      eyebrow: 'LEARN + PRACTICE',
      title: 'Study. Practice. Improve.',
      body:
          'Learn concepts, take mock tests and review detailed solutions without breaking your flow.',
      icon: Icons.auto_stories_rounded,
    ),
    _LoginFeature(
      eyebrow: 'SMART PROGRESS',
      title: 'Stay on track every day',
      body:
          'Continue where you left off and use your progress to focus revision where it matters.',
      icon: Icons.insights_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final featureHeight = textScale > 1.45 ? 250.0 : 194.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
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
                        const _BrandHeader(),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: featureHeight,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _features.length,
                            onPageChanged: (index) {
                              if (!mounted) return;
                              setState(() => _featureIndex = index);
                            },
                            itemBuilder: (context, index) =>
                                _FeatureSlide(feature: _features[index]),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _PageDots(
                          count: _features.length,
                          selected: _featureIndex,
                          onTap: (index) {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOutCubic,
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        Text(
                          widget.registering
                              ? 'Join ExamTree'
                              : 'Sign in to ExamTree',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: const Color(0xFF0B2343),
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.65,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.registering
                              ? 'Create your preparation profile and keep your progress in one place.'
                              : 'Welcome back. Continue your preparation from where you left off.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF65748B),
                            height: 1.35,
                          ),
                        ),
                        if (widget.isLoading &&
                            widget.loadingMessage != null) ...[
                          const SizedBox(height: 10),
                          _LoadingStage(message: widget.loadingMessage!),
                        ],
                        const SizedBox(height: 16),
                        _AuthPanel(
                          registering: widget.registering,
                          isLoading: widget.isLoading,
                          obscurePassword: widget.obscurePassword,
                          nameController: widget.nameController,
                          emailController: widget.emailController,
                          passwordController: widget.passwordController,
                          confirmPasswordController:
                              widget.confirmPasswordController,
                          showApple: widget.showApple,
                          onApple: widget.onApple,
                          onGoogle: widget.onGoogle,
                          onSubmit: widget.onSubmit,
                          onTogglePassword: widget.onTogglePassword,
                          onForgotPassword: widget.onForgotPassword,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          key: const Key('auth-toggle-mode'),
                          onPressed:
                              widget.isLoading ? null : widget.onToggleMode,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF0756A5),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: Text(
                            widget.registering
                                ? 'Already have an account? Sign in'
                                : 'New to ExamTree? Create account',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                        if (widget.promotionalContent != null) ...[
                          const SizedBox(height: 18),
                          widget.promotionalContent!,
                        ],
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

class _LoginFeature {
  const _LoginFeature({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
  });

  final String eyebrow;
  final String title;
  final String body;
  final IconData icon;
}

class _FeatureSlide extends StatelessWidget {
  const _FeatureSlide({required this.feature});

  final _LoginFeature feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF061B38),
            Color(0xFF0B3769),
            Color(0xFF0756A5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFE4B649).withValues(alpha: .38),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B2343).withValues(alpha: .18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -24,
            child: Container(
              width: 122,
              height: 122,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .055),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 10,
            child: Icon(
              feature.icon,
              size: 76,
              color: Colors.white.withValues(alpha: .13),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD36B).withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFFFD36B).withValues(alpha: .7),
                  ),
                ),
                child: Text(
                  feature.eyebrow,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFFFDB7C),
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  feature.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.04,
                    letterSpacing: -.45,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  feature.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: .88),
                    height: 1.38,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final int count;
  final int selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => GestureDetector(
          onTap: () => onTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: index == selected ? 20 : 7,
            height: 7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: index == selected
                  ? const Color(0xFF0B3B70)
                  : const Color(0xFFD7DEE9),
            ),
          ),
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
          width: 38,
          height: 38,
          child: CustomPaint(painter: _ExamtreeMarkPainter()),
        ),
        const SizedBox(width: 9),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5D9),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'PREP SMARTER',
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFF8D6410),
              fontWeight: FontWeight.w900,
              letterSpacing: .45,
            ),
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
    final theme = Theme.of(context);

    InputDecoration fieldDecoration({
      required String label,
      required IconData icon,
      Widget? suffix,
      String? helper,
    }) {
      return InputDecoration(
        labelText: label,
        helperText: helper,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDDE4EE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDDE4EE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: Color(0xFF0756A5), width: 1.5),
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
                borderRadius: BorderRadius.circular(17),
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
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10264A).withValues(alpha: .07),
                blurRadius: 14,
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
              side: const BorderSide(color: Color(0xFFDDE4EE)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
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
        const SizedBox(height: 16),
        const _DividerLabel(label: 'or continue with email'),
        const SizedBox(height: 14),
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
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: isLoading ? null : onForgotPassword,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0756A5),
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('Forgot password?'),
            ),
          ),
        ],
        SizedBox(height: registering ? 16 : 5),
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
              borderRadius: BorderRadius.circular(17),
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
          color: const Color(0xFFEAF3FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF0756A5),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF234568),
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
        const Expanded(child: Divider(color: Color(0xFFDDE4EE))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFF7A8799),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFDDE4EE))),
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
        border: Border.all(color: const Color(0xFFD9E0EA)),
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
