import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../l10n/l10n.dart';
import '../domain/question_language.dart';
import 'providers/app_language_providers.dart';

/// Opens the app language sheet and saves the choice.
Future<void> showAppLanguagePicker(BuildContext context, WidgetRef ref) async {
  final current =
      ref.read(appLanguageProvider).value ?? QuestionLanguage.english;
  final result = await showModalBottomSheet<(QuestionLanguage, bool)>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => AppLanguageSheet(current: current),
  );
  if (result == null || !context.mounted) return;
  final (selected, alsoForQuestions) = result;
  if (selected == current && !alsoForQuestions) return;
  try {
    await setAppLanguage(ref, selected, alsoForQuestions: alsoForQuestions);
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.languageSaveFailed)));
  }
}

/// Top-bar language control: a translate icon with the current language
/// code (EN / हि / ਪੰ) as a small badge. Same footprint as the other header
/// icons. Tapping it opens the language sheet.
class AppLanguageButton extends ConsumerWidget {
  const AppLanguageButton({super.key, this.iconSize = 26});

  final double iconSize;

  static String shortLabel(QuestionLanguage language) => switch (language) {
    QuestionLanguage.english => 'EN',
    QuestionLanguage.hindi => 'हि',
    QuestionLanguage.punjabi => 'ਪੰ',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language =
        ref.watch(appLanguageProvider).value ?? QuestionLanguage.english;
    return Semantics(
      button: true,
      label: '${context.l10n.appLanguage}: ${language.label}',
      excludeSemantics: true,
      child: IconButton(
        key: const Key('app-language-button'),
        tooltip: context.l10n.appLanguage,
        onPressed: () => showAppLanguagePicker(context, ref),
        visualDensity: VisualDensity.compact,
        style: IconButton.styleFrom(
          foregroundColor: const Color(0xFF082A52),
          backgroundColor: Colors.transparent,
        ),
        icon: SizedBox(
          width: iconSize + 8,
          height: iconSize + 6,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.translate_rounded, size: iconSize),
              Positioned(
                right: -2,
                bottom: -1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B3A6F),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                  child: Text(
                    shortLabel(language),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppLanguageSheet extends StatefulWidget {
  const AppLanguageSheet({super.key, required this.current});

  final QuestionLanguage current;

  @override
  State<AppLanguageSheet> createState() => _AppLanguageSheetState();
}

class _AppLanguageSheetState extends State<AppLanguageSheet> {
  late QuestionLanguage _selected = widget.current;
  bool _alsoForQuestions = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SafeArea(
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
              l10n.appLanguage,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.appLanguageHelp,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            RadioGroup<QuestionLanguage>(
              groupValue: _selected,
              onChanged: (value) {
                if (value != null) setState(() => _selected = value);
              },
              child: Column(
                children: [
                  for (final language in QuestionLanguage.values)
                    RadioListTile<QuestionLanguage>(
                      key: Key('app-language-${language.name}'),
                      value: language,
                      title: Text(language.label),
                    ),
                ],
              ),
            ),
            SwitchListTile(
              key: const Key('app-language-also-questions'),
              value: _alsoForQuestions,
              onChanged: (value) => setState(() => _alsoForQuestions = value),
              title: Text(l10n.alsoUseForQuestions),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('app-language-save'),
                onPressed: () =>
                    Navigator.of(context).pop((_selected, _alsoForQuestions)),
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
