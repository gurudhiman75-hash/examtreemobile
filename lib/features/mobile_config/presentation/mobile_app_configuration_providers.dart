import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../data/mobile_app_configuration_repository.dart';
import '../domain/mobile_app_configuration.dart';

final mobileAppConfigurationRepositoryProvider =
    Provider<MobileAppConfigurationRepository>((ref) {
  return MobileAppConfigurationRepository(ref.watch(apiClientProvider));
});

final mobileAppConfigurationProvider =
    FutureProvider<MobileAppConfiguration>((ref) async {
  return ref.watch(mobileAppConfigurationRepositoryProvider).load();
});

/// Remote feature flag keys the app reads. Add a key here before using it so
/// admins can find the full list in one place.
abstract final class MobileFeatureFlags {
  /// Full / Sectional / Topic-wise / PYQs switcher on the series test list.
  static const seriesTestTypeTabs = 'series_test_type_tabs';
}

/// Reads one remote feature flag. While the configuration is loading or
/// cannot be fetched, the flag uses its default.
final mobileFeatureFlagProvider =
    Provider.family<bool, ({String key, bool defaultValue})>((ref, flag) {
  final config = ref.watch(mobileAppConfigurationProvider).value;
  return config?.isEnabled(flag.key, defaultValue: flag.defaultValue) ??
      flag.defaultValue;
});
