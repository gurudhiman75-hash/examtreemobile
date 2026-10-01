import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../routes/app_router.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../data/push_notification_registration_service.dart';

final pushNotificationRegistrationServiceProvider =
    Provider<PushNotificationRegistrationService>((ref) {
  final service = PushNotificationRegistrationService(
    apiClient: ref.watch(apiClientProvider),
    onOpenDestination: (destinationType, destinationValue) {
      final router = ref.read(goRouterProvider);
      switch (destinationType) {
        case 'exam':
          if (destinationValue.isNotEmpty) {
            router.push(
              '/exam-details?id=${Uri.encodeQueryComponent(destinationValue)}',
            );
          } else {
            router.push('/notifications');
          }
          return;
        case 'test_series':
          router.go('/exams');
          return;
        case 'learn':
          if (destinationValue.startsWith('/')) {
            router.push(destinationValue);
          } else {
            router.go('/learn');
          }
          return;
        case 'url':
          final uri = Uri.tryParse(destinationValue);
          if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
            launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            router.push('/notifications');
          }
          return;
        default:
          router.push('/notifications');
      }
    },
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
