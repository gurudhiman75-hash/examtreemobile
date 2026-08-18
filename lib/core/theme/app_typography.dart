import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  // Mobile-first type scale. Weight carries hierarchy so the UI can stay
  // compact without relying on oversized headings.
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 48,
      height: 1.06,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.2,
    ),
    displayMedium: TextStyle(
      fontSize: 40,
      height: 1.08,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.9,
    ),
    displaySmall: TextStyle(
      fontSize: 34,
      height: 1.1,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.7,
    ),
    headlineLarge: TextStyle(
      fontSize: 30,
      height: 1.12,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    headlineMedium: TextStyle(
      fontSize: 26,
      height: 1.14,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.35,
    ),
    headlineSmall: TextStyle(
      fontSize: 22,
      height: 1.16,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 1.25,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      height: 1.25,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.05,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.25,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: 1.4,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.05,
    ),
  );
}
