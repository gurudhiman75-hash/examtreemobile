import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/analytics_model.dart';
import '../../../../core/providers/repository_providers.dart';

final userAnalyticsProvider = FutureProvider<Analytics>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  // Assuming hardcoded user for now
  return repository.getUserAnalytics('user_1');
});
