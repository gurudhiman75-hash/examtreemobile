import 'dart:io';

import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/companion/domain/daily_companion.dart';
import 'package:examtree/features/companion/presentation/providers/daily_companion_providers.dart';
import 'package:examtree/features/companion/presentation/quick_revision_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      'test/features/companion/presentation/quick_revision_previews/Roboto-Regular.ttf',
    );
    await loadFont(
      'MaterialIcons',
      'test/features/companion/presentation/quick_revision_previews/MaterialIcons-Regular.otf',
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

  RevisionItem item() => RevisionItem(
        id: 'revision-1',
        sourceAttemptId: 'attempt-1',
        testId: 'test-1',
        testName: 'SSC CGL Full Mock 12',
        section: 'Quantitative Aptitude',
        questionText:
            'A train covers the same distance at 60 km/h and 40 km/h. What is the average speed for the complete journey?',
        options: const ['48 km/h', '50 km/h', '52 km/h', '45 km/h'],
        selectedIndex: 1,
        correctIndex: 0,
        explanation:
            'For equal distances, average speed is 2ab ÷ (a + b). So 2 × 60 × 40 ÷ 100 = 48 km/h.',
        reasons: const {RevisionReason.incorrect, RevisionReason.slow},
        timeTakenSeconds: 95,
        dueAt: DateTime(2020, 1, 1),
        stage: 0,
        createdAt: DateTime(2020, 1, 1),
      );

  Future<void> configurePhone(WidgetTester tester) async {
    await tester.runAsync(loadFonts);
    tester.view
      ..physicalSize = phoneSize
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget app(List<RevisionItem> items) => ProviderScope(
        overrides: [
          dailyCompanionSnapshotProvider.overrideWith(
            (ref) async => DailyCompanionSnapshot(
              settings: const StudyCompanionSettings(),
              items: items,
              completedToday: 0,
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: previewTheme(),
          home: const MediaQuery(
            data: MediaQueryData(
              size: phoneSize,
              devicePixelRatio: 1,
              disableAnimations: true,
            ),
            child: QuickRevisionScreen(minutes: 5),
          ),
        ),
      );

  testWidgets('render Quick Revision question', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(app([item()]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('quick_revision_previews/quick_revision_question_390x844.png'),
    );
  });

  testWidgets('render Quick Revision revealed lower state', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(app([item()]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final scrollable = find.descendant(
      of: find.byKey(const Key('quick-revision-scroll')),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('quick-revision-show-answer')),
      220,
      scrollable: scrollable,
    );
    await tester.tap(find.byKey(const Key('quick-revision-show-answer')));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.drag(scrollable, const Offset(0, -380));
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('quick_revision_previews/quick_revision_revealed_390x844.png'),
    );
  });

  testWidgets('render Quick Revision empty state', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(app(const []));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('quick_revision_previews/quick_revision_empty_390x844.png'),
    );
  });
}
