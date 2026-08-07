import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/analytics_model.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/performance_analytics.dart';

final userAnalyticsProvider = FutureProvider<Analytics>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw StateError('Authentication is required to load profile analytics.');
  }
  return repository.getUserAnalytics(user.uid);
});

final performanceAnalyticsProvider = FutureProvider<PerformanceAnalytics>((ref) async {
  final repository = ref.watch(resultRepositoryProvider);
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw StateError('Authentication is required to load performance analytics.');
  }
  final results = await repository.getUserResults(user.uid);
  return PerformanceAnalytics.fromResults(user.uid, results);
});
