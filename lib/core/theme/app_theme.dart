import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      surfaceDim: AppColors.surfaceDim,
      surfaceBright: AppColors.surfaceBright,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      shadow: AppColors.shadow,
      scrim: AppColors.scrim,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.onInverseSurface,
      inversePrimary: AppColors.inversePrimary,
      surfaceTint: Colors.transparent,
    );

    const controlRadius = BorderRadius.all(Radius.circular(16));
    const cardRadius = BorderRadius.all(Radius.circular(22));

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 60,
        titleSpacing: 18,
        titleTextStyle: TextStyle(
          color: AppColors.onSurface,
          fontSize: 20,
          height: 1.2,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.35,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        backgroundColor: AppColors.surfaceContainerLowest,
        indicatorColor: AppColors.primaryContainer,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.onSurfaceVariant,
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.onSurfaceVariant,
            size: 24,
          );
        }),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        indicatorColor: AppColors.primaryContainer,
        selectedIconTheme: IconThemeData(color: AppColors.primary),
        selectedLabelTextStyle: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
      navigationDrawerTheme: const NavigationDrawerThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryContainer,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: cardRadius),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: const RoundedRectangleBorder(borderRadius: controlRadius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.outlineVariant),
          shape: const RoundedRectangleBorder(borderRadius: controlRadius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          foregroundColor: AppColors.onSurface,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: controlRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: controlRadius,
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: controlRadius,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: controlRadius,
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: controlRadius,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      searchBarTheme: const SearchBarThemeData(
        elevation: WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(AppColors.surfaceContainerLow),
        shadowColor: WidgetStatePropertyAll(Colors.transparent),
        surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        side: WidgetStatePropertyAll(BorderSide.none),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: controlRadius),
        ),
        constraints: BoxConstraints(minHeight: 52),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        selectedColor: AppColors.primaryContainer,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: controlRadius),
        labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 3,
        focusElevation: 3,
        hoverElevation: 4,
        highlightElevation: 4,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: controlRadius),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryContainer,
        circularTrackColor: AppColors.primaryContainer,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      dividerColor: AppColors.outlineVariant,
    );
  }
}
