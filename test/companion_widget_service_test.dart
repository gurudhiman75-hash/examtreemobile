import 'package:examtree/features/companion/domain/daily_companion.dart';
import 'package:examtree/features/companion/services/companion_widget_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.examtree.examtree/companion_widget');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('publishes truthful Daily Companion counts', () async {
    final now = DateTime(2026, 8, 14, 8, 30);
    final snapshot = DailyCompanionSnapshot(
      settings: const StudyCompanionSettings(dailyQuestionGoal: 10),
      items: [
        _item('due-1', now.subtract(const Duration(minutes: 5))),
        _item('due-2', now),
        _item('later', now.add(const Duration(days: 1))),
      ],
      completedToday: 4,
    );

    await const AndroidCompanionWidgetService().publish(snapshot, now: now);

    expect(calls, hasLength(1));
    expect(calls.single.method, 'publish');
    final arguments = calls.single.arguments! as Map<Object?, Object?>;
    expect(arguments['dueCount'], 2);
    expect(arguments['dailyGoal'], 10);
    expect(arguments['completedToday'], 4);
    expect(arguments['remainingGoal'], 6);
    expect(arguments['savedCount'], 3);
    expect(arguments['updatedAtMillis'], now.millisecondsSinceEpoch);
  });

  test('clear removes private launcher state through native bridge', () async {
    await const AndroidCompanionWidgetService().clear();

    expect(calls, hasLength(1));
    expect(calls.single.method, 'clear');
  });
}

RevisionItem _item(String id, DateTime dueAt) => RevisionItem(
      id: id,
      sourceAttemptId: 'attempt-1',
      testId: 'test-1',
      testName: 'SSC Mock',
      section: 'Quant',
      questionText: 'Question $id',
      options: const ['A', 'B', 'C', 'D'],
      selectedIndex: 1,
      correctIndex: 0,
      explanation: 'Explanation',
      reasons: const {RevisionReason.incorrect},
      timeTakenSeconds: 45,
      dueAt: dueAt,
      stage: 0,
      createdAt: dueAt,
    );
