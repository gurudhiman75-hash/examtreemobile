import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../domain/auth_error_messages.dart';
import 'providers/auth_providers.dart';

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
    final theme = Theme.of(context);
    final email = _emailController.text.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
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
                          const SizedBox(height: AppSpacing.xl),
                          Icon(
                            Icons.lock_reset_outlined,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Recover your account',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Enter the email you use for ExamTree. We will ask Firebase to send password-reset instructions.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
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
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: const OutlineInputBorder(),
                              errorText: _errorMessage,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          SizedBox(
                            height: 48,
                            child: FilledButton.icon(
                              onPressed: _isSending ? null : _sendReset,
                              icon: _isSending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
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
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xl),
        Icon(
          Icons.mark_email_read_outlined,
          size: 72,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Check your email',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'If an ExamTree account exists for $email, password-reset instructions will arrive there shortly.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Check your spam folder too. For privacy, we do not confirm whether an email is registered.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: isSending ? null : onBackToLogin,
            child: const Text('Back to sign in'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
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
