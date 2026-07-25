import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../repositories/analytics_repository.dart';
import '../repositories/api_attempt_draft_repository.dart';
import '../repositories/api_attempt_session_repository.dart';
import '../repositories/attempt_repository.dart';
import '../repositories/attempt_draft_repository.dart';
import '../repositories/attempt_session_repository.dart';
import '../repositories/exam_repository.dart';
import '../repositories/result_repository.dart';

import '../repositories/api_exam_repository.dart';
import '../repositories/mock_analytics_repository.dart';
import '../repositories/mock_attempt_repository.dart';
import '../repositories/mock_result_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final examRepositoryProvider = Provider<ExamRepository>((ref) {
  return ApiExamRepository(ref.watch(apiClientProvider).dio);
});

final attemptRepositoryProvider = Provider<AttemptRepository>((ref) {
  return MockAttemptRepository();
});

final resultRepositoryProvider = Provider<ResultRepository>((ref) {
  return MockResultRepository();
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return MockAnalyticsRepository();
});

@Deprecated('Use attemptSessionRepositoryProvider for canonical Neon attempts.')
final attemptDraftRepositoryProvider = Provider<AttemptDraftRepository>((ref) {
  return ApiAttemptDraftRepository(ref.watch(apiClientProvider));
});

final attemptSessionRepositoryProvider = Provider<AttemptSessionRepository>((ref) {
  return ApiAttemptSessionRepository(ref.watch(apiClientProvider));
});
