import 'package:examtree/core/models/exam_model.dart';
import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/exams/presentation/exams_screen.dart';
import 'package:examtree/features/exams/presentation/providers/exam_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 18, 12);

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
    List<Exam> inProgress = const [],
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
          availableExamsProvider.overrideWith((ref) async => available),
          inProgressExamsProvider.overrideWith((ref) async => inProgress),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              textScaler: TextScaler.linear(textScale),
              disableAnimations: true,
            ),
            child: const ExamsScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('catalogue prioritizes search and compact resume rail', (tester) async {
    await pumpCatalogue(
      tester,
      available: [
        exam(id: 'ssc-1', title: 'SSC CGL Mock 1', category: 'SSC'),
        exam(id: 'rail-1', title: 'Railway NTPC Mock', category: 'Railways'),
      ],
      inProgress: [
        exam(id: 'active-1', title: 'Quant Speed Sectional', category: 'SSC'),
      ],
    );

    expect(find.text('Tests'), findsOneWidget);
    expect(find.byKey(const Key('tests-search')), findsOneWidget);
    expect(find.text('Continue learning'), findsOneWidget);
    expect(find.byKey(const Key('tests-resume-rail')), findsOneWidget);
    expect(find.text('Quant Speed Sectional'), findsOneWidget);
    expect(find.text('Available tests'), findsOneWidget);
  });

  testWidgets('search filters visible catalogue without changing source data', (tester) async {
    await pumpCatalogue(
      tester,
      available: [
        exam(id: 'ssc-1', title: 'SSC CGL Mock 1', category: 'SSC'),
        exam(id: 'rail-1', title: 'Railway NTPC Mock', category: 'Railways'),
      ],
    );

    await tester.enterText(find.byKey(const Key('tests-search')), 'railway');
    await tester.pump();

    expect(find.text('Railway NTPC Mock'), findsOneWidget);
    expect(find.text('SSC CGL Mock 1'), findsNothing);
    expect(find.text('1 of 2 shown.'), findsOneWidget);
    expect(find.byKey(const Key('tests-reset')), findsOneWidget);
  });

  testWidgets('empty catalogue remains truthful', (tester) async {
    await pumpCatalogue(tester, available: const []);

    expect(find.text('No tests available yet'), findsOneWidget);
    expect(find.text('0 available'), findsOneWidget);
    expect(find.text('0 free'), findsOneWidget);
    expect(find.textContaining('popular'), findsNothing);
    expect(find.textContaining('recommended for you'), findsNothing);
  });

  testWidgets('catalogue remains usable at 200 percent text scaling', (tester) async {
    await pumpCatalogue(
      tester,
      available: [
        exam(
          id: 'long-1',
          title: 'SSC Combined Graduate Level Full Length Practice Mock',
          category: 'SSC',
        ),
      ],
      inProgress: [
        exam(
          id: 'active-1',
          title: 'Quantitative Aptitude Full Length Sectional Test',
          category: 'SSC',
        ),
      ],
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('tests-search')), findsOneWidget);
  });
}
