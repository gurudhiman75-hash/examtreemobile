import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import 'profile_screen_v4.dart' as v4;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const Expanded(child: v4.ProfileScreen()),
        Material(
          color: theme.colorScheme.surface,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: OutlinedButton.icon(
                key: const Key('profile-privacy-account'),
                onPressed: () => context.push('/account'),
                icon: const Icon(Icons.privacy_tip_outlined),
                label: const Text('Privacy & account'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
