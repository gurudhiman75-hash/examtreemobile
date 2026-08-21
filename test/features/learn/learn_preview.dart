import 'dart:io';
import 'dart:typed_data';

import 'package:examtree/core/models/exam_model.dart';
import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/learn/domain/learning_resource.dart';
import 'package:examtree/features/learn/presentation/learn_screen.dart';
import 'package:examtree/features/learn/presentation/learning_resource_detail_screen.dart';
import 'package:examtree/features/learn/presentation/providers/learning_resources_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var fontsLoaded = false;
  const phoneSize = Size(390, 844);
  final now = DateTime.utc(2026, 8, 21, 10);

  Future<void> loadFont(String family, String path) async {
    final bytes = await File(path).readAsBytes();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  }

  Future<void> loadFonts() async {
    if (fontsLoaded) return;
    await loadFont('Roboto', 'test/features/learn/previews/Roboto-Regular.ttf');
    await loadFont(
      'MaterialIcons',
      'test/features/learn/previews/MaterialIcons-Regular.otf',
    );
    fontsLoaded = true;
  }

  ThemeData previewTheme() {
    final base = AppTheme.lightTheme;
    final textTheme = base.textTheme.apply(fontFamily: 'Roboto');
    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(labelStyle: textTheme.labelMedium),
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

  LearningResourceSummary resource({
    required String id,
    required String title,
    required LearningResourceCategory category,
    LearningResourceFormat format = LearningResourceFormat.article,
    required String summary,
    bool general = true,
  }) {
    return LearningResourceSummary(
      id: id,
      publicCode: id.toUpperCase(),
      category: category,
      format: format,
      title: title,
      summary: summary,
      languageCode: 'en',
      contentDate: now,
      contentUrl: null,
      hasInlineContent: true,
      publishedAt: now,
      expiresAt: null,
      isGeneral: general,
      exams: const [],
    );
  }

  Exam exam(String id, String title) => Exam(
        id: id,
        title: title,
        description: '$title practice paper',
        durationInSeconds: 3600,
        totalQuestions: 100,
        totalMarks: 200,
        maxAttempts: 5,
        negativeMarking: 0.5,
        difficulty: 'Medium',
        status: 'published',
        category: 'SSC',
        createdAt: now,
        updatedAt: now,
      );

  final populatedResources = [
    resource(
      id: 'ca-1',
      title: 'Daily current affairs: 21 August',
      category: LearningResourceCategory.currentAffairs,
      summary:
          'Key national, economic and international developments selected for competitive exams.',
    ),
    resource(
      id: 'ca-2',
      title: 'Economy and banking weekly recap',
      category: LearningResourceCategory.currentAffairs,
      summary: 'A concise revision set covering the week’s important economy updates.',
    ),
    resource(
      id: 'notes-1',
      title: 'Quantitative aptitude revision notes',
      category: LearningResourceCategory.notes,
      format: LearningResourceFormat.pdf,
      summary: 'Core concepts and shortcuts for arithmetic revision.',
    ),
    resource(
      id: 'formula-1',
      title: 'Mensuration formula sheet',
      category: LearningResourceCategory.formulaSheet,
      format: LearningResourceFormat.pdf,
      summary: 'High-frequency 2D and 3D formulas for quick revision.',
    ),
  ];

  final freeTests = [
    exam('test-1', 'SSC CGL free full mock'),
    exam('test-2', 'Reasoning mixed practice'),
  ];

  Future<void> pumpLearn(
    WidgetTester tester, {
    required List<LearningResourceSummary> resources,
    required List<Exam> tests,
  }) async {
    await configurePhone(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          relevantLearningResourcesProvider.overrideWith(
            (ref) => AsyncValue.data(resources),
          ),
          learnFreeTestsProvider.overrideWith(
            (ref) => AsyncValue.data(tests),
          ),
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
            child: Scaffold(
              appBar: AppBar(title: const Text('Learn')),
              body: const LearnScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  Future<void> pumpDetail(WidgetTester tester) async {
    await configurePhone(tester);
    final summary = populatedResources.first;
    final detail = LearningResourceDetail(
      summary: summary,
      bodyMarkdown:
          '## Economy\n\nThe policy rate remained unchanged. Focus on the implication for inflation and borrowing costs.\n\n## National\n\nRevise the key appointments and schemes announced this week.',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          learningResourceDetailProvider.overrideWith(
            (ref, id) async => detail,
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
            child: LearningResourceDetailScreen(resourceId: 'ca-1'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('render populated Learn V3', (tester) async {
    await pumpLearn(
      tester,
      resources: populatedResources,
      tests: freeTests,
    );
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/learn_populated_390x844.png'),
    );
  });

  testWidgets('render lower Learn V3', (tester) async {
    await pumpLearn(
      tester,
      resources: populatedResources,
      tests: freeTests,
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/learn_lower_390x844.png'),
    );
  });

  testWidgets('render empty Learn V3', (tester) async {
    await pumpLearn(tester, resources: const [], tests: const []);
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/learn_empty_390x844.png'),
    );
  });

  testWidgets('render refreshed learning resource detail', (tester) async {
    await pumpDetail(tester);
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/learn_detail_390x844.png'),
    );
  });
}
