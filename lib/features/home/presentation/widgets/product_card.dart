import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.fullWidth = false,
  });

  final Product product;
  final VoidCallback? onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
      width: fullWidth ? double.infinity : 160,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: _ProductImage(url: product.image),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: BlocBuilder<FavoritesCubit, FavoritesState>(
                  buildWhen: (previous, current) =>
                      current is! FavoritesActionError,
                  builder: (context, favoritesState) {
                    final isFavorite = favoritesState is FavoritesLoaded
                        ? favoritesState.favorites
                            .any((favorite) => favorite.menuId == product.id)
                        : product.isFavorite;

                    return Material(
                      color: AppColors.white,
                      shape: const CircleBorder(),
                      elevation: 1,
                      shadowColor: Colors.black.withValues(alpha: 0.08),
                      child: InkWell(
                        onTap: () => context
                            .read<FavoritesCubit>()
                            .toggleFavorite(product.id),
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: isFavorite
                                ? Colors.red
                                : AppColors.subtitleGrey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.skipButton(color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.badgeYellow, size: 16),
              const SizedBox(width: 4),
              Text(
                product.rating.toStringAsFixed(1),
                style: AppTextStyles.onboardingSubtitle(color: Colors.black87),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  Formatters.formatPrice(product.price),
                  style: AppTextStyles.skipButton(color: AppColors.primaryBlue),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.primaryBlue,
                  size: 18,
                ),
              ),
            ],
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
