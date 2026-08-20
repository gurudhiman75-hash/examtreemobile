import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_question_language_store.dart';
import '../../domain/question_language.dart';

final questionLanguageStoreProvider = Provider<QuestionLanguageStore>((ref) {
  return SqfliteQuestionLanguageStore();
});

final questionLanguageProvider = FutureProvider<QuestionLanguage>((ref) async {
  return ref.watch(questionLanguageStoreProvider).load();
});

Future<void> setQuestionLanguage(
  WidgetRef ref,
  QuestionLanguage language,
) async {
  await ref.read(questionLanguageStoreProvider).save(language);
  ref.invalidate(questionLanguageProvider);
}
