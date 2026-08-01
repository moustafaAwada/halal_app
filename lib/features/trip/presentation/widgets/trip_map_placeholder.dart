import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Placeholder for future Google Maps integration.
class TripMapPlaceholder extends StatelessWidget {
  const TripMapPlaceholder({super.key, this.height = 220});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.reviewsBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navBarBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 48,
            color: AppColors.primaryBlue.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          Text(
            'خريطة جوجل — قريباً',
            style: AppTextStyles.onboardingSubtitle(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Google Maps coming soon',
            style: AppTextStyles.onboardingSubtitle(
              color: AppColors.subtitleGrey.withValues(alpha: 0.8),
            ).copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
