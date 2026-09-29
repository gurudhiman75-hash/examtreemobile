import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../preferences/domain/question_language.dart';
import '../../preferences/presentation/providers/question_language_providers.dart';

class LearnLanguageSelector extends ConsumerWidget {
  const LearnLanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(questionLanguageProvider).value ?? QuestionLanguage.english;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final language in QuestionLanguage.values)
          ChoiceChip(
            label: Text(language.label),
            selected: language == selected,
            onSelected: language == selected
                ? null
                : (_) async {
                    await setQuestionLanguage(ref, language);
                  },
          ),
      ],
    );
  }
}
