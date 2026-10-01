import '../../../core/network/api_client.dart';
import '../domain/mobile_home_configuration.dart';

class MobileHomeRepository {
  const MobileHomeRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<MobileHomeConfiguration> load() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        'mobile/home-config',
      );
      final body = response.data;
      final raw = body?['configuration'];
      if (raw is! Map) return MobileHomeConfiguration.fallback;
      return MobileHomeConfiguration.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      // Homepage configuration must never block app startup. The checked-in
      // fallback preserves the approved homepage when the API is unavailable.
      return MobileHomeConfiguration.fallback;
    }
  }
}
