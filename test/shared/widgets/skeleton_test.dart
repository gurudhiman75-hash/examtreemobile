import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:examtree/shared/widgets/skeleton.dart';

void main() {
  testWidgets('shimmers placeholders and announces loading', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SkeletonShimmer(child: SkeletonBlock(height: 40)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ShaderMask), findsOneWidget);
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
  });

  testWidgets('stays still when reduced motion is requested', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: SkeletonShimmer(child: SkeletonBlock(height: 40)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ShaderMask), findsNothing);
  });
}
