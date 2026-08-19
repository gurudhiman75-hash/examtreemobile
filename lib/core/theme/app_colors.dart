import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ExamTree mobile palette: deep indigo for focus, teal for learning progress,
  // and cool neutral surfaces for a clean, information-dense study UI.
  static const Color primary = Color(0xFF243B7B);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFE3E9FF);
  static const Color onPrimaryContainer = Color(0xFF11245C);

  static const Color secondary = Color(0xFF087F78);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFC8F2ED);
  static const Color onSecondaryContainer = Color(0xFF003D39);

  static const Color tertiary = Color(0xFF6B4FA1);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFEBDDFF);
  static const Color onTertiaryContainer = Color(0xFF3D236F);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  static const Color background = Color(0xFFF7F8FC);
  static const Color onBackground = Color(0xFF191B23);
  static const Color surface = Color(0xFFF7F8FC);
  static const Color onSurface = Color(0xFF191B23);
  static const Color onSurfaceVariant = Color(0xFF5D6170);

  static const Color surfaceDim = Color(0xFFD9DAE2);
  static const Color surfaceBright = Color(0xFFFCF8FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF1F2F8);
  static const Color surfaceContainer = Color(0xFFEBECF2);
  static const Color surfaceContainerHigh = Color(0xFFE5E6EC);
  static const Color surfaceContainerHighest = Color(0xFFDFE0E6);

  static const Color outline = Color(0xFF767987);
  static const Color outlineVariant = Color(0xFFC6C8D1);
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
  static const Color inverseSurface = Color(0xFF2E3038);
  static const Color onInverseSurface = Color(0xFFF1F0F8);
  static const Color inversePrimary = Color(0xFFB8C4FF);

  // Semantic learning colours used by result/progress surfaces. They are kept
  // separate from Material roles so meaning is never inferred from brand colour.
  static const Color success = Color(0xFF147D64);
  static const Color successContainer = Color(0xFFD1F5E9);
  static const Color onSuccessContainer = Color(0xFF004D3A);
  static const Color warning = Color(0xFF9A6700);
  static const Color warningContainer = Color(0xFFFFE6A6);
}
