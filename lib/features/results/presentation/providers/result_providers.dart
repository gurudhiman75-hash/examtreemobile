import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/result_model.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../preferences/domain/question_language.dart';
import '../../../preferences/presentation/providers/question_language_providers.dart';

final userResultsProvider = FutureProvider<List<Result>>((ref) async {
  final repository = ref.watch(resultRepositoryProvider);
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw StateError('Authentication is required to load result history.');
  }
  final language = await ref.watch(questionLanguageProvider.future);
  final results = await repository.getUserResults(user.uid);
  return results
      .map((result) => localizeResult(result, language))
      .toList(growable: false);
});

final resultProvider = FutureProvider.family<Result, String>((ref, attemptId) async {
  final repository = ref.watch(resultRepositoryProvider);
  final language = await ref.watch(questionLanguageProvider.future);
  final result = await repository.getResult(attemptId);
  return localizeResult(result, language);
});

final completedAttemptCountProvider = FutureProvider.family<int, String>((
  ref,
  testId,
) async {
  final results = await ref.watch(userResultsProvider.future);
  return countCompletedAttemptsForTest(results, testId);
});

int countCompletedAttemptsForTest(List<Result> results, String testId) {
  final normalizedTestId = testId.trim();
  if (normalizedTestId.isEmpty) return 0;
  return results.where((result) => result.examId == normalizedTestId).length;
}
