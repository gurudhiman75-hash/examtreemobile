import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/result_model.dart';
import '../../../../core/providers/repository_providers.dart';

final userResultsProvider = FutureProvider<List<Result>>((ref) async {
  final repository = ref.watch(resultRepositoryProvider);
  // Assuming hardcoded user for now
  return repository.getUserResults('user_1');
});

final resultProvider = FutureProvider.family<Result, String>((ref, attemptId) async {
  final repository = ref.watch(resultRepositoryProvider);
  return repository.getResult(attemptId);
});
