import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/exam_day/domain/exam_day_mode.dart';
import 'package:examtree/features/exam_day/presentation/exam_day_screen.dart';
import 'package:examtree/features/exam_day/presentation/providers/exam_day_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 22, 8, 30);

  ExamDayTarget target() => ExamDayTarget(
        examName: 'SSC CGL Tier I',
        examAt: DateTime(2026, 8, 25, 10),
        reportingAt: DateTime(2026, 8, 25, 9),
        venue: 'Sector 62 exam centre, Noida',
        remindersEnabled: true,
        checklist: [
          for (var index = 0; index < defaultExamDayChecklist.length; index++)
            ExamDayChecklistItem(
              id: defaultExamDayChecklist[index].id,
              label: defaultExamDayChecklist[index].label,
              completed: index < 3,
            ),
        ],
        updatedAt: now,
      );

  Future<void> pumpExamDay(
    WidgetTester tester, {
    required ExamDayTarget? target,
    double textScale = 1,
  }) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          examDayClockProvider.overrideWithValue(() => now),
          examDayTargetProvider.overrideWith((ref) async => target),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              textScaler: TextScaler.linear(textScale),
              disableAnimations: true,
            ),
            child: const ExamDayScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('exam day prioritizes countdown, logistics and checklist', (
    tester,
  ) async {
    await pumpExamDay(tester, target: target());

    expect(find.byKey(const Key('exam-day-countdown')), findsOneWidget);
    expect(find.text('SSC CGL Tier I'), findsOneWidget);
    expect(find.text('Final week'), findsOneWidget);
    expect(find.text('3 d 1 h'), findsOneWidget);
    expect(find.text('Reporting countdown'), findsOneWidget);
    expect(find.text('Saved logistics'), findsOneWidget);
    expect(find.byKey(const Key('exam-day-quick-revision')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty exam day stays truthful and asks learner for a target', (
    tester,
  ) async {
    await pumpExamDay(tester, target: null);

    expect(find.byKey(const Key('exam-day-empty')), findsOneWidget);
    expect(find.text('Set one active exam target'), findsOneWidget);
    expect(find.text('Set exam target'), findsOneWidget);
    expect(find.textContaining('does not invent exam dates'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exam day remains usable at 200 percent text scaling', (
    tester,
  ) async {
    await pumpExamDay(tester, target: target(), textScale: 2);

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('exam-day-countdown')), findsOneWidget);

    final scrollable = find.descendant(
      of: find.byKey(const Key('exam-day-scroll')),
      matching: find.byType(Scrollable),
    );

    for (var index = 0; index < 5; index++) {
      await tester.drag(scrollable, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    expect(find.byKey(const Key('exam-day-checklist')), findsOneWidget);
    expect(find.text('Exam-day checklist'), findsOneWidget);
    expect(find.textContaining('Official instructions remain authoritative'), findsOneWidget);
  });
}
