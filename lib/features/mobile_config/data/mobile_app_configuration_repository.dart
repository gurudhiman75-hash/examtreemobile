import '../../../core/network/api_client.dart';
import '../domain/mobile_app_configuration.dart';

class MobileAppConfigurationRepository {
  const MobileAppConfigurationRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<MobileAppConfiguration> load() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        'mobile/config',
      );
      final raw = response.data?['configuration'];
      if (raw is! Map) return MobileAppConfiguration.fallback;
      return MobileAppConfiguration.fromJson(
        Map<String, dynamic>.from(raw),
      );
    } catch (_) {
      // Remote configuration is an operational enhancement, never an app
      // startup dependency. Fail open to the bundled safe configuration.
      return MobileAppConfiguration.fallback;
    }
  }
}
