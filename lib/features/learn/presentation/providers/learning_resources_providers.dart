import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/exam_model.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../exam_preferences/presentation/providers/exam_preferences_providers.dart';
import '../../../exams/presentation/providers/exam_providers.dart';
import '../../../preferences/domain/question_language.dart';
import '../../../preferences/presentation/providers/question_language_providers.dart';
import '../../data/learning_resources_repository.dart';
import '../../domain/learning_resource.dart';

final learningResourcesRepositoryProvider = Provider<LearningResourcesRepository>((ref) {
  return LearningResourcesRepository(ref.watch(apiClientProvider));
});

String learningResourceLanguageCode(QuestionLanguage language) => switch (language) {
      QuestionLanguage.english => 'en',
      QuestionLanguage.hindi => 'hi',
      QuestionLanguage.punjabi => 'pa',
    };

final learningResourcesProvider = FutureProvider<List<LearningResourceSummary>>((ref) async {
  final repository = ref.watch(learningResourcesRepositoryProvider);
  final language = await ref.watch(questionLanguageProvider.future);
  final preferredCode = learningResourceLanguageCode(language);
  final preferred = await repository.loadResources(languageCode: preferredCode);
  if (preferredCode == 'en') return preferred;

  final english = await repository.loadResources(languageCode: 'en');
  final combined = <LearningResourceSummary>[];
  for (final category in LearningResourceCategory.values) {
    final localized = preferred.where((resource) => resource.category == category).toList();
    if (localized.isNotEmpty) {
      combined.addAll(localized);
    } else {
      combined.addAll(english.where((resource) => resource.category == category));
    }
  }
  return combined;
});

final relevantLearningResourcesProvider = Provider<AsyncValue<List<LearningResourceSummary>>>((ref) {
  final resources = ref.watch(learningResourcesProvider);
  final selections = ref.watch(selectedExamIdsProvider);
  return switch ((resources, selections)) {
    (AsyncData(value: final resourceList), AsyncData(value: final selectedIds)) =>
      AsyncValue.data(
        relevantLearningResources(
          resources: resourceList,
          selectedExamIds: selectedIds,
        ),
      ),
    (AsyncError(error: final error, stackTrace: final stack), _) =>
      AsyncValue.error(error, stack),
    (_, AsyncError()) => resources.whenData(
        (items) => relevantLearningResources(
          resources: items,
          selectedExamIds: const <String>[],
        ),
      ),
    _ => const AsyncValue.loading(),
  };
});

final learnFreeTestsProvider = Provider<AsyncValue<List<Exam>>>((ref) {
  final examsAsync = ref.watch(availableExamsProvider);
  final codesAsync = ref.watch(selectedExamCodesProvider);

  return examsAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
    data: (exams) {
      final free = exams
          .where((exam) => exam.status.trim().toLowerCase() != 'paid')
          .toList(growable: false);
      final selectedCodes = codesAsync.value ?? const <String>[];
      if (selectedCodes.isEmpty) return AsyncValue.data(free);
      final rank = <String, int>{};
      for (var index = 0; index < selectedCodes.length; index++) {
        rank.putIfAbsent(selectedCodes[index].trim().toLowerCase(), () => index);
      }
      final decorated = <({Exam exam, int index, int? rank})>[];
      for (var index = 0; index < free.length; index++) {
        final exam = free[index];
        final code = _canonicalExamCode(exam)?.toLowerCase();
        decorated.add((exam: exam, index: index, rank: code == null ? null : rank[code]));
      }
      decorated.sort((left, right) {
        if (left.rank == null && right.rank == null) {
          return left.index.compareTo(right.index);
        }
        if (left.rank == null) return 1;
        if (right.rank == null) return -1;
        final byRank = left.rank!.compareTo(right.rank!);
        return byRank != 0 ? byRank : left.index.compareTo(right.index);
      });
      return AsyncValue.data(decorated.map((item) => item.exam).toList(growable: false));
    },
  );
});

final learningResourceDetailProvider = FutureProvider.family<LearningResourceDetail, String>((ref, id) {
  return ref.watch(learningResourcesRepositoryProvider).loadResource(id);
});

String? _canonicalExamCode(Exam exam) {
  for (final tag in exam.tags) {
    if (tag.startsWith('exam-code:')) {
      final code = tag.substring('exam-code:'.length).trim();
      if (code.isNotEmpty) return code;
    }
  }
  return null;
}
