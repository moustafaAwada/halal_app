import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/restaurant.dart';

class RestaurantTile extends StatelessWidget {
  const RestaurantTile({
    super.key,
    required this.restaurant,
    this.onTap,
  });

  final Restaurant restaurant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 72,
              height: 72,
              child: _RestaurantImage(url: restaurant.imageUrl),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.skipButton(color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.badgeYellow, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      restaurant.avgRating.toStringAsFixed(1),
                      style: AppTextStyles.onboardingSubtitle(color: Colors.black87),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        Formatters.formatBuyersCount(restaurant.buyersCount),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.onboardingSubtitle(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${restaurant.menusCount} عنصر في المنيو',
                    style: AppTextStyles.onboardingSubtitle(
                      color: AppColors.primaryBlue,
                    ).copyWith(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primaryBlue,
            size: 18,
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _RestaurantImage extends StatelessWidget {
  const _RestaurantImage({required this.url});

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
        child: const Icon(Icons.storefront_outlined),
      ),
    );
  }
}
