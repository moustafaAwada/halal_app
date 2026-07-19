import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography tokens using the Cairo Arabic font family.
abstract final class AppTextStyles {
  static TextStyle get _base => GoogleFonts.cairo();

  static TextStyle splashBrand({Color color = AppColors.white}) => _base.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
      );

  static TextStyle splashSlogan({Color color = AppColors.white}) => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.4,
      );

  static TextStyle onboardingTitle({Color color = AppColors.primaryBlue}) =>
      _base.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
      );

  static TextStyle onboardingSubtitle({Color color = AppColors.subtitleGrey}) =>
      _base.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle skipButton({Color color = AppColors.primaryBlue}) => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle primaryButton({Color color = AppColors.white}) => _base.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: color,
      );
}
