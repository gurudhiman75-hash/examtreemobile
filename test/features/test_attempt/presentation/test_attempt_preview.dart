import 'dart:io';

import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/test_attempt/presentation/widgets/test_attempt_stage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var fontsLoaded = false;
  const phoneSize = Size(390, 844);

  Future<void> loadFont(String family, String path) async {
    final bytes = await File(path).readAsBytes();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  }

  Future<void> loadFonts() async {
    if (fontsLoaded) return;
    await loadFont(
      'Roboto',
      'test/features/test_attempt/presentation/attempt_previews/Roboto-Regular.ttf',
    );
    await loadFont(
      'MaterialIcons',
      'test/features/test_attempt/presentation/attempt_previews/MaterialIcons-Regular.otf',
    );
    fontsLoaded = true;
  }

  ThemeData previewTheme() {
    final base = AppTheme.lightTheme;
    final textTheme = base.textTheme.apply(fontFamily: 'Roboto');
    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Future<void> configurePhone(WidgetTester tester) async {
    await tester.runAsync(loadFonts);
    tester.view
      ..physicalSize = phoneSize
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget app({int? selectedIndex, bool marked = false}) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: previewTheme(),
        home: const MediaQuery(
          data: MediaQueryData(
            size: phoneSize,
            devicePixelRatio: 1,
            disableAnimations: true,
          ),
          child: SizedBox.shrink(),
        ),
        builder: (context, child) => MediaQuery(
          data: const MediaQueryData(
            size: phoneSize,
            devicePixelRatio: 1,
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
            markedForReview: marked,
            onSelect: (_) {},
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
      );

  testWidgets('render active attempt question', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(app());
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byKey(const Key('test-attempt-stage')),
      matchesGoldenFile('attempt_previews/attempt_question_390x844.png'),
    );
  });

  testWidgets('render selected and marked attempt question', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(app(selectedIndex: 1, marked: true));
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byKey(const Key('test-attempt-stage')),
      matchesGoldenFile('attempt_previews/attempt_selected_390x844.png'),
    );
  });
}
