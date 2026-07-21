import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/search_product.dart';

class SearchProductCard extends StatelessWidget {
  const SearchProductCard({super.key, required this.product});

  final SearchProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _ProductImage(url: product.image),
              ),
              if (product.hasDiscount)
                Positioned(
                  top: 12,
                  right: 12,
                  child: _Badge(
                    label: 'خصم ${product.discountPercentage}%',
                    backgroundColor: const Color(0xFFFF8A80),
                    textColor: AppColors.white,
                  ),
                )
              else if (product.isAvailable)
                Positioned(
                  top: 12,
                  right: 12,
                  child: _Badge(
                    label: 'متاح الآن',
                    backgroundColor: const Color(0xFF4CAF50),
                    textColor: AppColors.white,
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.skipButton(color: Colors.black87)
                      .copyWith(fontSize: 18),
                ),
                if (product.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.onboardingSubtitle(),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.badgeYellow,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.averageRating.toStringAsFixed(1),
                      style: AppTextStyles.onboardingSubtitle(
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${product.reviewsCount} تقييم',
                      style: AppTextStyles.onboardingSubtitle(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (product.hasDiscount) ...[
                  Text(
                    Formatters.formatPrice(product.priceBeforeDiscount!),
                    style: AppTextStyles.onboardingSubtitle().copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  Formatters.formatPrice(product.price),
                  style: AppTextStyles.skipButton(color: AppColors.primaryBlue)
                      .copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.skipButton(color: textColor).copyWith(fontSize: 12),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url});

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
