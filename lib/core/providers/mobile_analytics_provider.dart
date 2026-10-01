import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/mobile_analytics_client.dart';
import 'repository_providers.dart';

final mobileAnalyticsClientProvider = Provider<MobileAnalyticsClient>((ref) {
  return MobileAnalyticsClient(ref.watch(apiClientProvider));
});
