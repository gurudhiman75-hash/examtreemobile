import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../data/mobile_content_planning_repository.dart';
import '../domain/mobile_content_plan_item.dart';

final mobileContentPlanningRepositoryProvider =
    Provider<MobileContentPlanningRepository>((ref) {
  return MobileContentPlanningRepository(ref.watch(apiClientProvider));
});

final mobileContentPlanProvider =
    FutureProvider.family<List<MobileContentPlanItem>, String>((ref, slotKey) {
  return ref.watch(mobileContentPlanningRepositoryProvider).loadSlot(slotKey);
});
