import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/favorite_item.dart';

class FavoriteProductCard extends StatelessWidget {
  const FavoriteProductCard({
    super.key,
    required this.item,
    required this.onRemove,
    this.onAddToCart,
    this.onTap,
  });

  final FavoriteItem item;
  final VoidCallback onRemove;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final menu = item.menu;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 110,
                  height: 110,
                  child: _ProductImage(url: menu.image),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 110,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              menu.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppTextStyles.skipButton(color: Colors.black87)
                                      .copyWith(fontSize: 16),
                            ),
                          ),
                          InkWell(
                            onTap: onRemove,
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (menu.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          menu.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.onboardingSubtitle().copyWith(
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            Formatters.formatPrice(menu.price),
                            style: AppTextStyles.skipButton(
                              color: AppColors.primaryBlue,
                            ).copyWith(fontSize: 16),
                          ),
                          const Spacer(),
                          Material(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: onAddToCart,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                child: Text(
                                  'أضف للسلة',
                                  style: AppTextStyles.primaryButton().copyWith(
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
