import 'dart:io';
import 'dart:typed_data';

import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/exam_day/domain/exam_day_mode.dart';
import 'package:examtree/features/exam_day/presentation/exam_day_screen.dart';
import 'package:examtree/features/exam_day/presentation/providers/exam_day_providers.dart';
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
      'test/features/exam_day/presentation/previews/Roboto-Regular.ttf',
    );
    await loadFont(
      'MaterialIcons',
      'test/features/exam_day/presentation/previews/MaterialIcons-Regular.otf',
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
          const ExamDayChecklistItem(
            id: 'custom_ticket',
            label: 'Bus ticket saved offline',
            completed: true,
            isCustom: true,
          ),
        ],
        updatedAt: now,
      );

  Future<void> configurePhone(WidgetTester tester) async {
    await tester.runAsync(loadFonts);
    tester.view
      ..physicalSize = phoneSize
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget app(ExamDayTarget? target) => ProviderScope(
        overrides: [
          examDayClockProvider.overrideWithValue(() => now),
          examDayTargetProvider.overrideWith((ref) async => target),
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
            child: const ExamDayScreen(),
          ),
        ),
      );

  testWidgets('render populated Exam-Day initial viewport', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(app(target()));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/exam_day_populated_390x844.png'),
    );
  });

  testWidgets('render populated Exam-Day checklist viewport', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(app(target()));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.drag(find.byType(ListView), const Offset(0, -760));
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/exam_day_lower_390x844.png'),
    );
  });

  testWidgets('render empty Exam-Day state', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(app(null));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/exam_day_empty_390x844.png'),
    );
  });
}
