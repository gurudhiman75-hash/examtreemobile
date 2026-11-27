import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/features/bookmarks/data/local_question_bookmark_store.dart';
import 'package:examtree/features/bookmarks/domain/question_bookmark.dart';
import 'package:examtree/features/bookmarks/presentation/providers/bookmark_providers.dart';
import 'package:examtree/features/companion/presentation/providers/daily_companion_providers.dart';
import 'package:examtree/features/offline/presentation/offline_library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows saved questions and says tests are not downloadable', (
    tester,
  ) async {
    final store = InMemoryQuestionBookmarkStore();
    await store.save(
      QuestionBookmark.fromReview(
        question: ResultQuestionReview.fromJson({
          'questionVersionId': 'v1',
          'text': 'Q',
          'options': ['a', 'b'],
          'correct': 0,
        }),
        testName: 'Mock',
        attemptId: 'a',
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          questionBookmarkStoreProvider.overrideWithValue(store),
          dailyCompanionSnapshotProvider.overrideWith(
            (ref) async => throw StateError('signed out'),
          ),
        ],
        child: const MaterialApp(home: OfflineLibraryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 question with solutions'), findsOneWidget);
    expect(
      find.text('Tests need a connection to start and submit'),
      findsOneWidget,
    );
  });
}
