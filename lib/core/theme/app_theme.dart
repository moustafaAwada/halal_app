import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Centralized application theme configuration.
abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        surface: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.white,
      useMaterial3: true,
      textTheme: GoogleFonts.cairoTextTheme(),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
