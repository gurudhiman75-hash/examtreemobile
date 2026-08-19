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
    final email = _emailController.text.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 520,
                    minHeight: constraints.maxHeight -
                        AppSpacing.md -
                        AppSpacing.xl,
                  ),
                  child: _sent
                      ? _SuccessState(
                          email: email,
                          isSending: _isSending,
                          onResend: _sendReset,
                          onEditEmail: _editEmail,
                          onBackToLogin: () => context.go('/login'),
                        )
                      : _RecoveryForm(
                          emailController: _emailController,
                          errorMessage: _errorMessage,
                          isSending: _isSending,
                          onSend: _sendReset,
                          onEmailChanged: () {
                            if (_errorMessage != null) {
                              setState(() => _errorMessage = null);
                            }
                          },
                          onBackToLogin: () => context.go('/login'),
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

class _RecoveryForm extends StatelessWidget {
  const _RecoveryForm({
    required this.emailController,
    required this.errorMessage,
    required this.isSending,
    required this.onSend,
    required this.onEmailChanged,
    required this.onBackToLogin,
  });

  final TextEditingController emailController;
  final String? errorMessage;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onEmailChanged;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RecoveryHeader(
            icon: Icons.lock_reset_rounded,
            title: 'Recover your account',
            message:
                'Enter the email you use for ExamTree and we will send password-reset instructions.',
          ),
          const SizedBox(height: AppSpacing.xl),
          Material(
            color: scheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              side: BorderSide(color: scheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const Key('password-recovery-email'),
                    controller: emailController,
                    enabled: !isSending,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.email],
                    autocorrect: false,
                    onChanged: (_) => onEmailChanged(),
                    onSubmitted: (_) {
                      if (!isSending) onSend();
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      errorText: errorMessage,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    key: const Key('password-recovery-send'),
                    onPressed: isSending ? null : onSend,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    icon: isSending
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.mark_email_read_outlined),
                    label: Text(isSending ? 'Sending…' : 'Send reset email'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.privacy_tip_outlined,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'For privacy, the confirmation screen does not reveal whether an email is registered.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: isSending ? null : onBackToLogin,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back to sign in'),
          ),
        ],
      ),
    );
  }
}

class _RecoveryHeader extends StatelessWidget {
  const _RecoveryHeader({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Icon(icon, color: scheme.onPrimaryContainer),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
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

    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RecoveryHeader(
            icon: Icons.mark_email_read_rounded,
            title: 'Check your email',
            message:
                'If an ExamTree account exists for $email, password-reset instructions will arrive there shortly.',
          ),
          const SizedBox(height: AppSpacing.xl),
          Material(
            color: scheme.secondaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: scheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Check your spam folder too. For privacy, we do not confirm whether an email is registered.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSecondaryContainer,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isSending) ...[
            const SizedBox(height: AppSpacing.md),
            Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(child: Text('Sending another reset email…')),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            key: const Key('password-recovery-back'),
            onPressed: isSending ? null : onBackToLogin,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            icon: const Icon(Icons.login_rounded),
            label: const Text('Back to sign in'),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              TextButton(
                key: const Key('password-recovery-edit'),
                onPressed: isSending ? null : onEditEmail,
                child: const Text('Use another email'),
              ),
              TextButton(
                key: const Key('password-recovery-resend'),
                onPressed: isSending ? null : onResend,
                child: Text(isSending ? 'Sending…' : 'Resend email'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
