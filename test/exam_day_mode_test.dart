import 'package:examtree/features/exam_day/domain/exam_day_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 14, 15, 30);

  test('exam day stages are based only on saved time remaining', () {
    expect(
      examDayStage(_target(now.add(const Duration(days: 20))), now),
      ExamDayStage.planning,
    );
    expect(
      examDayStage(_target(now.add(const Duration(days: 5))), now),
      ExamDayStage.finalWeek,
    );
    expect(
      examDayStage(_target(now.add(const Duration(hours: 20))), now),
      ExamDayStage.finalDay,
    );
    expect(
      examDayStage(DateTime(2026, 8, 14, 18).let(_target), now),
      ExamDayStage.examDay,
    );
    expect(
      examDayStage(_target(now.subtract(const Duration(minutes: 1))), now),
      ExamDayStage.scheduledTimeReached,
    );
  });

  test('countdown never invents progress after scheduled time', () {
    expect(
      examCountdownLabel(now.subtract(const Duration(minutes: 5)), now),
      'Scheduled time reached',
    );
    expect(
      examCountdownLabel(now.add(const Duration(days: 2, hours: 3)), now),
      '2 d 3 h',
    );
  });

  test('stored built-in checklist state survives schema additions', () {
    const stored = [
      ExamDayChecklistItem(
        id: 'official_instructions',
        label: 'Old label',
        completed: true,
      ),
      ExamDayChecklistItem(
        id: 'custom_bus',
        label: 'Bus ticket ready',
        completed: false,
        isCustom: true,
      ),
    ];

    final merged = mergeExamDayChecklist(stored);

    expect(merged.length, defaultExamDayChecklist.length + 1);
    expect(
      merged.firstWhere((item) => item.id == 'official_instructions').completed,
      isTrue,
    );
    expect(merged.any((item) => item.id == 'custom_bus'), isTrue);
  });
}

ExamDayTarget _target(DateTime examAt) => ExamDayTarget(
      examName: 'Mock exam',
      examAt: examAt,
      remindersEnabled: false,
      checklist: defaultExamDayChecklist,
      updatedAt: DateTime(2026, 8, 1),
    );

extension _Let<T> on T {
  R let<R>(R Function(T value) transform) => transform(this);
}
