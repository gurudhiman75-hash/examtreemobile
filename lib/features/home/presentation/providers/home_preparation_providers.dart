import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../companion/presentation/providers/daily_companion_providers.dart';

final homeDueRevisionCountProvider = Provider<AsyncValue<int>>((ref) {
  final companionAsync = ref.watch(dailyCompanionSnapshotProvider);
  final now = ref.watch(dailyCompanionClockProvider)();
  return companionAsync.whenData((snapshot) => snapshot.dueItems(now).length);
});
