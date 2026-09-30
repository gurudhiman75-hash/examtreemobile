import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/current_affairs/presentation/current_affairs_screen.dart';
import 'package:examtree/features/learn/domain/learning_resource.dart';
import 'package:examtree/features/learn/presentation/providers/learning_resources_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 9, 30, 8, 30);

  LearningResourceSummary resource({
    required String id,
    required String title,
    required LearningResourceCategory category,
    LearningResourceFormat format = LearningResourceFormat.article,
  }) {
    return LearningResourceSummary(
      id: id,
      publicCode: id.toUpperCase(),
      category: category,
      format: format,
      title: title,
      summary: 'Published exam-relevant update for revision.',
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

  Future<void> pumpScreen(
    WidgetTester tester, {
    required List<LearningResourceSummary> resources,
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
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              textScaler: TextScaler.linear(textScale),
              disableAnimations: true,
            ),
            child: const Scaffold(body: CurrentAffairsScreen()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('shows only current affairs and filters published formats', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      resources: [
        resource(
          id: 'ca-article',
          title: 'Daily current affairs article',
          category: LearningResourceCategory.currentAffairs,
        ),
        resource(
          id: 'ca-pdf',
          title: 'Monthly current affairs PDF',
          category: LearningResourceCategory.currentAffairs,
          format: LearningResourceFormat.pdf,
        ),
        resource(
          id: 'note',
          title: 'Polity revision note',
          category: LearningResourceCategory.notes,
        ),
      ],
    );

    expect(find.byKey(const Key('current-affairs-hero')), findsOneWidget);
    expect(find.text('Daily current affairs article'), findsOneWidget);
    expect(find.text('Monthly current affairs PDF'), findsOneWidget);
    expect(find.text('Polity revision note'), findsNothing);
    expect(find.text('2 updates'), findsOneWidget);
    expect(find.text('1 article'), findsOneWidget);
    expect(find.text('1 PDF'), findsOneWidget);

    await tester.tap(find.byKey(const Key('current-affairs-filter-pdfs')));
    await tester.pump();

    expect(find.text('Daily current affairs article'), findsNothing);
    expect(find.text('Monthly current affairs PDF'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('truthfully renders an empty published feed', (tester) async {
    await pumpScreen(tester, resources: const []);

    expect(find.byKey(const Key('current-affairs-empty')), findsOneWidget);
    expect(find.text('No current affairs are published yet.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('remains usable at 200 percent text scaling', (tester) async {
    await pumpScreen(
      tester,
      textScale: 2,
      resources: [
        resource(
          id: 'ca-long',
          title:
              'Daily national and international current affairs revision digest',
          category: LearningResourceCategory.currentAffairs,
        ),
      ],
    );

    expect(find.byKey(const Key('current-affairs-hero')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(
      find.byKey(const Key('current-affairs-scroll')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Daily national'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
