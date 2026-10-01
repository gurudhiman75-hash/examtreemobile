import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../data/mobile_home_repository.dart';
import '../domain/mobile_home_configuration.dart';

final mobileHomeRepositoryProvider = Provider<MobileHomeRepository?>((ref) {
  if (Firebase.apps.isEmpty) return null;
  return MobileHomeRepository(ref.watch(apiClientProvider));
});

final mobileHomeConfigurationProvider =
    FutureProvider<MobileHomeConfiguration>((ref) async {
  final repository = ref.watch(mobileHomeRepositoryProvider);
  if (repository == null) return MobileHomeConfiguration.fallback;
  try {
    return await repository.load();
  } catch (_) {
    return MobileHomeConfiguration.fallback;
  }
});
