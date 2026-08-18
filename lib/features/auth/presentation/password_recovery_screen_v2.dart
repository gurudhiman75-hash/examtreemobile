import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../domain/auth_error_messages.dart';
import 'providers/auth_providers.dart';
import 'widgets/auth_visual_components.dart';

class PasswordRecoveryScreen extends ConsumerStatefulWidget {
  const PasswordRecoveryScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  ConsumerState<PasswordRecoveryScreen> createState() =>
      _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState
    extends ConsumerState<PasswordRecoveryScreen> {
  late final TextEditingController _emailController;
  bool _isSending = false;
  bool _sent = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail.trim());
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    final email = _emailController.text.trim();
    if (!AuthErrorMessages.isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Enter a valid email address.';
        _sent = false;
      });
      return;
    }

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider).sendPasswordResetEmail(email);
      if (!mounted) return;
      setState(() => _sent = true);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final failure = AuthErrorMessages.passwordReset(error);
      if (failure.shouldShowSuccess) {
        setState(() => _sent = true);
      } else {
        setState(() {
          _sent = false;
          _errorMessage = failure.message;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sent = false;
        _errorMessage = 'We could not send the reset email. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _editEmail() {
    setState(() {
      _sent = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final email = _emailController.text.trim();

    return AuthPageFrame(
      topAction: IconButton.filledTonal(
        tooltip: 'Back to sign in',
        onPressed: _isSending ? null : () => context.go('/login'),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      child: AuthSurfaceCard(
        child: _sent
            ? _SuccessState(
                email: email,
                isSending: _isSending,
                onResend: _sendReset,
                onEditEmail: _editEmail,
                onBackToLogin: () => context.go('/login'),
              )
            : AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthCardHeading(
                      title: 'Recover your account',
                      subtitle:
                          'Enter the email you use for ExamTree and we will request password-reset instructions from Firebase.',
                      icon: Icons.lock_reset_outlined,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextField(
                      controller: _emailController,
                      enabled: !_isSending,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.email],
                      autocorrect: false,
                      onChanged: (_) {
                        if (_errorMessage != null) {
                          setState(() => _errorMessage = null);
                        }
                      },
                      onSubmitted: (_) {
                        if (!_isSending) _sendReset();
                      },
                      decoration: authInputDecoration(
                        context,
                        label: 'Email',
                        icon: Icons.mail_outline_rounded,
                        errorText: _errorMessage,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const AuthPrivacyNote(
                      text:
                          'For privacy, the confirmation screen does not reveal whether an email is registered.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _isSending ? null : _sendReset,
                        icon: _isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.mark_email_read_outlined),
                        label: Text(
                          _isSending ? 'Sending…' : 'Send reset email',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: _isSending
                          ? null
                          : () => context.go('/login'),
                      child: const Text('Back to sign in'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState({
    required this.email,
    required this.isSending,
    required this.onResend,
    required this.onEditEmail,
    required this.onBackToLogin,
  });

  final String email;
  final bool isSending;
  final VoidCallback onResend;
  final VoidCallback onEditEmail;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read_outlined,
            size: 28,
            color: scheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Check your email',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'If an ExamTree account exists for $email, password-reset instructions will arrive there shortly.',
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
        ),
        const SizedBox(height: AppSpacing.md),
        const AuthPrivacyNote(
          icon: Icons.privacy_tip_outlined,
          text:
              'Check your spam folder too. For privacy, we do not confirm whether an email is registered.',
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: isSending ? null : onBackToLogin,
            child: const Text('Back to sign in'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            TextButton(
              onPressed: isSending ? null : onEditEmail,
              child: const Text('Use another email'),
            ),
            TextButton(
              onPressed: isSending ? null : onResend,
              child: Text(isSending ? 'Sending…' : 'Resend email'),
            ),
          ],
        ),
      ],
    );
  }
}
