import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../data/mobile_home_repository.dart';
import '../domain/mobile_home_configuration.dart';

final mobileHomeRepositoryProvider = Provider<MobileHomeRepository>((ref) {
  return MobileHomeRepository(ref.watch(apiClientProvider));
});

final mobileHomeConfigurationProvider =
    FutureProvider<MobileHomeConfiguration>((ref) async {
  try {
    return await ref.watch(mobileHomeRepositoryProvider).load();
  } catch (_) {
    return MobileHomeConfiguration.fallback;
  }
});
