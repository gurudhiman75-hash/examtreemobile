import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/mobile_analytics_client.dart';
import 'repository_providers.dart';

final mobileAnalyticsClientProvider = Provider<MobileAnalyticsClient>((ref) {
  if (Firebase.apps.isEmpty) return MobileAnalyticsClient.disabled();
  return MobileAnalyticsClient(ref.watch(apiClientProvider));
});
