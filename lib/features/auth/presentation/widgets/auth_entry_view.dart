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
    required this.onGoogle,
    required this.onSubmit,
    required this.onTogglePassword,
    required this.onForgotPassword,
    required this.onToggleMode,
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
  final VoidCallback onGoogle;
  final VoidCallback onSubmit;
  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
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
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _BrandHeader(registering: registering),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          registering ? 'Join ExamTree' : 'Sign in to ExamTree',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.45,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          registering
                              ? 'Create one account for your tests, results and progress across mobile and web.'
                              : 'Continue your tests, review results and keep progress synced across devices.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                        if (isLoading && loadingMessage != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          _LoadingStage(message: loadingMessage!),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        OutlinedButton.icon(
                          key: const Key('auth-google'),
                          onPressed: isLoading ? null : onGoogle,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                          ),
                          icon: const _GoogleMark(),
                          label: const Text('Continue with Google'),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _DividerLabel(label: 'or use email'),
                        const SizedBox(height: AppSpacing.lg),
                        Material(
                          color: scheme.surfaceContainerLowest,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusXl),
                            side: BorderSide(color: scheme.outlineVariant),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (registering) ...[
                                  TextField(
                                    controller: nameController,
                                    enabled: !isLoading,
                                    textCapitalization: TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.name],
                                    decoration: const InputDecoration(
                                      labelText: 'Name',
                                      prefixIcon: Icon(Icons.person_outline),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                ],
                                TextField(
                                  controller: emailController,
                                  enabled: !isLoading,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  autocorrect: false,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                TextField(
                                  controller: passwordController,
                                  enabled: !isLoading,
                                  obscureText: obscurePassword,
                                  textInputAction: registering
                                      ? TextInputAction.next
                                      : TextInputAction.done,
                                  autofillHints: [
                                    registering
                                        ? AutofillHints.newPassword
                                        : AutofillHints.password,
                                  ],
                                  onSubmitted: (_) {
                                    if (!isLoading && !registering) onSubmit();
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    helperText: registering
                                        ? 'Use at least 6 characters.'
                                        : null,
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      tooltip: obscurePassword
                                          ? 'Show password'
                                          : 'Hide password',
                                      onPressed:
                                          isLoading ? null : onTogglePassword,
                                      icon: Icon(
                                        obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                  ),
                                ),
                                if (registering) ...[
                                  const SizedBox(height: AppSpacing.md),
                                  TextField(
                                    controller: confirmPasswordController,
                                    enabled: !isLoading,
                                    obscureText: obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [
                                      AutofillHints.newPassword,
                                    ],
                                    onSubmitted: (_) {
                                      if (!isLoading) onSubmit();
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Confirm password',
                                      prefixIcon:
                                          Icon(Icons.lock_reset_outlined),
                                    ),
                                  ),
                                ] else ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: isLoading
                                          ? null
                                          : onForgotPassword,
                                      child: const Text('Forgot password?'),
                                    ),
                                  ),
                                ],
                                SizedBox(
                                  height: registering
                                      ? AppSpacing.xl
                                      : AppSpacing.sm,
                                ),
                                FilledButton(
                                  key: const Key('auth-submit'),
                                  onPressed: isLoading ? null : onSubmit,
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                  ),
                                  child: isLoading
                                      ? const SizedBox.square(
                                          dimension: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          registering
                                              ? 'Create Account'
                                              : 'Sign In',
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextButton(
                          key: const Key('auth-toggle-mode'),
                          onPressed: isLoading ? null : onToggleMode,
                          child: Text(
                            registering
                                ? 'Already have an account? Sign in'
                                : 'New to ExamTree? Create account',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'One ExamTree account keeps your attempts and results together across mobile and web.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.35,
                          ),
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
  const _BrandHeader({required this.registering});

  final bool registering;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Icon(
            registering ? Icons.school_rounded : Icons.park_rounded,
            color: scheme.onPrimary,
            size: 23,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ExamTree',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Practice · Review · Improve',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
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
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
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
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider()),
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
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(
        'G',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
