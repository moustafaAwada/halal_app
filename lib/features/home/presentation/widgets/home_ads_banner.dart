import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Colors sampled from the ads banner image.
abstract final class _AdsBannerColors {
  static const Color background = Color(0xFFE8E8E8);
  static const Color accentYellow = Color(0xFFFDBF00);
  static const Color accentRed = Color(0xFFA01515);
}

/// Static promotional banner shown on the home page.
class HomeAdsBanner extends StatelessWidget {
  const HomeAdsBanner({super.key, this.onTap});

  final VoidCallback? onTap;

  static const double _bannerHeight = 148;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bannerWidth = screenWidth - 40;
    final cacheWidth = (bannerWidth * dpr).round();
    final cacheHeight = (_bannerHeight * dpr).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Material(
        color: _AdsBannerColors.background,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: _bannerHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  AppAssets.adsBanner,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.medium,
                  cacheWidth: cacheWidth,
                  cacheHeight: cacheHeight,
                  errorBuilder: (_, _, _) => const ColoredBox(
                    color: _AdsBannerColors.background,
                    child: Icon(
                      Icons.lunch_dining_rounded,
                      color: _AdsBannerColors.accentRed,
                      size: 56,
                    ),
                  ),
                ),
                // Soft edge fade using the same light color as the image.
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _AdsBannerColors.background.withValues(alpha: 0.35),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _AdsBannerColors.background.withValues(alpha: 0.12),
                          Colors.transparent,
                          Colors.transparent,
                          _AdsBannerColors.background.withValues(alpha: 0.18),
                        ],
                        stops: const [0.0, 0.2, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
                // Small Arabic label using the image accent yellow.
                PositionedDirectional(
                  start: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _AdsBannerColors.accentYellow,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'إعلان',
                      style: AppTextStyles.onboardingSubtitle(
                        color: _AdsBannerColors.accentRed,
                      ).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
