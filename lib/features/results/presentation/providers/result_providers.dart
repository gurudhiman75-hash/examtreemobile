import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/result_model.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final userResultsProvider = FutureProvider<List<Result>>((ref) async {
  final repository = ref.watch(resultRepositoryProvider);
  final user = ref.watch(authStateChangesProvider).value;
  final userId = user?.uid ?? 'user_1';
  return repository.getUserResults(userId);
});

final resultProvider = FutureProvider.family<Result, String>((ref, attemptId) async {
  final repository = ref.watch(resultRepositoryProvider);
  return repository.getResult(attemptId);
});
