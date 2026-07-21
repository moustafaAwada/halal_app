import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_offer.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final offer = product is ProductOffer ? product as ProductOffer : null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<FavoritesCubit, FavoritesState>(
        listener: (context, state) {
          if (state is FavoritesActionError) {
            SnackbarUtils.showErrorSnackBar(context, state.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.white,
          body: BlocBuilder<FavoritesCubit, FavoritesState>(
          buildWhen: (previous, current) => current is! FavoritesActionError,
          builder: (context, favoritesState) {
            final favoriteMenuIds = favoritesState is FavoritesLoaded
                ? favoritesState.favorites.map((item) => item.menuId).toSet()
                : <int>{};
            final isFavorite = favoriteMenuIds.contains(product.id);

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 260,
                  pinned: true,
                  backgroundColor: AppColors.white,
                  foregroundColor: Colors.black87,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: _ProductImage(url: product.image),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: AppTextStyles.onboardingTitle(
                                  color: Colors.black87,
                                ).copyWith(fontSize: 24),
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                final cubit = context.read<FavoritesCubit>();
                                final wasFavorite = isFavorite;
                                await cubit.toggleFavorite(product.id);
                                if (!wasFavorite && context.mounted) {
                                  SnackbarUtils.showSuccessSnackBar(
                                    context,
                                    'تمت الإضافة إلى المفضلة',
                                  );
                                }
                              },
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : AppColors.subtitleGrey,
                              ),
                            ),
                          ],
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
                              product.rating.toStringAsFixed(1),
                              style: AppTextStyles.skipButton(color: Colors.black87),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              Formatters.formatBuyersCount(product.totalSold),
                              style: AppTextStyles.onboardingSubtitle(),
                            ),
                          ],
                        ),
                        if (offer != null && offer.discount > 0) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.badgeYellow.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'خصم ${offer.discount}%',
                              style: AppTextStyles.skipButton(color: Colors.black87)
                                  .copyWith(fontSize: 14),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        _InfoTile(
                          icon: Icons.local_offer_outlined,
                          label: 'السعر',
                          value: Formatters.formatPrice(product.price),
                          valueColor: AppColors.primaryBlue,
                        ),
                        if (offer != null) ...[
                          const SizedBox(height: 12),
                          _InfoTile(
                            icon: Icons.history,
                            label: 'السعر قبل الخصم',
                            value: Formatters.formatPrice(offer.oldPrice),
                          ),
                        ],
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: () {},
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'أضف للسلة',
                              style: AppTextStyles.primaryButton(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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
        child: const Icon(Icons.fastfood_outlined, size: 48),
      ),
    );
  }
}
