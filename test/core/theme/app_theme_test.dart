import 'package:examtree/core/theme/app_colors.dart';
import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('light theme exposes the ExamTree mobile visual foundation', () {
    final theme = AppTheme.lightTheme;
    final label = theme.textTheme.labelLarge;
    final canonicalLabel = AppTypography.textTheme.labelLarge;

    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.colorScheme.secondary, AppColors.secondary);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(theme.progressIndicatorTheme.color, AppColors.secondary);
    expect(theme.navigationBarTheme.height, 68);
    expect(theme.cardTheme.elevation, 0);
    expect(label?.fontSize, canonicalLabel?.fontSize);
    expect(label?.fontWeight, canonicalLabel?.fontWeight);
    expect(label?.letterSpacing, canonicalLabel?.letterSpacing);
    expect(label?.height, canonicalLabel?.height);
  });

  testWidgets('shared controls preserve mobile touch-target sizing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Column(
            children: [
              FilledButton(onPressed: () {}, child: const Text('Continue')),
              OutlinedButton(onPressed: () {}, child: const Text('Browse')),
            ],
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(FilledButton)).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(find.byType(OutlinedButton)).height, greaterThanOrEqualTo(48));
  });

  test('buttons inherit the canonical label typography', () {
    final theme = AppTheme.lightTheme;

    expect(theme.filledButtonTheme.style?.textStyle?.resolve({}), isNull);
    expect(theme.outlinedButtonTheme.style?.textStyle?.resolve({}), isNull);
    expect(theme.textButtonTheme.style?.textStyle?.resolve({}), isNull);
    expect(theme.textTheme.labelLarge?.fontWeight, FontWeight.w700);
  });
}
