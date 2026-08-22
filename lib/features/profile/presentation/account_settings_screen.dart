import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/repositories/account_repository.dart';
import '../../../core/repositories/api_account_repository.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../companion/presentation/providers/daily_companion_providers.dart';
import '../../exam_day/presentation/providers/exam_day_providers.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  bool _deleting = false;

  Future<void> _requestDeletion() async {
    if (_deleting) return;
    final confirmed = await _showDeletionConfirmation();
    if (confirmed != true || !mounted) return;

    final userId = ref.read(firebaseAuthProvider).currentUser?.uid.trim() ?? '';
    setState(() => _deleting = true);
    try {
      final result = await ref.read(accountRepositoryProvider).deleteAccount();
      await _clearDeletedUserDeviceData(userId);
      try {
        await ref.read(authControllerProvider).signOut();
      } catch (_) {
        // The backend may already have removed the Firebase user. The auth
        // stream will settle on the signed-out state after the next refresh.
      }
      if (!mounted) return;
      context.go(
        result.pending
            ? '/login?notice=deletion-pending'
            : '/login?notice=account-deleted',
      );
    } on AccountDeletionException catch (error) {
      if (!mounted) return;
      if (error.requiresReauthentication) {
        await _reauthenticateForDeletion();
        return;
      }
      _showMessage(
        error.code == 'ACCOUNT_DELETION_NOT_ALLOWED'
            ? 'This account cannot be deleted from the learner app. Contact ExamTree support.'
            : 'Account deletion could not be completed. Please try again.',
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('Account deletion could not be completed. Please try again.');
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _clearDeletedUserDeviceData(String userId) async {
    final normalized = userId.trim();
    if (normalized.isNotEmpty) {
      try {
        await ref.read(attemptDraftStoreProvider).deleteAllForUser(normalized);
      } catch (_) {
        // Server erasure is canonical. Continue with the remaining device data.
      }
      try {
        await ref.read(dailyCompanionStoreProvider).deleteAllForUser(normalized);
      } catch (_) {
        // Continue clearing independent caches/reminders even if one DB fails.
      }
      try {
        await ref.read(examDayControllerProvider).deleteTarget(normalized);
      } catch (_) {
        // Reminder cancellation is retried separately below.
      }
    }

    try {
      await ref.read(studyReminderServiceProvider).cancel();
    } catch (_) {
      // Local notification cleanup is best-effort after canonical deletion.
    }
    try {
      await ref.read(examDayControllerProvider).cancelReminders();
    } catch (_) {
      // Local notification cleanup is best-effort after canonical deletion.
    }
    try {
      await ref.read(companionWidgetServiceProvider).clear();
    } catch (_) {
      // Never keep a deleted learner's revision snapshot in the home widget.
    }
  }

  Future<void> _reauthenticateForDeletion() async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign in again to continue'),
        content: const Text(
          'For your security, account deletion requires a recent sign-in. '
          'You will return here after signing in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign in again'),
          ),
        ],
      ),
    );
    if (proceed != true || !mounted) return;

    try {
      await ref.read(authControllerProvider).signOut();
    } catch (_) {
      // Continue to Login even if provider cleanup is already complete.
    }
    if (!mounted) return;
    context.go('/login?continue=%2Faccount');
  }

  Future<bool?> _showDeletionConfirmation() {
    final controller = TextEditingController();
    var matches = false;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Delete your ExamTree account?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This permanently erases your learner profile, attempts, '
                  'results and active access entitlements. Financial and '
                  'security records may be retained in anonymized form where '
                  'required for legitimate record-keeping.',
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'This cannot be undone. Type DELETE MY ACCOUNT to continue.',
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  key: const Key('account-delete-confirmation-field'),
                  controller: controller,
                  autofocus: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (value) {
                    final next = value.trim() == ApiAccountRepository.confirmation;
                    if (next != matches) {
                      setDialogState(() => matches = next);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Confirmation',
                    hintText: 'DELETE MY ACCOUNT',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep my account'),
            ),
            FilledButton(
              key: const Key('account-delete-confirm-button'),
              onPressed: matches
                  ? () => Navigator.of(dialogContext).pop(true)
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Delete account'),
            ),
          ],
        ),
      ),
    ).whenComplete(controller.dispose);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & account')),
      body: SafeArea(
        top: false,
        child: ListView(
          key: const Key('account-settings-scroll'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          children: [
            const _PrivacyHero(),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Your learner data',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Clear information about what ExamTree uses and where to read the full policy.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const _InfoCard(
              icon: Icons.auto_graph_outlined,
              title: 'Learning activity',
              body:
                  'ExamTree uses your account information to authenticate you, save test attempts, show results and provide learning analytics. We do not need your question answers for advertising.',
            ),
            const SizedBox(height: AppSpacing.sm),
            const _InfoCard(
              icon: Icons.shield_outlined,
              title: 'Privacy policy',
              body:
                  'The production privacy policy is available at https://sarbedutech.web.app/privacy. It describes data use, retention, deletion and contact details.',
            ),
            const SizedBox(height: AppSpacing.sm),
            const _InfoCard(
              icon: Icons.language_outlined,
              title: 'Account deletion on the web',
              body:
                  'You can also start an account-deletion request at https://sarbedutech.web.app/account-deletion.',
            ),
            const SizedBox(height: AppSpacing.xl),
            _DangerZone(
              deleting: _deleting,
              onDelete: _deleting ? null : _requestDeletion,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyHero extends StatelessWidget {
  const _PrivacyHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final icon = Container(
      width: 58,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(19),
      ),
      child: const Icon(
        Icons.lock_person_outlined,
        color: Colors.white,
        size: 28,
      ),
    );
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRIVACY & ACCOUNT',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.76),
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'Your privacy, your account',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Review how learner data is used and manage permanent account deletion.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.84),
            height: 1.4,
          ),
        ),
      ],
    );

    return Container(
      key: const Key('account-privacy-hero'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: largeText
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon,
                const SizedBox(height: AppSpacing.md),
                copy,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon,
                const SizedBox(width: AppSpacing.md),
                Expanded(child: copy),
              ],
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone({required this.deleting, required this.onDelete});

  final bool deleting;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      key: const Key('account-danger-zone'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.delete_forever_outlined, color: scheme.error),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Delete account',
            style: theme.textTheme.titleLarge?.copyWith(
              color: scheme.error,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Deleting your account permanently removes learner-owned attempts, results, profile data and active entitlements. An anonymized account record may remain solely where financial or security records must be retained.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'You will be asked to type DELETE MY ACCOUNT before anything is removed.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            key: const Key('account-delete-start'),
            onPressed: onDelete,
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
              minimumSize: const Size.fromHeight(52),
            ),
            icon: deleting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.onError,
                    ),
                  )
                : const Icon(Icons.delete_forever_outlined),
            label: Text(deleting ? 'Deleting account…' : 'Delete account'),
          ),
        ],
      ),
    );
  }
}
