import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/shared/widgets/app_visual_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('page header remains usable at 320 px and 200% text', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(320, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const MediaQuery(
          data: MediaQueryData(
            size: Size(320, 800),
            devicePixelRatio: 1,
            textScaler: TextScaler.linear(2),
          ),
          child: Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: AppPageHeader(
                  eyebrow: 'TEST LIBRARY',
                  title: 'Find your next test',
                  subtitle:
                      'Search by exam or subject and continue saved attempts.',
                  leading: AppHeaderIcon(
                    icon: Icons.assignment_outlined,
                  ),
                  trailing: IconButton(
                    onPressed: null,
                    icon: Icon(Icons.tune_rounded),
                  ),
                  metrics: [
                    AppMetricData(value: '24', label: 'Available'),
                    AppMetricData(value: '18', label: 'Free'),
                    AppMetricData(value: '2', label: 'In progress'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Find your next test'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('In progress'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('metric strip exposes complete semantic labels', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: AppMetricStrip(
              metrics: [
                AppMetricData(
                  value: '76%',
                  label: 'Average score',
                  semanticLabel: 'Average score: 76 percent',
                ),
                AppMetricData(
                  value: '84%',
                  label: 'Accuracy',
                  semanticLabel: 'Accuracy: 84 percent',
                ),
              ],
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Average score: 76 percent'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Accuracy: 84 percent'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });
}
