import '../../../core/network/api_client.dart';
import '../domain/mobile_content_plan_item.dart';

class MobileContentPlanningRepository {
  const MobileContentPlanningRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<MobileContentPlanItem>> loadSlot(String slotKey) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        'mobile/content-plan',
        queryParameters: <String, Object?>{'slot': slotKey},
      );
      final raw = response.data?['items'];
      if (raw is! List) return const <MobileContentPlanItem>[];
      final items = raw
          .whereType<Map>()
          .map((item) => MobileContentPlanItem.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .where((item) => item.id.isNotEmpty && item.entityId.isNotEmpty)
          .toList(growable: false)
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return List.unmodifiable(items);
    } catch (_) {
      return const <MobileContentPlanItem>[];
    }
  }
}
