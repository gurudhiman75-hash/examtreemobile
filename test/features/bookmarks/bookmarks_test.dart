import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/features/bookmarks/data/local_question_bookmark_store.dart';
import 'package:examtree/features/bookmarks/domain/question_bookmark.dart';
import 'package:examtree/features/bookmarks/presentation/bookmarks_screen.dart';
import 'package:examtree/features/bookmarks/presentation/providers/bookmark_providers.dart';
import 'package:examtree/features/preferences/domain/question_language.dart';
import 'package:examtree/features/preferences/presentation/providers/question_language_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ResultQuestionReview question({
  String version = 'v1',
  String section = 'Quant',
}) {
  return ResultQuestionReview.fromJson({
    'questionId': 7,
    'questionVersionId': version,
    'section': section,
    'text': 'What is 20% of 150?',
    'options': ['20', '25', '30', '35'],
    'correct': 2,
    'selected': 1,
    'explanation': '150 × 0.2 = 30',
    'textHi': '150 का 20% क्या है?',
    'optionsHi': ['20', '25', '30', '35'],
  });
}

void main() {
  test('round-trips every language through JSON', () {
    final bookmark = QuestionBookmark.fromReview(
      question: question(),
      testName: 'Full Mock 1',
      attemptId: 'a1',
      savedAt: DateTime.utc(2026, 11, 27),
    );
    final copy = QuestionBookmark.tryFromJson(bookmark.toJson())!;
    expect(copy.id, 'qv:v1');
    expect(copy.question.textHi, '150 का 20% क्या है?');
    expect(copy.question.correct, 2);
    expect(copy.testName, 'Full Mock 1');
    expect(QuestionBookmark.tryFromJson({'question': 'bad'}), isNull);
  });

  test('toggle saves then removes', () async {
    final container = ProviderContainer(
      overrides: [
        questionBookmarkStoreProvider.overrideWithValue(
          InMemoryQuestionBookmarkStore(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(questionBookmarksProvider.future);
    final notifier = container.read(questionBookmarksProvider.notifier);

    expect(
      await notifier.toggle(
        question: question(),
        testName: 'T',
        attemptId: 'a',
      ),
      isTrue,
    );
    expect(container.read(isQuestionBookmarkedProvider('qv:v1')), isTrue);
    expect(
      await notifier.toggle(
        question: question(),
        testName: 'T',
        attemptId: 'a',
      ),
      isFalse,
    );
    expect(container.read(questionBookmarksProvider).value, isEmpty);
  });

  testWidgets('lists saved questions, filters by section and opens one', (
    tester,
  ) async {
    final store = InMemoryQuestionBookmarkStore();
    await store.save(
      QuestionBookmark.fromReview(
        question: question(),
        testName: 'Full Mock 1',
        attemptId: 'a1',
      ),
    );
    await store.save(
      QuestionBookmark.fromReview(
        question: question(version: 'v2', section: 'Reasoning'),
        testName: 'Full Mock 2',
        attemptId: 'a2',
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          questionBookmarkStoreProvider.overrideWithValue(store),
          questionLanguageProvider.overrideWith(
            (ref) async => QuestionLanguage.english,
          ),
        ],
        child: const MaterialApp(home: BookmarksScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 saved questions · on this device'), findsOneWidget);
    await tester.tap(find.text('Reasoning').first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bookmark-qv:v1')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('bookmark-qv:v2')));
    await tester.pumpAndSettle();
    expect(find.text('Correct answer'), findsOneWidget);
    expect(find.text('Your answer'), findsOneWidget);
    expect(find.text('150 × 0.2 = 30'), findsOneWidget);
  });

  testWidgets('shows an empty state with guidance', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          questionBookmarkStoreProvider.overrideWithValue(
            InMemoryQuestionBookmarkStore(),
          ),
        ],
        child: const MaterialApp(home: BookmarksScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No saved questions yet'), findsOneWidget);
  });
}
