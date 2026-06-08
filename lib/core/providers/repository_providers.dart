import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/analytics_repository.dart';
import '../repositories/attempt_repository.dart';
import '../repositories/exam_repository.dart';
import '../repositories/result_repository.dart';

import '../repositories/mock_analytics_repository.dart';
import '../repositories/mock_attempt_repository.dart';
import '../repositories/mock_exam_repository.dart';
import '../repositories/mock_result_repository.dart';

final examRepositoryProvider = Provider<ExamRepository>((ref) {
  return MockExamRepository();
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
