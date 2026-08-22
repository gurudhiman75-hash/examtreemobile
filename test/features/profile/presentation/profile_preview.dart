import 'dart:io';
import 'dart:typed_data';

import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/auth/presentation/providers/auth_providers.dart';
import 'package:examtree/features/preferences/domain/question_language.dart';
import 'package:examtree/features/preferences/presentation/providers/question_language_providers.dart';
import 'package:examtree/features/profile/domain/performance_analytics.dart';
import 'package:examtree/features/profile/presentation/profile_screen.dart';
import 'package:examtree/features/profile/presentation/providers/analytics_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var fontsLoaded = false;
  const phoneSize = Size(390, 844);
  final now = DateTime(2026, 8, 21, 12);

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
      'test/features/profile/presentation/previews/Roboto-Regular.ttf',
    );
    await loadFont(
      'MaterialIcons',
      'test/features/profile/presentation/previews/MaterialIcons-Regular.otf',
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

  PerformanceAnalytics populatedAnalytics() => PerformanceAnalytics(
        userId: 'student-1',
        totalTestsAttempted: 12,
        averageScore: 76,
        averageAccuracy: 84,
        totalCorrect: 612,
        totalIncorrect: 96,
        totalUnanswered: 42,
        averageTimePerQuestion: 41,
        latestAttemptId: 'attempt-12',
        latestTestName: 'SSC CGL Full Mock 12',
        updatedAt: now,
        scoreTrend: [
          PerformanceTrendPoint(
            attemptId: 'attempt-9',
            testName: 'SSC CGL Full Mock 9',
            percentageScore: 69,
            accuracy: 78,
            completedAt: now.subtract(const Duration(days: 9)),
          ),
          PerformanceTrendPoint(
            attemptId: 'attempt-10',
            testName: 'SSC CGL Full Mock 10',
            percentageScore: 73,
            accuracy: 81,
            completedAt: now.subtract(const Duration(days: 6)),
          ),
          PerformanceTrendPoint(
            attemptId: 'attempt-11',
            testName: 'SSC CGL Full Mock 11',
            percentageScore: 76,
            accuracy: 84,
            completedAt: now.subtract(const Duration(days: 3)),
          ),
          PerformanceTrendPoint(
            attemptId: 'attempt-12',
            testName: 'SSC CGL Full Mock 12',
            percentageScore: 82,
            accuracy: 89,
            completedAt: now,
          ),
        ],
        sectionPerformance: const [
          SectionPerformance(
            name: 'Reasoning',
            correct: 112,
            incorrect: 14,
            unanswered: 4,
            timedQuestions: 126,
            totalTimeSeconds: 4180,
          ),
          SectionPerformance(
            name: 'Quantitative Aptitude',
            correct: 76,
            incorrect: 36,
            unanswered: 12,
            timedQuestions: 112,
            totalTimeSeconds: 5230,
          ),
        ],
      );

  Future<void> configurePhone(WidgetTester tester) async {
    await tester.runAsync(loadFonts);
    tester.view
      ..physicalSize = phoneSize
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget app(PerformanceAnalytics analytics) => ProviderScope(
        overrides: [
          authStateChangesProvider.overrideWith(
            (ref) => Stream<User?>.value(null),
          ),
          performanceAnalyticsProvider.overrideWith((ref) async => analytics),
          questionLanguageProvider.overrideWith(
            (ref) async => QuestionLanguage.english,
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
              appBar: AppBar(title: const Text('Profile')),
              body: const ProfileScreen(),
            ),
          ),
        ),
      );

  testWidgets('render populated Profile initial viewport', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(app(populatedAnalytics()));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/profile_populated_390x844.png'),
    );
  });

  testWidgets('render populated Profile lower viewport', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(app(populatedAnalytics()));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.drag(find.byType(ListView), const Offset(0, -720));
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/profile_lower_390x844.png'),
    );
  });

  testWidgets('render empty Profile performance state', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(app(PerformanceAnalytics.empty('student-1')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/profile_empty_390x844.png'),
    );
  });
}
