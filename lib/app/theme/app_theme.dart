import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';

/// Tema global aplikasi HATCH-CARE.
abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.neutral,
      ),
      scaffoldBackgroundColor: AppColors.neutral,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.neutral,
      ),
    );
  }
}
