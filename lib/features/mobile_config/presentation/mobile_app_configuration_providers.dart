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
