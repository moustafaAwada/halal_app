import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/product_offer.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.offer,
    this.onTap,
    this.fullWidth = false,
  });

  final ProductOffer offer;
  final VoidCallback? onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
      width: fullWidth ? double.infinity : 280,
      height: fullWidth ? 190 : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _NetworkImage(url: offer.image),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
                stops: const [0.45, 1.0],
              ),
            ),
          ),
          if (offer.discount > 0)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.badgeYellow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'خصم ${offer.discount}%',
                  style: AppTextStyles.skipButton(color: Colors.black87)
                      .copyWith(fontSize: 12),
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.primaryButton().copyWith(fontSize: 18),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      Formatters.formatPrice(offer.price),
                      style: AppTextStyles.primaryButton().copyWith(fontSize: 16),
                    ),
                    if (offer.oldPrice > offer.price) ...[
                      const SizedBox(width: 8),
                      Text(
                        Formatters.formatPrice(offer.oldPrice),
                        style: AppTextStyles.splashSlogan(
                          color: Colors.white70,
                        ).copyWith(
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  const _NetworkImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(color: AppColors.inactiveDot);
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(color: AppColors.inactiveDot),
      errorWidget: (_, _, _) => Container(
        color: AppColors.inactiveDot,
        child: const Icon(Icons.fastfood_outlined),
      ),
    );
  }
}
