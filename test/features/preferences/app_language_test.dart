import 'package:examtree/features/preferences/data/local_app_language_store.dart';
import 'package:examtree/features/preferences/domain/question_language.dart';
import 'package:examtree/features/preferences/presentation/providers/app_language_providers.dart';
import 'package:examtree/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryStore implements AppLanguageStore {
  _MemoryStore(this.value);
  QuestionLanguage? value;
  @override
  Future<QuestionLanguage?> load() async => value;
  @override
  Future<void> save(QuestionLanguage language) async => value = language;
}

void main() {
  test('every app language has every string', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final strings = lookupAppLocalizations(locale);
      expect(strings.navResults, isNotEmpty, reason: locale.toString());
      expect(strings.bookmarksCount(2), contains('2'));
    }
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
      {'en', 'hi', 'pa'},
    );
  });

  test('defaults to English and follows the saved choice', () async {
    final store = _MemoryStore(null);
    final container = ProviderContainer(
      overrides: [appLanguageStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    await container.read(appLanguageProvider.future);
    expect(container.read(appLocaleProvider), const Locale('en'));

    store.value = QuestionLanguage.punjabi;
    container.invalidate(appLanguageProvider);
    await container.read(appLanguageProvider.future);
    expect(container.read(appLocaleProvider), const Locale('pa'));
  });

  testWidgets('screens show Punjabi strings when the locale is pa',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pa'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(builder: (context) => Text(context.l10n.navResults)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('ਨਤੀਜੇ'), findsOneWidget);
  });

  testWidgets('falls back to English without delegates', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(builder: (context) => Text(context.l10n.navResults)),
      ),
    );
    expect(find.text('Results'), findsOneWidget);
  });
}
