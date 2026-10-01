import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../data/push_notification_registration_service.dart';

final pushNotificationRegistrationServiceProvider =
    Provider<PushNotificationRegistrationService>((ref) {
  final service = PushNotificationRegistrationService(
    apiClient: ref.watch(apiClientProvider),
  );
  ref.onDispose(() => service.dispose());
  return service;
});

final pushNotificationBootstrapProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null || !user.emailVerified) return;
  await ref
      .watch(pushNotificationRegistrationServiceProvider)
      .initializeForAuthenticatedUser();
});
