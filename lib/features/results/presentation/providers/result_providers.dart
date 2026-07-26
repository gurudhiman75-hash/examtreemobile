import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/result_model.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final userResultsProvider = FutureProvider<List<Result>>((ref) async {
  final repository = ref.watch(resultRepositoryProvider);
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw StateError('Authentication is required to load result history.');
  }
  return repository.getUserResults(user.uid);
});

final resultProvider = FutureProvider.family<Result, String>((ref, attemptId) async {
  final repository = ref.watch(resultRepositoryProvider);
  return repository.getResult(attemptId);
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
