import 'package:examtree/features/preferences/data/local_app_language_store.dart';
import 'package:examtree/features/preferences/data/local_question_language_store.dart';
import 'package:examtree/features/preferences/domain/question_language.dart';
import 'package:examtree/features/preferences/presentation/app_language_picker.dart';
import 'package:examtree/features/preferences/presentation/providers/app_language_providers.dart';
import 'package:examtree/features/preferences/presentation/providers/question_language_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _AppStore implements AppLanguageStore {
  QuestionLanguage? value;
  @override
  Future<QuestionLanguage?> load() async => value;
  @override
  Future<void> save(QuestionLanguage language) async => value = language;
}

class _QuestionStore implements QuestionLanguageStore {
  QuestionLanguage value = QuestionLanguage.english;
  @override
  Future<QuestionLanguage> load() async => value;
  @override
  Future<void> save(QuestionLanguage language) async => value = language;
}

void main() {
  testWidgets('top-bar button switches the app and question language', (
    tester,
  ) async {
    final appStore = _AppStore();
    final questionStore = _QuestionStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageStoreProvider.overrideWithValue(appStore),
          questionLanguageStoreProvider.overrideWithValue(questionStore),
        ],
        child: const MaterialApp(
          home: Scaffold(body: Center(child: AppLanguageButton())),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('EN'), findsOneWidget);

    await tester.tap(find.byKey(const Key('app-language-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('app-language-punjabi')));
    await tester.tap(find.byKey(const Key('app-language-save')));
    await tester.pumpAndSettle();

    expect(appStore.value, QuestionLanguage.punjabi);
    expect(questionStore.value, QuestionLanguage.punjabi);
    expect(find.text('ਪੰ'), findsOneWidget);
  });
}
