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
  }) {
    return Exam(
      id: id,
      title: title,
      description: title + ' preparation paper',
      durationInSeconds: 3600,
      totalQuestions: 100,
      totalMarks: 100,
      maxAttempts: 5,
      negativeMarking: 0.25,
      difficulty: 'Medium',
      status: status,
      category: category,
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now,
    );
  }

  Future<void> pumpCategories(
    WidgetTester tester, {
    required List<Exam> available,
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
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(
                size: const Size(390, 844),
                textScaler: TextScaler.linear(textScale),
                disableAnimations: true,
              ),
              child: const ExamsScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('exams tab presents master categories before individual exams', (tester) async {
    await pumpCategories(
      tester,
      available: [
        exam(id: 'ssc-1', title: 'SSC CGL', category: 'SSC CGL'),
        exam(id: 'rail-1', title: 'RRB NTPC', category: 'Railways'),
        exam(id: 'bank-1', title: 'IBPS PO', category: 'Banking'),
      ],
    );

    expect(find.text('Choose your exam path'), findsOneWidget);
    expect(find.byKey(const Key('exam-category-catalogue')), findsOneWidget);
    expect(find.byKey(const Key('exam-category-search')), findsOneWidget);
    expect(find.text('SSC'), findsOneWidget);
    expect(find.text('Railway'), findsOneWidget);
    expect(find.text('Banking'), findsOneWidget);
    expect(find.text('SSC CGL'), findsNothing);
  });

  testWidgets('category search filters only master categories', (tester) async {
    await pumpCategories(
      tester,
      available: [
        exam(id: 'ssc-1', title: 'SSC CGL', category: 'SSC'),
        exam(id: 'rail-1', title: 'RRB NTPC', category: 'Railways'),
      ],
    );

    await tester.enterText(
      find.byKey(const Key('exam-category-search')),
      'rail',
    );
    await tester.pump();

    expect(find.text('Railway'), findsOneWidget);
    expect(find.text('SSC'), findsNothing);
  });

  testWidgets('empty category catalogue remains truthful', (tester) async {
    await pumpCategories(tester, available: const []);

    expect(find.text('No exam categories are published yet.'), findsOneWidget);
    expect(find.textContaining('popular'), findsNothing);
    expect(find.textContaining('recommended for you'), findsNothing);
  });

  testWidgets('category catalogue remains usable at 200 percent text scaling', (tester) async {
    await pumpCategories(
      tester,
      available: [
        exam(id: 'ssc-1', title: 'SSC Combined Graduate Level', category: 'SSC'),
        exam(id: 'punjab-1', title: 'PSSSB Clerk', category: 'Punjab'),
      ],
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('exam-category-search')), findsOneWidget);
  });

  testWidgets('family mapping keeps exam names out of master category level', (tester) async {
    expect(
      familyForExam(
        exam(id: 'cgl', title: 'SSC CGL', category: 'SSC CGL'),
      ),
      ExamFamily.ssc,
    );
    expect(
      familyForExam(
        exam(id: 'psssb', title: 'PSSSB Clerk', category: 'Punjab Government'),
      ),
      ExamFamily.punjab,
    );
    expect(
      familyForExam(
        exam(id: 'lic', title: 'LIC AAO', category: 'Insurance'),
      ),
      ExamFamily.insurance,
    );
  });
}
