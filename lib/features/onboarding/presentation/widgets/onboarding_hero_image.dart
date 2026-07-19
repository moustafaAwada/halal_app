import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../cubit/onboarding_cubit.dart';

/// Styled image frame for onboarding slides with a soft brand backdrop.
class OnboardingHeroImage extends StatelessWidget {
  const OnboardingHeroImage({
    super.key,
    required this.page,
    required this.maxHeight,
  });

  final OnboardingPageData page;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final frameHeight = maxHeight.clamp(240.0, 360.0);

    return SizedBox(
      height: frameHeight,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: frameHeight * 0.08,
            child: Container(
              width: frameHeight * 0.82,
              height: frameHeight * 0.82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryBlue.withValues(alpha: 0.14),
                    AppColors.primaryBlue.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 20,
            right: 20,
            child: Container(
              height: frameHeight * 0.88,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.06),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    page.imagePadding.left,
                    page.imagePadding.top,
                    page.imagePadding.right,
                    page.imagePadding.bottom,
                  ),
                  child: Transform.scale(
                    scale: page.imageScale,
                    child: AppAssetImage(
                      assetPath: page.imageAsset,
                      width: double.infinity,
                      height: double.infinity,
                      fit: page.imageFit,
                      alignment: page.imageAlignment,
                      placeholderIcon: page.placeholderIcon,
                      placeholderLabel: page.placeholderLabel,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
