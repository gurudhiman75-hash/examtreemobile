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
    expect(theme.progressIndicatorTheme.color, AppColors.primary);
    expect(theme.navigationBarTheme.height, 70);
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
              const SearchBar(hintText: 'Search tests'),
            ],
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(FilledButton)).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(find.byType(OutlinedButton)).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(find.byType(SearchBar)).height, greaterThanOrEqualTo(52));
  });

  test('buttons inherit the canonical label typography', () {
    final theme = AppTheme.lightTheme;

    expect(theme.filledButtonTheme.style?.textStyle?.resolve({}), isNull);
    expect(theme.outlinedButtonTheme.style?.textStyle?.resolve({}), isNull);
    expect(theme.textButtonTheme.style?.textStyle?.resolve({}), isNull);
    expect(theme.textTheme.labelLarge?.fontWeight, FontWeight.w700);
  });

  test('search bars use a flat neutral surface instead of default elevation', () {
    final search = AppTheme.lightTheme.searchBarTheme;
    const states = <WidgetState>{};

    expect(search.elevation?.resolve(states), 0);
    expect(
      search.backgroundColor?.resolve(states),
      AppColors.surfaceContainerLow,
    );
    expect(search.shadowColor?.resolve(states), Colors.transparent);
    expect(search.side?.resolve(states), BorderSide.none);
  });
}
