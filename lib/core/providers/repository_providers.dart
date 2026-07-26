import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../repositories/analytics_repository.dart';
import '../repositories/api_attempt_session_repository.dart';
import '../repositories/api_exam_repository.dart';
import '../repositories/api_result_repository.dart';
import '../repositories/attempt_session_repository.dart';
import '../repositories/canonical_analytics_repository.dart';
import '../repositories/exam_repository.dart';
import '../repositories/result_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final examRepositoryProvider = Provider<ExamRepository>((ref) {
  return ApiExamRepository(ref.watch(apiClientProvider).dio);
});

final resultRepositoryProvider = Provider<ResultRepository>((ref) {
  return ApiResultRepository(ref.watch(apiClientProvider));
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return CanonicalAnalyticsRepository(ref.watch(resultRepositoryProvider));
});

final attemptSessionRepositoryProvider = Provider<AttemptSessionRepository>((ref) {
  return ApiAttemptSessionRepository(ref.watch(apiClientProvider));
});
