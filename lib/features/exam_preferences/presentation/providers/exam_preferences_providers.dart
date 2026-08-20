import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/exam_preferences_repository.dart';
import '../../domain/exam_preferences.dart';

final examPreferencesRepositoryProvider = Provider<ExamPreferencesRepository>((ref) {
  return ExamPreferencesRepository(ref.watch(apiClientProvider));
});

final examPreferenceSnapshotProvider = FutureProvider<ExamPreferenceSnapshot>((ref) async {
  final repository = ref.watch(examPreferencesRepositoryProvider);
  final values = await Future.wait([
    repository.loadCatalogue(),
    repository.loadPreferences(),
  ]);
  return ExamPreferenceSnapshot(
    catalogue: values[0] as ExamTargetCatalogue,
    preferences: values[1] as LearnerExamPreferences,
  );
});

final selectedExamIdsProvider = Provider<AsyncValue<List<String>>>((ref) {
  return ref.watch(examPreferenceSnapshotProvider).whenData(
        (snapshot) => snapshot.preferences.selectedExamIds,
      );
});
