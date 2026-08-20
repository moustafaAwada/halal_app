import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_asset_image.dart';

/// Brand logo mark shown on the splash screen.
class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  static const double _size = 132;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const AppAssetImage(
        assetPath: AppAssets.logo,
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.contain,
        placeholderIcon: Icons.hexagon_outlined,
        placeholderLabel: 'logo.jpeg',
      ),
    );
  }
}
