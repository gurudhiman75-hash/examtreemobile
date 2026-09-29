import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_learn_practice_progress_store.dart';
import '../../domain/learn_practice_models.dart';

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
