import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/web_launcher.dart';
import '../../domain/entities/ad.dart';

abstract final class _AdCardColors {
  static const Color background = Color(0xFFE8E8E8);
  static const Color accentYellow = Color(0xFFFDBF00);
  static const Color accentRed = Color(0xFFA01515);
}

class AdCardWidget extends StatelessWidget {
  const AdCardWidget({
    super.key,
    required this.ad,
    this.width,
    this.height = 148,
  });

  final Ad ad;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _AdCardColors.background,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openTargetUrl(context),
        child: SizedBox(
          height: height,
          width: width ?? double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _AdNetworkImage(url: ad.image),
              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Color(0x99000000),
                      ],
                      stops: [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                start: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _AdCardColors.accentYellow,
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
                    ad.placement.isNotEmpty ? ad.placement : 'إعلان',
                    style: AppTextStyles.onboardingSubtitle(
                      color: _AdCardColors.accentRed,
                    ).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (ad.title.isNotEmpty)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Text(
                    ad.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.primaryButton().copyWith(fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openTargetUrl(BuildContext context) async {
    final opened = await WebLauncher.open(ad.targetUrl);
    if (!opened && context.mounted) {
      SnackbarUtils.showErrorSnackBar(context, 'تعذر فتح رابط الإعلان');
    }
  }
}

class _AdNetworkImage extends StatelessWidget {
  const _AdNetworkImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const _AdImageError();
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      placeholder: (_, _) => const _AdImageShimmer(),
      errorWidget: (_, _, _) => const _AdImageError(),
    );
  }
}

class _AdImageShimmer extends StatelessWidget {
  const _AdImageShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.inactiveDot.withValues(alpha: 0.45),
      highlightColor: AppColors.white,
      child: const ColoredBox(color: _AdCardColors.background),
    );
  }
}

class _AdImageError extends StatelessWidget {
  const _AdImageError();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: _AdCardColors.background,
      child: Icon(
        Icons.lunch_dining_rounded,
        color: _AdCardColors.accentRed,
        size: 56,
      ),
    );
  }
}
