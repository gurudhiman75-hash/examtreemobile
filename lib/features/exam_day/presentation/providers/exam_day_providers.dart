import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/local_exam_day_store.dart';
import '../../domain/exam_day_mode.dart';
import '../../services/exam_day_reminder_service.dart';

final examDayStoreProvider = Provider<ExamDayStore>((ref) {
  return SqfliteExamDayStore();
});

final examDayReminderServiceProvider = Provider<ExamDayReminderService>((ref) {
  return LocalExamDayReminderService();
});

final examDayClockProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});

final examDayTargetProvider = FutureProvider<ExamDayTarget?>((ref) async {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw StateError('Authentication is required to load Exam-Day Mode.');
  }
  return ref.watch(examDayStoreProvider).loadTarget(user.uid);
});

final examDayControllerProvider = Provider<ExamDayController>((ref) {
  return ExamDayController(
    store: ref.watch(examDayStoreProvider),
    reminderService: ref.watch(examDayReminderServiceProvider),
  );
});

class ExamDayController {
  const ExamDayController({
    required ExamDayStore store,
    required ExamDayReminderService reminderService,
  })  : _store = store,
        _reminderService = reminderService;

  final ExamDayStore _store;
  final ExamDayReminderService _reminderService;

  Future<bool> saveTarget({
    required String userId,
    required ExamDayTarget target,
  }) async {
    final reminderReady = await _reminderService.schedule(target);
    final effectiveTarget = reminderReady
        ? target
        : target.copyWith(remindersEnabled: false, updatedAt: DateTime.now());
    await _store.saveTarget(userId: userId, target: effectiveTarget);
    return reminderReady;
  }

  Future<void> saveChecklist({
    required String userId,
    required ExamDayTarget target,
  }) {
    return _store.saveTarget(userId: userId, target: target);
  }

  Future<void> restoreReminders(String userId) async {
    final target = await _store.loadTarget(userId);
    if (target == null || !target.remindersEnabled) return;

    final reminderReady = await _reminderService.schedule(target);
    if (!reminderReady) {
      await _store.saveTarget(
        userId: userId,
        target: target.copyWith(
          remindersEnabled: false,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> deleteTarget(String userId) async {
    await _reminderService.cancel();
    await _store.deleteTarget(userId);
  }

  Future<void> cancelReminders() => _reminderService.cancel();
}
