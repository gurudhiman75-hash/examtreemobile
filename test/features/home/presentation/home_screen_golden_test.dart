import 'dart:io';
import 'dart:typed_data';

import 'package:examtree/core/models/analytics_model.dart';
import 'package:examtree/core/models/exam_model.dart';
import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/auth/presentation/providers/auth_providers.dart';
import 'package:examtree/features/exams/presentation/providers/exam_providers.dart';
import 'package:examtree/features/home/presentation/home_screen.dart';
import 'package:examtree/features/profile/presentation/providers/analytics_providers.dart';
import 'package:examtree/features/results/presentation/providers/result_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var goldenFontLoaded = false;

  Future<void> loadGoldenFont() async {
    if (goldenFontLoaded) return;
    final bytes = await File(
      'test/features/home/presentation/goldens/Roboto-Regular.ttf',
    ).readAsBytes();
    final loader = FontLoader('Roboto')
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
    goldenFontLoaded = true;
  }

  const phoneSize = Size(390, 844);
  final fixedNow = DateTime(2026, 7, 30, 9, 30);

  Exam exam({
    required String id,
    required String title,
    String category = 'SSC',
    String status = 'published',
    String difficulty = 'Medium',
    DateTime? updatedAt,
  }) {
    final updated = updatedAt ?? fixedNow;
    return Exam(
      id: id,
      title: title,
      description: '$title description',
      durationInSeconds: 3600,
      totalQuestions: 100,
      totalMarks: 100,
      maxAttempts: 10,
      negativeMarking: 0.25,
      difficulty: difficulty,
      status: status,
      category: category,
      createdAt: updated.subtract(const Duration(days: 2)),
      updatedAt: updated,
    );
  }

  Result result() {
    return Result(
      id: 'result-1',
      attemptId: 'attempt-1',
      userId: 'student-1',
      examId: 'completed-1',
      score: 76,
      maxScore: 100,
      accuracy: 84,
      correctCount: 76,
      incorrectCount: 14,
      skippedCount: 10,
      calculatedAt: fixedNow.subtract(const Duration(hours: 4)),
      testName: 'SSC CGL diagnostic mock',
      category: 'SSC',
      percentageScore: 76,
      rawScore: 76,
      totalQuestions: 100,
    );
  }

  Analytics analytics({
    int tests = 12,
    double score = 76,
    double accuracy = 84,
    List<String> weakestTopics = const ['Time and Work'],
  }) {
    return Analytics(
      id: 'analytics-1',
      userId: 'student-1',
      totalTestsAttempted: tests,
      averageScore: score,
      averageAccuracy: accuracy,
      weakestTopics: weakestTopics,
      averageTimePerQuestion: 42,
      updatedAt: fixedNow,
    );
  }

  Future<void> pumpHome(
    WidgetTester tester, {
    required List<Exam> active,
    required List<Exam> available,
    required List<Result> results,
    required Analytics analyticsValue,
  }) async {
    await tester.runAsync(loadGoldenFont);

    tester.view
      ..physicalSize = phoneSize
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateChangesProvider.overrideWith(
            (ref) => Stream<User?>.value(null),
          ),
          userAnalyticsProvider.overrideWith((ref) async => analyticsValue),
          inProgressExamsProvider.overrideWith((ref) async => active),
          availableExamsProvider.overrideWith((ref) async => available),
          userResultsProvider.overrideWith((ref) async => results),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme.copyWith(
            textTheme: AppTheme.lightTheme.textTheme.apply(
              fontFamily: 'Roboto',
            ),
          ),
          home: MediaQuery(
            data: const MediaQueryData(
              size: phoneSize,
              devicePixelRatio: 1,
              disableAnimations: true,
            ),
            child: HomeScreen(now: () => fixedNow),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('populated Home initial viewport matches its phone baseline', (
    tester,
  ) async {
    await pumpHome(
      tester,
      active: [
        exam(id: 'active-1', title: 'SSC CGL full-length mock'),
        exam(id: 'active-2', title: 'Quant sectional speed test'),
      ],
      available: [
        exam(id: 'available-1', title: 'Reasoning mixed practice'),
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
      results: [result()],
      analyticsValue: analytics(),
    );

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/home_populated_initial_390x844.png'),
    );
  });

  testWidgets('populated Home lower viewport matches its phone baseline', (
    tester,
  ) async {
    await pumpHome(
      tester,
      active: [
        exam(id: 'active-1', title: 'SSC CGL full-length mock'),
        exam(id: 'active-2', title: 'Quant sectional speed test'),
      ],
      available: [
        exam(id: 'available-1', title: 'Reasoning mixed practice'),
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
      results: [result()],
      analyticsValue: analytics(),
    );

    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -780),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/home_populated_lower_390x844.png'),
    );
  });

  testWidgets('empty Home matches its truthful phone baseline', (tester) async {
    await pumpHome(
      tester,
      active: const [],
      available: const [],
      results: const [],
      analyticsValue: analytics(
        tests: 0,
        score: 0,
        accuracy: 0,
        weakestTopics: const [],
      ),
    );

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/home_empty_390x844.png'),
    );
  });
}
