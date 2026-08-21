import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/learn/domain/learning_resource.dart';
import 'package:examtree/features/learn/presentation/learning_resource_detail_screen.dart';
import 'package:examtree/features/learn/presentation/providers/learning_resources_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final detail = LearningResourceDetail(
    summary: LearningResourceSummary(
      id: 'resource-1',
      publicCode: 'CA_DAILY_001',
      category: LearningResourceCategory.currentAffairs,
      format: LearningResourceFormat.article,
      title: 'Daily current affairs',
      summary: 'Important exam-relevant developments.',
      languageCode: 'en',
      contentDate: DateTime.utc(2026, 8, 21),
      contentUrl: null,
      hasInlineContent: true,
      publishedAt: DateTime.utc(2026, 8, 21, 4),
      expiresAt: null,
      isGeneral: true,
      exams: const [],
    ),
    bodyMarkdown: '## Economy\n\nThe policy rate remained unchanged.',
  );

  testWidgets('renders published article content without placeholder material', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          learningResourceDetailProvider.overrideWith(
            (ref, id) async => detail,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LearningResourceDetailScreen(
            resourceId: 'resource-1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daily current affairs'), findsOneWidget);
    expect(find.text('Current affairs'), findsOneWidget);
    expect(find.text('All exams'), findsOneWidget);
    expect(find.text('Economy'), findsOneWidget);
    expect(find.text('The policy rate remained unchanged.'), findsOneWidget);
    expect(find.textContaining('placeholder'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stays usable at 200 percent text scale', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          learningResourceDetailProvider.overrideWith(
            (ref, id) async => detail,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              textScaler: TextScaler.linear(2),
            ),
            child: const LearningResourceDetailScreen(
              resourceId: 'resource-1',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daily current affairs'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
