import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PlaceholderTabPage extends StatelessWidget {
  const PlaceholderTabPage({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: AppColors.primaryBlue),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTextStyles.onboardingTitle(color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'قريباً',
                style: AppTextStyles.onboardingSubtitle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
