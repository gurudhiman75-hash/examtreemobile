import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_app_language_store.dart';
import '../../domain/question_language.dart';
import 'question_language_providers.dart';

final appLanguageStoreProvider = Provider<AppLanguageStore>((ref) {
  return SqfliteAppLanguageStore();
});

/// The app's display language. Until the learner picks one, it is English.
final appLanguageProvider = FutureProvider<QuestionLanguage>((ref) async {
  try {
    return await ref.watch(appLanguageStoreProvider).load() ??
        QuestionLanguage.english;
  } catch (_) {
    return QuestionLanguage.english;
  }
});

Locale localeFor(QuestionLanguage language) => switch (language) {
  QuestionLanguage.english => const Locale('en'),
  QuestionLanguage.hindi => const Locale('hi'),
  QuestionLanguage.punjabi => const Locale('pa'),
};

/// The locale for MaterialApp. English while the saved choice is loading, so
/// the first frame never waits on the device database.
final appLocaleProvider = Provider<Locale>((ref) {
  final language =
      ref.watch(appLanguageProvider).value ?? QuestionLanguage.english;
  return localeFor(language);
});

Future<void> setAppLanguage(
  WidgetRef ref,
  QuestionLanguage language, {
  bool alsoForQuestions = false,
}) async {
  await ref.read(appLanguageStoreProvider).save(language);
  ref.invalidate(appLanguageProvider);
  if (alsoForQuestions) await setQuestionLanguage(ref, language);
}
