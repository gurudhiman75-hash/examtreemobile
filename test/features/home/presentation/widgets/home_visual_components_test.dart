import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/home/presentation/widgets/home_visual_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget app(
    Widget child, {
    Size size = const Size(390, 844),
    double textScale = 1,
    bool disableAnimations = false,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
          disableAnimations: disableAnimations,
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  testWidgets('learning action remains usable at 200% text on a narrow phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var opened = false;
    await tester.pumpWidget(
      app(
        LearningActionCard(
          icon: Icons.play_circle_outline_rounded,
          eyebrow: 'Continue now',
          title: 'SSC Combined Graduate Level full-length mock test',
          description:
              'Your active attempt is saved. Resume from the point where you stopped.',
          actionLabel: 'Resume test',
          metadata: const [
            HomeActionMetadata(icon: Icons.timer_outlined, label: '60 min'),
            HomeActionMetadata(
              icon: Icons.help_outline_rounded,
              label: '100 questions',
            ),
            HomeActionMetadata(
              icon: Icons.signal_cellular_alt_rounded,
              label: 'Medium',
            ),
          ],
          onAction: () => opened = true,
          secondaryIcon: Icons.grid_view_rounded,
          secondaryTooltip: 'Browse all tests',
          onSecondaryAction: () {},
        ),
        size: const Size(320, 760),
        textScale: 2,
        disableAnimations: true,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Resume test'), findsOneWidget);
    await tester.ensureVisible(find.text('Resume test'));
    await tester.tap(find.text('Resume test'));
    expect(opened, isTrue);
  });

  testWidgets('section action stacks without overflow at large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(300, 500));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      app(
        HomeSectionHeader(
          title: 'Recommended for you',
          subtitle: 'Fresh tests from your available catalogue',
          actionLabel: 'View all',
          onAction: () {},
        ),
        size: const Size(300, 500),
        textScale: 2,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('View all'), findsOneWidget);
  });

  testWidgets('rail exposes position semantics and survives snapping', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.binding.setSurfaceSize(const Size(360, 500));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        app(
          HorizontalContentRail(
            height: 180,
            semanticLabel: 'Recommended tests',
            children: List.generate(
              4,
              (index) => HomeModuleShell(
                child: Text('Test ${index + 1}'),
              ),
            ),
          ),
          size: const Size(360, 500),
        ),
      );

      expect(find.bySemanticsLabel('Recommended tests'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Item 1 of 4')), findsOneWidget);
      await tester.drag(
        find.byType(HorizontalContentRail),
        const Offset(-190, 0),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Test 2'), findsWidgets);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('skeleton becomes static when reduced motion is requested', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        app(
          const HomeSkeleton(
            height: 210,
            variant: HomeSkeletonVariant.action,
          ),
          disableAnimations: true,
        ),
      );

      expect(find.bySemanticsLabel('Loading content'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(tester.binding.transientCallbackCount, 0);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('compact metric supplies a spoken label', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        app(const CompactMetric(value: '82%', label: 'Accuracy')),
      );

      expect(find.bySemanticsLabel('Accuracy: 82%'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });
}
