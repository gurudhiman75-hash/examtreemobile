import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('question language preference is wired through preparation surfaces', () {
    final exams = File(
      'lib/features/exams/presentation/providers/exam_providers.dart',
    ).readAsStringSync();
    final results = File(
      'lib/features/results/presentation/providers/result_providers.dart',
    ).readAsStringSync();
    final profile = File(
      'lib/features/profile/presentation/profile_screen.dart',
    ).readAsStringSync();
    final preference = File(
      'lib/features/preferences/presentation/providers/question_language_providers.dart',
    ).readAsStringSync();

    expect(exams, contains('questionLanguageProvider.future'));
    expect(exams, contains('localizeQuestion(question, language)'));
    expect(results, contains('questionLanguageProvider.future'));
    expect(results, contains('localizeResult(result, language)'));
    expect(profile, contains("Key('profile-question-language')"));
    expect(profile, contains('Questions · \${language.shortLabel}'));
    expect(profile, contains('English is used when a translation is unavailable.'));
    expect(preference, contains('return QuestionLanguage.english;'));
  });

  test('question language stays a device preference rather than learner data', () {
    final store = File(
      'lib/features/preferences/data/local_question_language_store.dart',
    ).readAsStringSync();

    expect(store, contains("'examtree_preferences.db'"));
    expect(store, contains("'question_language'"));
    expect(store, isNot(contains('user_id')));
  });
}
