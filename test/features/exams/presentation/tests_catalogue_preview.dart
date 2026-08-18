import 'dart:io';
import 'dart:typed_data';

import 'package:examtree/core/models/exam_model.dart';
import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/exams/presentation/exams_screen.dart';
import 'package:examtree/features/exams/presentation/providers/exam_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var fontsLoaded = false;
  const phoneSize = Size(390, 844);
  final now = DateTime(2026, 8, 18, 12);

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
      'test/features/exams/presentation/previews/Roboto-Regular.ttf',
    );
    await loadFont(
      'MaterialIcons',
      'test/features/exams/presentation/previews/MaterialIcons-Regular.otf',
    );
    fontsLoaded = true;
  }

  Exam exam({
    required String id,
    required String title,
    required String category,
    String status = 'published',
    String difficulty = 'Medium',
  }) {
    return Exam(
      id: id,
      title: title,
      description: '$title preparation paper',
      durationInSeconds: 3600,
      totalQuestions: 100,
      totalMarks: 100,
      maxAttempts: 5,
      negativeMarking: 0.25,
      difficulty: difficulty,
      status: status,
      category: category,
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now,
    );
  }

  Future<void> pumpCatalogue(
    WidgetTester tester, {
    required List<Exam> available,
    required List<Exam> inProgress,
  }) async {
    await tester.runAsync(loadFonts);
    tester.view
      ..physicalSize = phoneSize
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableExamsProvider.overrideWith((ref) async => available),
          inProgressExamsProvider.overrideWith((ref) async => inProgress),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme.copyWith(
            textTheme: AppTheme.lightTheme.textTheme.apply(fontFamily: 'Roboto'),
          ),
          home: const MediaQuery(
            data: MediaQueryData(
              size: phoneSize,
              devicePixelRatio: 1,
              disableAnimations: true,
            ),
            child: ExamsScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('render populated Tests catalogue', (tester) async {
    await pumpCatalogue(
      tester,
      inProgress: [
        exam(
          id: 'active-1',
          title: 'SSC CGL full-length mock',
          category: 'SSC',
        ),
        exam(
          id: 'active-2',
          title: 'Quant sectional speed test',
          category: 'SSC',
        ),
      ],
      available: [
        exam(
          id: 'available-1',
          title: 'Reasoning mixed practice',
          category: 'SSC',
        ),
        exam(
          id: 'available-2',
          title: 'Railway NTPC mock',
          category: 'Railways',
        ),
        exam(
          id: 'available-3',
          title: 'Banking prelims mock',
          category: 'Banking',
          status: 'paid',
          difficulty: 'Hard',
        ),
      ],
    );

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/tests_populated_390x844.png'),
    );
  });

  testWidgets('render lower Tests catalogue', (tester) async {
    await pumpCatalogue(
      tester,
      inProgress: [
        exam(
          id: 'active-1',
          title: 'SSC CGL full-length mock',
          category: 'SSC',
        ),
      ],
      available: [
        exam(
          id: 'available-1',
          title: 'Reasoning mixed practice',
          category: 'SSC',
        ),
        exam(
          id: 'available-2',
          title: 'Railway NTPC mock',
          category: 'Railways',
        ),
        exam(
          id: 'available-3',
          title: 'Banking prelims mock',
          category: 'Banking',
          status: 'paid',
          difficulty: 'Hard',
        ),
      ],
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -480));
    await tester.pump(const Duration(milliseconds: 300));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/tests_lower_390x844.png'),
    );
  });

  testWidgets('render empty Tests catalogue', (tester) async {
    await pumpCatalogue(
      tester,
      inProgress: const [],
      available: const [],
    );

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/tests_empty_390x844.png'),
    );
  });
}
