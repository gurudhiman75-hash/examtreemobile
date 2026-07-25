import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/attempt_model.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final activeAttemptProvider = FutureProvider.family<Attempt, String>((ref, examId) async {
  final repository = ref.watch(attemptRepositoryProvider);
  final user = ref.watch(authStateChangesProvider).value;
  final userId = user?.uid ?? 'user_1';
  return repository.getActiveAttempt(examId, userId);
});

final attemptProvider = FutureProvider.family<Attempt, String>((ref, attemptId) async {
  final repository = ref.watch(attemptRepositoryProvider);
  return repository.getAttempt(attemptId);
});
