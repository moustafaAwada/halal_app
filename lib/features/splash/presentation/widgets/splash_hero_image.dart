import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_asset_image.dart';

/// Hero illustration displayed at the bottom of the splash screen.
class SplashHeroImage extends StatelessWidget {
  const SplashHeroImage({super.key, required this.maxHeight});

  final double maxHeight;

  static const double _horizontalPadding = 24;
  static const double _bottomPadding = 12;
  static const double _borderRadius = 28;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return SizedBox(
      height: maxHeight,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Background glow
          Positioned(
            bottom: maxHeight * 0.08,
            child: Container(
              width: screenWidth * 0.68,
              height: maxHeight * 0.22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryBlue.withValues(alpha: 0.14),
                    AppColors.primaryBlue.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              _horizontalPadding,
              0,
              _horizontalPadding,
              _bottomPadding,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_borderRadius),
              child: SizedBox(
                width: double.infinity,
                height: maxHeight * 0.92,
                child: AppAssetImage(
                  assetPath: AppAssets.splashDelivery,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  placeholderIcon: Icons.delivery_dining,
                  placeholderLabel: 'splash_delivery.png',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
