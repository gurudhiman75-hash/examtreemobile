import 'package:examtree/core/models/exam_model.dart';
import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/learn/domain/learning_resource.dart';
import 'package:examtree/features/learn/presentation/learn_screen.dart';
import 'package:examtree/features/learn/presentation/providers/learning_resources_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 8, 21, 10);

  LearningResourceSummary resource({
    required String id,
    required String title,
    required LearningResourceCategory category,
    LearningResourceFormat format = LearningResourceFormat.article,
    String summary = 'Exam-relevant published learning material.',
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
      isGeneral: true,
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

  Future<void> pumpLearn(
    WidgetTester tester, {
    required List<LearningResourceSummary> resources,
    required List<Exam> freeTests,
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
          relevantLearningResourcesProvider.overrideWith(
            (ref) => AsyncValue.data(resources),
          ),
          learnFreeTestsProvider.overrideWith(
            (ref) => AsyncValue.data(freeTests),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              textScaler: TextScaler.linear(textScale),
              disableAnimations: true,
            ),
            child: const Scaffold(
              appBar: AppBar(title: Text('Learn')),
              body: LearnScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('learn prioritizes current affairs and free practice', (tester) async {
    await pumpLearn(
      tester,
      resources: [
        resource(
          id: 'ca-1',
          title: 'Daily current affairs',
          category: LearningResourceCategory.currentAffairs,
        ),
        resource(
          id: 'notes-1',
          title: 'Quant revision notes',
          category: LearningResourceCategory.notes,
          format: LearningResourceFormat.pdf,
        ),
      ],
      freeTests: [exam('test-1', 'SSC CGL free mock')],
    );

    expect(find.text('Learn for your exams'), findsOneWidget);
    expect(find.text('Daily current affairs'), findsOneWidget);
    expect(find.byKey(const Key('learn-current-affairs')), findsOneWidget);
    expect(find.text('Free practice'), findsOneWidget);
    expect(find.byKey(const Key('learn-free-practice')), findsOneWidget);
    expect(find.text('SSC CGL free mock'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -620));
    await tester.pump();
    expect(find.text('Notes & formula sheets'), findsOneWidget);
    expect(find.text('Quant revision notes'), findsOneWidget);
  });

  testWidgets('empty learn state stays truthful', (tester) async {
    await pumpLearn(tester, resources: const [], freeTests: const []);

    expect(
      find.text('No free learning resources are published yet.'),
      findsOneWidget,
    );
    expect(find.text('0'), findsNWidgets(3));
    expect(find.textContaining('popular'), findsNothing);
    expect(find.textContaining('trending'), findsNothing);
  });

  testWidgets('learn remains usable at 200 percent text scaling', (tester) async {
    await pumpLearn(
      tester,
      resources: [
        resource(
          id: 'ca-long',
          title: 'Daily national and international current affairs revision digest',
          category: LearningResourceCategory.currentAffairs,
          summary:
              'A longer published summary that checks the featured resource card under large accessibility text.',
        ),
        resource(
          id: 'formula-long',
          title: 'Quantitative aptitude formulas and shortcuts revision sheet',
          category: LearningResourceCategory.formulaSheet,
          format: LearningResourceFormat.pdf,
        ),
      ],
      freeTests: [
        exam('test-long', 'SSC Combined Graduate Level full length practice mock'),
      ],
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Learn for your exams'), findsOneWidget);
    expect(find.byKey(const Key('learn-current-affairs')), findsOneWidget);
  });
}
