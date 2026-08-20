import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/repositories/account_repository.dart';
import '../../../core/repositories/api_account_repository.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/providers/auth_providers.dart';

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
      if (userId.isNotEmpty) {
        try {
          await ref.read(attemptDraftStoreProvider).deleteAllForUser(userId);
        } catch (_) {
          // Canonical deletion is already complete/pending. Local cleanup is
          // best-effort and must never keep a deleted account signed in.
        }
      }
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
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & account')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          children: [
            Text(
              'Privacy',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'ExamTree uses your account information to authenticate you, '
              'save test attempts, show results and provide learning analytics. '
              'We do not need your question answers for advertising.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoCard(
              icon: Icons.shield_outlined,
              title: 'Privacy policy',
              body:
                  'The production privacy policy is available at examtree.in/privacy. '
                  'It describes data use, retention, deletion and contact details.',
            ),
            const SizedBox(height: AppSpacing.sm),
            const _InfoCard(
              icon: Icons.delete_sweep_outlined,
              title: 'Account deletion on the web',
              body:
                  'You can also start an account-deletion request at '
                  'examtree.in/account-deletion.',
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Delete account',
              style: theme.textTheme.titleLarge?.copyWith(
                color: scheme.error,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Deleting your account permanently removes learner-owned '
              'attempts, results, profile data and active entitlements. '
              'An anonymized account record may remain solely where financial '
              'or security records must be retained.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              key: const Key('account-delete-start'),
              onPressed: _deleting ? null : _requestDeletion,
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
                minimumSize: const Size.fromHeight(52),
              ),
              icon: _deleting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onError,
                      ),
                    )
                  : const Icon(Icons.delete_forever_outlined),
              label: Text(_deleting ? 'Deleting account…' : 'Delete account'),
            ),
          ],
        ),
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
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
