import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/restaurant.dart';

class RestaurantDetailPage extends StatelessWidget {
  const RestaurantDetailPage({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: AppColors.white,
              foregroundColor: Colors.black87,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: _RestaurantImage(url: restaurant.imageUrl),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: AppTextStyles.onboardingTitle(
                        color: Colors.black87,
                      ).copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.badgeYellow,
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          restaurant.avgRating.toStringAsFixed(1),
                          style: AppTextStyles.skipButton(color: Colors.black87),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          Formatters.formatBuyersCount(restaurant.buyersCount),
                          style: AppTextStyles.onboardingSubtitle(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _InfoTile(
                      icon: Icons.restaurant_menu_outlined,
                      label: 'عدد عناصر المنيو',
                      value: '${restaurant.menusCount} عنصر',
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      icon: Icons.people_outline,
                      label: 'عدد المشترين',
                      value: Formatters.formatBuyersCount(restaurant.buyersCount),
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      icon: Icons.star_outline_rounded,
                      label: 'التقييم',
                      value: restaurant.avgRating.toStringAsFixed(1),
                      valueColor: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.searchBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.onboardingSubtitle(color: Colors.black87),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.skipButton(color: valueColor ?? Colors.black87),
          ),
        ],
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
        child: const Icon(Icons.storefront_outlined, size: 48),
      ),
    );
  }
}
