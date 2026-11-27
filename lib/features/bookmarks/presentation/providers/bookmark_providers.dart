import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/result_model.dart';
import '../../data/local_question_bookmark_store.dart';
import '../../domain/question_bookmark.dart';

final questionBookmarkStoreProvider = Provider<QuestionBookmarkStore>((ref) {
  return SqfliteQuestionBookmarkStore();
});

final questionBookmarksProvider =
    AsyncNotifierProvider<QuestionBookmarksNotifier, List<QuestionBookmark>>(
      QuestionBookmarksNotifier.new,
    );

class QuestionBookmarksNotifier extends AsyncNotifier<List<QuestionBookmark>> {
  QuestionBookmarkStore get _store => ref.read(questionBookmarkStoreProvider);

  @override
  Future<List<QuestionBookmark>> build() async {
    try {
      return await _store.loadAll();
    } catch (_) {
      // A broken device store must never block review or Profile.
      return const [];
    }
  }

  bool contains(String id) =>
      state.value?.any((bookmark) => bookmark.id == id) ?? false;

  /// Saves or removes the question. Returns true when it is now saved.
  Future<bool> toggle({
    required ResultQuestionReview question,
    required String testName,
    required String attemptId,
  }) async {
    final id = QuestionBookmark.idFor(question);
    if (contains(id)) {
      await remove(id);
      return false;
    }
    final bookmark = QuestionBookmark.fromReview(
      question: question,
      testName: testName,
      attemptId: attemptId,
    );
    await _store.save(bookmark);
    state = AsyncData([
      bookmark,
      ...?state.value?.where((item) => item.id != id),
    ]);
    return true;
  }

  Future<void> remove(String id) async {
    await _store.remove(id);
    state = AsyncData([...?state.value?.where((item) => item.id != id)]);
  }
}

final isQuestionBookmarkedProvider = Provider.family<bool, String>((ref, id) {
  final bookmarks = ref.watch(questionBookmarksProvider).value ?? const [];
  return bookmarks.any((bookmark) => bookmark.id == id);
});
