import 'dart:io';

import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/exam_preferences/domain/exam_preferences.dart';
import 'package:examtree/features/exam_preferences/presentation/my_exams_screen.dart';
import 'package:examtree/features/exam_preferences/presentation/providers/exam_preferences_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var fontsLoaded = false;
  const phoneSize = Size(390, 844);

  const ssc = ExamFamilyTarget(
    id: 'ssc',
    code: 'SSC',
    name: 'SSC',
    description: 'Staff Selection Commission exams',
    examCount: 3,
  );
  const banking = ExamFamilyTarget(
    id: 'banking',
    code: 'BANK',
    name: 'Banking',
    description: 'Bank recruitment and officer exams',
    examCount: 2,
  );

  const exams = [
    SelectableExamTarget(
      id: 'ssc-cgl',
      familyId: 'ssc',
      code: 'SSC_CGL',
      name: 'SSC CGL',
      description: 'Combined Graduate Level',
      currentVersionId: 'v1',
      languages: [
        ExamTargetLanguage(
          code: 'en',
          name: 'English',
          nativeName: 'English',
          isPrimary: true,
        ),
        ExamTargetLanguage(
          code: 'hi',
          name: 'Hindi',
          nativeName: 'हिन्दी',
          isPrimary: false,
        ),
      ],
      liveTestCount: 42,
    ),
    SelectableExamTarget(
      id: 'ssc-chsl',
      familyId: 'ssc',
      code: 'SSC_CHSL',
      name: 'SSC CHSL',
      description: 'Combined Higher Secondary Level',
      currentVersionId: 'v2',
      languages: [
        ExamTargetLanguage(
          code: 'en',
          name: 'English',
          nativeName: 'English',
          isPrimary: true,
        ),
      ],
      liveTestCount: 18,
    ),
    SelectableExamTarget(
      id: 'ssc-mts',
      familyId: 'ssc',
      code: 'SSC_MTS',
      name: 'SSC MTS',
      description: 'Multi-Tasking Staff examination',
      currentVersionId: 'v3',
      languages: [],
      liveTestCount: 0,
    ),
    SelectableExamTarget(
      id: 'ibps-po',
      familyId: 'banking',
      code: 'IBPS_PO',
      name: 'IBPS PO',
      description: 'Probationary Officer recruitment',
      currentVersionId: 'v4',
      languages: [
        ExamTargetLanguage(
          code: 'en',
          name: 'English',
          nativeName: 'English',
          isPrimary: true,
        ),
      ],
      liveTestCount: 12,
    ),
    SelectableExamTarget(
      id: 'sbi-clerk',
      familyId: 'banking',
      code: 'SBI_CLERK',
      name: 'SBI Clerk',
      description: 'Junior Associate recruitment',
      currentVersionId: 'v5',
      languages: [],
      liveTestCount: 0,
    ),
  ];

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
      'test/features/exam_preferences/previews/Roboto-Regular.ttf',
    );
    await loadFont(
      'MaterialIcons',
      'test/features/exam_preferences/previews/MaterialIcons-Regular.otf',
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

  Widget app() {
    final snapshot = ExamPreferenceSnapshot(
      catalogue: const ExamTargetCatalogue(
        families: [ssc, banking],
        exams: exams,
        maxSelectedExams: 4,
      ),
      preferences: const LearnerExamPreferences(
        selectedExamIds: ['ssc-cgl'],
        maxSelectedExams: 4,
      ),
    );

    return ProviderScope(
      overrides: [
        examPreferenceSnapshotProvider.overrideWith((ref) async => snapshot),
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
          child: MyExamsScreen(),
        ),
      ),
    );
  }

  testWidgets('render My Exams initial viewport', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(app());
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/my_exams_390x844.png'),
    );
  });

  testWidgets('render My Exams lower catalogue', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(app());
    await tester.pump(const Duration(milliseconds: 250));
    await tester.drag(
      find.byKey(const Key('my-exams-scroll')),
      const Offset(0, -780),
    );
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/my_exams_lower_390x844.png'),
    );
  });
}
