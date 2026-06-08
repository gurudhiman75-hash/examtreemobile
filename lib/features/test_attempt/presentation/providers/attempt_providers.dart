import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/attempt_model.dart';
import '../../../../core/providers/repository_providers.dart';

final activeAttemptProvider = FutureProvider.family<Attempt, String>((ref, examId) async {
  final repository = ref.watch(attemptRepositoryProvider);
  // Assuming a hardcoded userId for now, since auth is not implemented
  return repository.getActiveAttempt(examId, 'user_1');
});

final attemptProvider = FutureProvider.family<Attempt, String>((ref, attemptId) async {
  final repository = ref.watch(attemptRepositoryProvider);
  return repository.getAttempt(attemptId);
});
