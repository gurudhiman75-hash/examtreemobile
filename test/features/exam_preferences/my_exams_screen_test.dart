import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/exam_preferences/domain/exam_preferences.dart';
import 'package:examtree/features/exam_preferences/presentation/my_exams_screen.dart';
import 'package:examtree/features/exam_preferences/presentation/providers/exam_preferences_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const family = ExamFamilyTarget(
    id: 'family-1',
    code: 'SSC',
    name: 'SSC',
    description: 'Staff Selection Commission exams',
    examCount: 2,
  );
  const liveExam = SelectableExamTarget(
    id: 'exam-1',
    familyId: 'family-1',
    code: 'SSC_CGL',
    name: 'SSC CGL',
    description: 'Combined Graduate Level',
    currentVersionId: 'version-1',
    languages: [
      ExamTargetLanguage(
        code: 'en',
        name: 'English',
        nativeName: 'English',
        isPrimary: true,
      ),
    ],
    liveTestCount: 4,
  );
  const comingExam = SelectableExamTarget(
    id: 'exam-2',
    familyId: 'family-1',
    code: 'SSC_CHSL',
    name: 'SSC CHSL',
    description: 'Combined Higher Secondary Level',
    currentVersionId: 'version-2',
    languages: [],
    liveTestCount: 0,
  );

  Widget app({double textScale = 1, int maxSelected = 1}) {
    final snapshot = ExamPreferenceSnapshot(
      catalogue: ExamTargetCatalogue(
        families: const [family],
        exams: const [liveExam, comingExam],
        maxSelectedExams: maxSelected,
      ),
      preferences: LearnerExamPreferences(
        selectedExamIds: const [],
        maxSelectedExams: maxSelected,
      ),
    );
    return ProviderScope(
      overrides: [
        examPreferenceSnapshotProvider.overrideWith((ref) async => snapshot),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(390, 844),
            textScaler: TextScaler.linear(textScale),
          ),
          child: const MyExamsScreen(),
        ),
      ),
    );
  }

  testWidgets('groups canonical exams and communicates content availability', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Choose what you are preparing for'), findsOneWidget);
    expect(find.text('SSC'), findsOneWidget);
    expect(find.text('SSC CGL'), findsOneWidget);
    expect(find.text('4 live tests'), findsOneWidget);
    expect(find.text('SSC CHSL'), findsOneWidget);
    expect(find.text('Tests coming later'), findsOneWidget);
    expect(find.byKey(const Key('my-exams-save')), findsOneWidget);
  });

  testWidgets('selection cap is enforced before save', (tester) async {
    await tester.pumpWidget(app(maxSelected: 1));
    await tester.pumpAndSettle();

    final first = find.byKey(const Key('my-exams-choice-exam-1'));
    await tester.ensureVisible(first);
    await tester.pump();
    await tester.tap(first);
    await tester.pump();
    expect(find.text('Save 1 exam'), findsOneWidget);

    final second = find.byKey(const Key('my-exams-choice-exam-2'));
    await tester.ensureVisible(second);
    await tester.pump();
    await tester.tap(second);
    await tester.pump();
    expect(find.text('Choose up to 1 exams.'), findsOneWidget);
  });

  testWidgets('catalogue stays usable at 200 percent text scale', (tester) async {
    await tester.pumpWidget(app(textScale: 2, maxSelected: 12));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final save = find.byKey(const Key('my-exams-save'));
    await tester.ensureVisible(save);
    expect(save, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
