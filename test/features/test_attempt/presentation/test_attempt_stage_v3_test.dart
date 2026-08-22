import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/test_attempt/presentation/widgets/test_attempt_stage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpStage(
    WidgetTester tester, {
    double textScale = 1,
    int? selectedIndex,
    bool markedForReview = false,
    ValueChanged<int>? onSelect,
  }) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(390, 844),
            textScaler: TextScaler.linear(textScale),
            disableAnimations: true,
          ),
          child: TestAttemptStage(
            examTitle: 'SSC CGL Full Length Mock Test',
            questionNumber: 7,
            totalQuestions: 100,
            timeLabel: '42:18',
            timerBackground: const Color(0xFFE2E8F0),
            timerForeground: const Color(0xFF475569),
            syncing: false,
            syncFailed: false,
            onRetrySync: null,
            onExit: () {},
            topBanners: const [],
            questionText:
                'If the price of an article is increased by 20% and then reduced by 10%, what is the overall percentage change?',
            options: const [
              '8% increase',
              '8% decrease',
              '10% increase',
              'No change',
            ],
            selectedIndex: selectedIndex,
            locked: false,
            markedForReview: markedForReview,
            onSelect: onSelect ?? (_) {},
            onPrevious: () {},
            onClear: selectedIndex == null ? null : () {},
            onMarkReview: () {},
            onSaveNext: () {},
            saveNextLabel: 'Save & next',
            paletteLabel: 'Palette · 29 left',
            onPalette: () {},
            submitLabel: 'Submit test',
            onSubmit: () {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('attempt stage keeps question and actions focused', (tester) async {
    var selected = -1;
    await pumpStage(tester, onSelect: (index) => selected = index);

    expect(find.text('Question 7 of 100'), findsOneWidget);
    expect(find.byKey(const Key('test-attempt-timer')), findsOneWidget);
    expect(find.byKey(const Key('test-attempt-question')), findsOneWidget);
    expect(find.byKey(const Key('test-attempt-save-next')), findsOneWidget);
    expect(find.byKey(const Key('test-attempt-palette')), findsOneWidget);
    expect(find.byKey(const Key('test-attempt-submit')), findsOneWidget);

    await tester.tap(find.byKey(const Key('test-attempt-option-1')));
    await tester.pump();
    expect(selected, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selected and marked states stay explicit without answer semantics', (
    tester,
  ) async {
    await pumpStage(tester, selectedIndex: 1, markedForReview: true);

    expect(find.text('Marked for review'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(find.text('Correct answer'), findsNothing);
    expect(find.text('Your answer'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('attempt stage remains usable at 200 percent text scaling', (
    tester,
  ) async {
    await pumpStage(tester, textScale: 2, selectedIndex: 1);

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('test-attempt-save-next')), findsOneWidget);
    expect(find.byKey(const Key('test-attempt-palette')), findsOneWidget);
    expect(find.byKey(const Key('test-attempt-submit')), findsOneWidget);

    final scrollable = find.byKey(const Key('test-attempt-question-scroll'));
    for (var index = 0; index < 4; index++) {
      await tester.drag(scrollable, const Offset(0, -320));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
