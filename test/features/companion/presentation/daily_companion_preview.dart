import 'dart:io';
import 'dart:typed_data';

import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/companion/domain/daily_companion.dart';
import 'package:examtree/features/companion/presentation/daily_companion_screen.dart';
import 'package:examtree/features/companion/presentation/providers/daily_companion_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var fontsLoaded = false;
  const phoneSize = Size(390, 844);
  final now = DateTime(2026, 8, 22, 8, 30);

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
      'test/features/companion/presentation/previews/Roboto-Regular.ttf',
    );
    await loadFont(
      'MaterialIcons',
      'test/features/companion/presentation/previews/MaterialIcons-Regular.otf',
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

  RevisionItem item({
    required String id,
    required String question,
    required DateTime dueAt,
    Set<RevisionReason> reasons = const {RevisionReason.incorrect},
  }) => RevisionItem(
        id: id,
        sourceAttemptId: 'attempt-1',
        testId: 'test-1',
        testName: 'SSC CGL Full Mock 12',
        section: 'Quantitative Aptitude',
        questionText: question,
        options: const ['A', 'B', 'C', 'D'],
        selectedIndex: 1,
        correctIndex: 0,
        explanation: 'Use the canonical explanation stored with the result.',
        reasons: reasons,
        timeTakenSeconds: 78,
        dueAt: dueAt,
        stage: 0,
        createdAt: now.subtract(const Duration(days: 1)),
      );

  DailyCompanionSnapshot populated() => DailyCompanionSnapshot(
        settings: const StudyCompanionSettings(
          dailyQuestionGoal: 10,
          reminderEnabled: true,
          reminderHour: 19,
          reminderMinute: 30,
        ),
        items: [
          item(
            id: 'due-1',
            question:
                'A train covers a fixed distance at one speed and returns at another. Find the average speed.',
            dueAt: now.subtract(const Duration(minutes: 10)),
            reasons: const {
              RevisionReason.incorrect,
              RevisionReason.slow,
            },
          ),
          item(
            id: 'due-2',
            question:
                'Which conclusion follows from the given statements about the three groups?',
            dueAt: now.subtract(const Duration(minutes: 2)),
            reasons: const {RevisionReason.flagged},
          ),
          item(
            id: 'later-1',
            question:
                'Find the value of the expression after applying the standard algebraic identity.',
            dueAt: now.add(const Duration(days: 1)),
          ),
        ],
        completedToday: 4,
      );

  Future<void> configurePhone(WidgetTester tester) async {
    await tester.runAsync(loadFonts);
    tester.view
      ..physicalSize = phoneSize
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget app(DailyCompanionSnapshot snapshot) => ProviderScope(
        overrides: [
          dailyCompanionClockProvider.overrideWithValue(() => now),
          dailyCompanionSnapshotProvider.overrideWith((ref) async => snapshot),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: previewTheme(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: phoneSize,
              devicePixelRatio: 1,
              disableAnimations: true,
            ),
            child: const DailyCompanionScreen(),
          ),
        ),
      );

  testWidgets('render populated Daily Companion initial viewport', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(app(populated()));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/daily_populated_390x844.png'),
    );
  });

  testWidgets('render populated Daily Companion lower viewport', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(app(populated()));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.drag(find.byType(ListView), const Offset(0, -760));
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/daily_lower_390x844.png'),
    );
  });

  testWidgets('render empty Daily Companion state', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(
      app(
        const DailyCompanionSnapshot(
          settings: StudyCompanionSettings(dailyQuestionGoal: 8),
          items: [],
          completedToday: 2,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/daily_empty_390x844.png'),
    );
  });
}
