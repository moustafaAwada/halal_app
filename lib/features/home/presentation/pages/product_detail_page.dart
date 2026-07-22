import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../domain/entities/product_detail.dart';
import '../cubit/product_detail_cubit.dart';
import '../widgets/home_shimmer.dart';

void openProductDetail(
  BuildContext context, {
  required int itemId,
  required bool isOffer,
}) {
  final favoritesCubit = context.read<FavoritesCubit>();

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: favoritesCubit,
        child: ProductDetailPage(
          itemId: itemId,
          isOffer: isOffer,
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
  });

  final int itemId;
  final bool isOffer;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductDetailCubit>()
        ..load(id: itemId, isOffer: isOffer),
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
              final isFavorite = favoriteMenuIds.contains(detail.id);

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
                                color:
                                    AppColors.badgeYellow.withValues(alpha: 0.2),
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
