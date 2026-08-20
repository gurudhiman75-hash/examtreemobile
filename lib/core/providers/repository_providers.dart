import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/test_attempt/data/local_attempt_draft_store.dart';
import '../network/api_client.dart';
import '../network/api_server_readiness.dart';
import '../repositories/account_repository.dart';
import '../repositories/analytics_repository.dart';
import '../repositories/api_account_repository.dart';
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

final apiServerReadinessProvider = Provider<ApiServerReadiness>((ref) {
  final readiness = DioApiServerReadiness(
    apiBaseUrl: ref.watch(apiClientProvider).dio.options.baseUrl,
  );
  ref.onDispose(readiness.close);
  return readiness;
});

final apiServerWarmupProvider = FutureProvider<void>((ref) async {
  try {
    await ref.watch(apiServerReadinessProvider).ensureReady();
  } catch (_) {
    // Startup warmup is best-effort. Authentication retries the same readiness
    // probe with a visible status before creating or synchronizing a session.
  }
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return ApiAccountRepository(ref.watch(apiClientProvider));
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

final attemptDraftStoreProvider = Provider<AttemptDraftStore>((ref) {
  return SqfliteAttemptDraftStore();
});
