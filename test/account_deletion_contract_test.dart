import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mobile account deletion contract', () {
    test('uses canonical destructive endpoint and typed confirmation', () {
      final apiRepository = File(
        'lib/core/repositories/api_account_repository.dart',
      ).readAsStringSync();
      final contract = File(
        'lib/core/repositories/account_repository.dart',
      ).readAsStringSync();

      expect(apiRepository, contains("'/users/me'"));
      expect(apiRepository, contains("confirmation = 'DELETE MY ACCOUNT'"));
      expect(
        apiRepository,
        contains("data: const {'confirmation': confirmation}"),
      );
      expect(contract, contains("code == 'REAUTH_REQUIRED'"));
    });

    test('profile exposes privacy and account controls', () {
      final profileEntry = File(
        'lib/features/profile/presentation/profile_screen.dart',
      ).readAsStringSync();
      final profile = File(
        'lib/features/profile/presentation/profile_screen_v5.dart',
      ).readAsStringSync();
      final account = File(
        'lib/features/profile/presentation/account_settings_screen.dart',
      ).readAsStringSync();
      final router = File('lib/routes/app_router.dart').readAsStringSync();

      expect(profileEntry, contains("export 'profile_screen_v5.dart';"));
      expect(profile, contains("context.push('/account')"));
      expect(profile, contains('Privacy & account'));
      expect(router, contains("path: '/account'"));
      expect(account, contains('account-delete-confirmation-field'));
      expect(account, contains('account-delete-confirm-button'));
      expect(account, contains('https://sarbedutech.web.app/privacy'));
      expect(
        account,
        contains('https://sarbedutech.web.app/account-deletion'),
      );
      expect(account, contains("'/login?continue=%2Faccount'"));
    });

    test('successful deletion erases learner-owned device data and reminders', () {
      final account = File(
        'lib/features/profile/presentation/account_settings_screen.dart',
      ).readAsStringSync();
      final drafts = File(
        'lib/features/test_attempt/data/local_attempt_draft_store.dart',
      ).readAsStringSync();
      final companion = File(
        'lib/features/companion/data/local_daily_companion_store.dart',
      ).readAsStringSync();

      expect(account, contains('attemptDraftStoreProvider).deleteAllForUser'));
      expect(account, contains('dailyCompanionStoreProvider).deleteAllForUser'));
      expect(account, contains('examDayControllerProvider).deleteTarget'));
      expect(account, contains('studyReminderServiceProvider).cancel()'));
      expect(account, contains('examDayControllerProvider).cancelReminders()'));
      expect(account, contains('companionWidgetServiceProvider).clear()'));
      expect(account, contains('authControllerProvider).signOut()'));

      expect(drafts, contains('Future<void> deleteAllForUser(String userId)'));
      expect(drafts, contains("where: 'user_id = ?'"));
      expect(companion, contains('Future<void> deleteAllForUser(String userId)'));
      expect(companion, contains('_eventTable'));
      expect(companion, contains('_revisionTable'));
      expect(companion, contains('_settingsTable'));
    });

    test('learner-facing deletion errors do not expose raw exceptions', () {
      final account = File(
        'lib/features/profile/presentation/account_settings_screen.dart',
      ).readAsStringSync();

      expect(account, isNot(contains(r'$error')));
      expect(
        account,
        contains('Account deletion could not be completed. Please try again.'),
      );
    });
  });
}
