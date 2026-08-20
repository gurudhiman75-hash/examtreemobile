import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../preferences/domain/question_language.dart';
import '../../preferences/presentation/providers/question_language_providers.dart';
import 'profile_screen_v4.dart' as v4;

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final language = ref.watch(questionLanguageProvider).value ??
        QuestionLanguage.english;

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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stack = constraints.maxWidth < 340 ||
                      MediaQuery.textScalerOf(context).scale(1) > 1.5;
                  final languageButton = OutlinedButton.icon(
                    key: const Key('profile-question-language'),
                    onPressed: () => _chooseQuestionLanguage(
                      context,
                      ref,
                      language,
                    ),
                    icon: const Icon(Icons.translate_rounded),
                    label: Text('Questions · ${language.shortLabel}'),
                  );
                  final privacyButton = OutlinedButton.icon(
                    key: const Key('profile-privacy-account'),
                    onPressed: () => context.push('/account'),
                    icon: const Icon(Icons.privacy_tip_outlined),
                    label: const Text('Privacy & account'),
                  );

                  if (stack) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        languageButton,
                        const SizedBox(height: AppSpacing.xs),
                        privacyButton,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: languageButton),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: privacyButton),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _chooseQuestionLanguage(
    BuildContext context,
    WidgetRef ref,
    QuestionLanguage current,
  ) async {
    final selected = await showModalBottomSheet<QuestionLanguage>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question language',
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Used in tests, answer review and saved revision questions. English is used when a translation is unavailable.',
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final language in QuestionLanguage.values)
                RadioListTile<QuestionLanguage>(
                  value: language,
                  groupValue: current,
                  title: Text(language.label),
                  subtitle: Text(language.shortLabel),
                  onChanged: (value) => Navigator.of(sheetContext).pop(value),
                ),
            ],
          ),
        ),
      ),
    );

    if (selected == null || selected == current || !context.mounted) return;
    try {
      await setQuestionLanguage(ref, selected);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save the question language on this device.'),
        ),
      );
    }
  }
}
