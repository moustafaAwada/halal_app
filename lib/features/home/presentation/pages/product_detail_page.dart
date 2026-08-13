import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_detail.dart';
import '../cubit/product_detail_cubit.dart';
import '../widgets/home_shimmer.dart';

void openProductDetail(
  BuildContext context, {
  required int itemId,
  required bool isOffer,
  Product? product,
}) {
  final favoritesCubit = context.read<FavoritesCubit>();
  final cartCubit = context.read<CartCubit>();

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: favoritesCubit),
          BlocProvider.value(value: cartCubit),
        ],
        child: ProductDetailPage(
          itemId: itemId,
          isOffer: isOffer,
          product: product,
        ),
      ),
    ),
  );
}

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    super.key,
    required this.itemId,
    this.isOffer = false,
    this.product,
  });

  final int itemId;
  final bool isOffer;
  final Product? product;

  @override
  Widget build(BuildContext context) {
    final seed = product == null ? null : ProductDetail.fromProduct(product!);

    return BlocProvider(
      create: (_) => sl<ProductDetailCubit>()
        ..load(id: itemId, isOffer: isOffer, seed: seed),
      child: _ProductDetailView(
        itemId: itemId,
        isOffer: isOffer,
      ),
    );
  }
}

class _ProductDetailView extends StatelessWidget {
  const _ProductDetailView({
    required this.itemId,
    required this.isOffer,
  });

  final int itemId;
  final bool isOffer;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailCubit, ProductDetailState>(
      builder: (context, state) {
        return switch (state) {
          ProductDetailInitial() || ProductDetailLoading() =>
            const _ProductDetailLoadingView(),
          ProductDetailError(:final message) => _ProductDetailErrorView(
              message: message,
              onRetry: () => context.read<ProductDetailCubit>().retry(
                    id: itemId,
                    isOffer: isOffer,
                  ),
            ),
          ProductDetailLoaded(:final detail) => _ProductDetailContent(
              detail: detail,
            ),
        };
      },
    );
  }
}

class _ProductDetailLoadingView extends StatelessWidget {
  const _ProductDetailLoadingView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ProductDetailErrorView extends StatelessWidget {
  const _ProductDetailErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: HomeErrorView(message: message, onRetry: onRetry),
      ),
    );
  }
}

class _ProductDetailContent extends StatelessWidget {
  const _ProductDetailContent({required this.detail});

  final ProductDetail detail;

  @override
  Widget build(BuildContext context) {
    final oldPrice = detail.displayPriceBeforeDiscount;
    final vendor = detail.vendor;

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
              final isFavorite = favoriteMenuIds.contains(detail.id) ||
                  (favoritesState is! FavoritesLoaded && detail.isFavorite);

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 260,
                    pinned: true,
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.white,
                    leading: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.white,
                            size: 18,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: _ProductImage(url: detail.image),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (detail.isOffer) ...[
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.badgeYellow
                                              .withValues(alpha: 0.25),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'عرض حصري',
                                          style: AppTextStyles.skipButton(
                                            color: Colors.black87,
                                          ).copyWith(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                    Text(
                                      detail.name,
                                      style: AppTextStyles.onboardingTitle(
                                        color: Colors.black87,
                                      ).copyWith(fontSize: 24),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  final cubit = context.read<FavoritesCubit>();
                                  final wasFavorite = isFavorite;
                                  await cubit.toggleFavorite(detail.id);
                                  if (!wasFavorite && context.mounted) {
                                    SnackbarUtils.showSuccessSnackBar(
                                      context,
                                      'تمت الإضافة إلى المفضلة',
                                    );
                                  }
                                },
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite
                                      ? Colors.red
                                      : AppColors.subtitleGrey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _RatingSoldRow(
                            rating: detail.rating,
                            reviewCount: detail.reviewCount,
                            totalSold: detail.totalSold,
                          ),
                          if (vendor != null) ...[
                            const SizedBox(height: 16),
                            _VendorTile(
                              name: vendor.displayName,
                              imageUrl: vendor.imageUrl,
                              avgRating: vendor.avgRating,
                            ),
                          ],
                          if (detail.description.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              detail.description,
                              style: AppTextStyles.onboardingSubtitle(),
                            ),
                          ],
                          if (detail.hasDiscount) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.badgeYellow
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'خصم ${detail.discountPercentage}%',
                                style: AppTextStyles.skipButton(
                                  color: Colors.black87,
                                ).copyWith(fontSize: 14),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          _InfoTile(
                            icon: Icons.local_offer_outlined,
                            label: 'السعر',
                            value: Formatters.formatPrice(detail.price),
                            valueColor: AppColors.primaryBlue,
                          ),
                          if (oldPrice != null) ...[
                            const SizedBox(height: 12),
                            _InfoTile(
                              icon: Icons.history,
                              label: 'السعر قبل الخصم',
                              value: Formatters.formatPrice(oldPrice),
                            ),
                          ],
                          if (detail.totalSold > 0) ...[
                            const SizedBox(height: 12),
                            _InfoTile(
                              icon: Icons.shopping_bag_outlined,
                              label: 'تم البيع',
                              value: '${detail.totalSold}',
                            ),
                          ],
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed: () async {
                                final cubit = context.read<CartCubit>();
                                await cubit.addToCart(detail.id);
                                if (!context.mounted) return;
                                if (cubit.state is CartLoaded) {
                                  SnackbarUtils.showSuccessSnackBar(
                                    context,
                                    'تمت الإضافة إلى السلة',
                                  );
                                }
                              },
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

class _RatingSoldRow extends StatelessWidget {
  const _RatingSoldRow({
    required this.rating,
    required this.reviewCount,
    required this.totalSold,
  });

  final double rating;
  final int reviewCount;
  final int totalSold;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star_rounded,
              color: AppColors.badgeYellow,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: AppTextStyles.skipButton(color: Colors.black87),
            ),
            if (reviewCount > 0) ...[
              const SizedBox(width: 4),
              Text(
                '($reviewCount تقييم)',
                style: AppTextStyles.onboardingSubtitle(),
              ),
            ],
          ],
        ),
        if (totalSold > 0)
          Text(
            '$totalSold مبيعات',
            style: AppTextStyles.onboardingSubtitle(color: Colors.black87),
          ),
      ],
    );
  }
}

class _VendorTile extends StatelessWidget {
  const _VendorTile({
    required this.name,
    required this.imageUrl,
    required this.avgRating,
  });

  final String name;
  final String imageUrl;
  final double avgRating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.searchBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 48,
              height: 48,
              child: imageUrl.isEmpty
                  ? Container(
                      color: AppColors.inactiveDot,
                      child: const Icon(Icons.storefront_outlined),
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Container(color: AppColors.inactiveDot),
                      errorWidget: (_, _, _) => Container(
                        color: AppColors.inactiveDot,
                        child: const Icon(Icons.storefront_outlined),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'البائع',
                  style: AppTextStyles.onboardingSubtitle(),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: AppTextStyles.skipButton(color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.badgeYellow,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: AppTextStyles.onboardingSubtitle(
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
