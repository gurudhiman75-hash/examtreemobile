import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../preferences/domain/question_language.dart';
import '../../../preferences/presentation/providers/question_language_providers.dart';
import '../../data/api_learn_practice_question_repository.dart';
import '../../data/local_learn_practice_progress_store.dart';
import '../../domain/learn_practice_models.dart';
import '../../domain/learn_practice_question.dart';

final learnPracticeProgressStoreProvider =
    Provider<LearnPracticeProgressStore>((ref) {
  return SqfliteLearnPracticeProgressStore();
});

final learnPracticeProgressProvider =
    FutureProvider.family<LearnPracticeProgress?, String>((ref, topicId) {
  return ref.watch(learnPracticeProgressStoreProvider).read(topicId);
});

final learnPracticeProgressListProvider =
    FutureProvider<List<LearnPracticeProgress>>((ref) {
  return ref.watch(learnPracticeProgressStoreProvider).readAll();
});


final learnPracticeQuestionRepositoryProvider =
    Provider<LearnPracticeQuestionRepository>((ref) {
  return ApiLearnPracticeQuestionRepository(ref.watch(apiClientProvider).dio);
});

class LearnPracticeRequest {
  const LearnPracticeRequest({
    required this.topicId,
    required this.limit,
    this.tagQuery = '',
    this.fresh = false,
  });

  final String topicId;
  final int limit;
  final String tagQuery;
  final bool fresh;

  @override
  bool operator ==(Object other) =>
      other is LearnPracticeRequest &&
      other.topicId == topicId &&
      other.limit == limit &&
      other.tagQuery == tagQuery &&
      other.fresh == fresh;

  @override
  int get hashCode => Object.hash(topicId, limit, tagQuery, fresh);
}

final learnPracticeQuestionsProvider =
    FutureProvider.family<List<LearnPracticeQuestion>, LearnPracticeRequest>(
  (ref, request) async {
    final language = await ref.watch(questionLanguageProvider.future);
    return ref.watch(learnPracticeQuestionRepositoryProvider).loadQuestions(
          topicId: request.topicId,
          limit: request.limit,
          language: switch (language) {
            QuestionLanguage.english => 'en',
            QuestionLanguage.hindi => 'hi',
            QuestionLanguage.punjabi => 'pa',
          },
          tagQuery: request.tagQuery,
          fresh: request.fresh,
        );
  },
);
