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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 520,
                    minHeight: constraints.maxHeight - AppSpacing.xl,
                  ),
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _ModernBrandHeader(),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          registering ? 'Join ExamTree' : 'Sign in to ExamTree',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.55,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          registering
                              ? 'Build one preparation profile for tests, revision and progress.'
                              : 'Pick up your preparation exactly where you left it.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        if (isLoading && loadingMessage != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _LoadingStage(message: loadingMessage!),
                        ],
                        if (promotionalContent != null) ...[
                          const SizedBox(height: AppSpacing.lg),
                          promotionalContent!,
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        _AuthPanel(
                          registering: registering,
                          isLoading: isLoading,
                          obscurePassword: obscurePassword,
                          nameController: nameController,
                          emailController: emailController,
                          passwordController: passwordController,
                          confirmPasswordController: confirmPasswordController,
                          onGoogle: onGoogle,
                          onSubmit: onSubmit,
                          onTogglePassword: onTogglePassword,
                          onForgotPassword: onForgotPassword,
                        ),
                        const SizedBox(height: AppSpacing.sm),
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
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Flexible(
                              child: Text(
                                'Your attempts and progress stay synced across ExamTree.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.35,
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

class _ModernBrandHeader extends StatelessWidget {
  const _ModernBrandHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.account_tree_rounded,
            color: scheme.onPrimary,
            size: 22,
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
                  letterSpacing: -0.35,
                ),
              ),
              Text(
                'Practice smarter · revise what matters',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'PREP',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSecondaryContainer,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
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
  final VoidCallback onGoogle;
  final VoidCallback onSubmit;
  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
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
            OutlinedButton.icon(
              key: const Key('auth-google'),
              onPressed: isLoading ? null : onGoogle,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: scheme.surface,
              ),
              icon: const _GoogleMark(),
              label: const Text('Continue with Google'),
            ),
            const SizedBox(height: AppSpacing.md),
            const _DividerLabel(label: 'or use email'),
            const SizedBox(height: AppSpacing.md),
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
              const SizedBox(height: AppSpacing.sm),
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
            const SizedBox(height: AppSpacing.sm),
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
              decoration: InputDecoration(
                labelText: 'Password',
                helperText: registering ? 'Use at least 6 characters.' : null,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
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
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: confirmPasswordController,
                enabled: !isLoading,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onSubmitted: (_) {
                  if (!isLoading) onSubmit();
                },
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                  prefixIcon: Icon(Icons.lock_reset_outlined),
                ),
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.xxs),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLoading ? null : onForgotPassword,
                  child: const Text('Forgot password?'),
                ),
              ),
            ],
            SizedBox(height: registering ? AppSpacing.lg : AppSpacing.xs),
            FilledButton(
              key: const Key('auth-submit'),
              onPressed: isLoading ? null : onSubmit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: isLoading
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(registering ? 'Create Account' : 'Sign In'),
            ),
          ],
        ),
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
