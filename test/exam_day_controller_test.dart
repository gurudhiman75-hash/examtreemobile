import 'package:examtree/features/exam_day/data/local_exam_day_store.dart';
import 'package:examtree/features/exam_day/domain/exam_day_mode.dart';
import 'package:examtree/features/exam_day/presentation/providers/exam_day_providers.dart';
import 'package:examtree/features/exam_day/services/exam_day_reminder_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notification denial persists target with reminders disabled', () async {
    final store = _FakeStore();
    final reminders = _FakeReminders(scheduleResult: false);
    final controller = ExamDayController(
      store: store,
      reminderService: reminders,
    );
    final target = _target(remindersEnabled: true);

    final ready = await controller.saveTarget(userId: 'user-1', target: target);

    expect(ready, isFalse);
    expect(reminders.scheduleCalls, 1);
    expect(store.savedTarget?.remindersEnabled, isFalse);
  });

  test('checklist updates do not reschedule notification permission flow', () async {
    final store = _FakeStore();
    final reminders = _FakeReminders(scheduleResult: true);
    final controller = ExamDayController(
      store: store,
      reminderService: reminders,
    );

    await controller.saveChecklist(
      userId: 'user-1',
      target: _target(remindersEnabled: true),
    );

    expect(store.saveCalls, 1);
    expect(reminders.scheduleCalls, 0);
  });

  test('deleting target cancels reminders before local removal', () async {
    final order = <String>[];
    final store = _FakeStore(order: order);
    final reminders = _FakeReminders(scheduleResult: true, order: order);
    final controller = ExamDayController(
      store: store,
      reminderService: reminders,
    );

    await controller.deleteTarget('user-1');

    expect(order, ['cancel', 'delete']);
  });
}

ExamDayTarget _target({required bool remindersEnabled}) => ExamDayTarget(
      examName: 'SSC CGL',
      examAt: DateTime(2026, 9, 15, 9),
      remindersEnabled: remindersEnabled,
      checklist: defaultExamDayChecklist,
      updatedAt: DateTime(2026, 8, 14),
    );

class _FakeStore implements ExamDayStore {
  _FakeStore({this.order});

  final List<String>? order;
  int saveCalls = 0;
  ExamDayTarget? savedTarget;

  @override
  Future<void> deleteTarget(String userId) async {
    order?.add('delete');
  }

  @override
  Future<ExamDayTarget?> loadTarget(String userId) async => savedTarget;

  @override
  Future<void> saveTarget({
    required String userId,
    required ExamDayTarget target,
  }) async {
    saveCalls++;
    savedTarget = target;
  }
}

class _FakeReminders implements ExamDayReminderService {
  _FakeReminders({required this.scheduleResult, this.order});

  final bool scheduleResult;
  final List<String>? order;
  int scheduleCalls = 0;

  @override
  Future<void> cancel() async {
    order?.add('cancel');
  }

  @override
  Future<bool> schedule(ExamDayTarget target) async {
    scheduleCalls++;
    return scheduleResult;
  }
}
