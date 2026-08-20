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
import '../../domain/entities/addon.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_detail.dart';
import '../../domain/entities/size.dart';
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
          ProductDetailLoaded() => _ProductDetailContent(loadedState: state),
        };
      },
    );
  }
}

// ── Loading / Error views ────────────────────────────────────────────────────

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

// ── Main content ─────────────────────────────────────────────────────────────

class _ProductDetailContent extends StatelessWidget {
  const _ProductDetailContent({required this.loadedState});

  final ProductDetailLoaded loadedState;

  @override
  Widget build(BuildContext context) {
    final detail = loadedState.detail;
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
          // ── Bottom bar with dynamic price + Add to Cart ──────────────────
          bottomNavigationBar: _AddToCartBar(loadedState: loadedState),
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
                  // ── Hero image + back button ─────────────────────────────
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
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Title row + favorite button ──────────────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (detail.isOffer) ...[
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
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
                                  final cubit =
                                      context.read<FavoritesCubit>();
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
                            label: 'السعر الأساسي',
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

                          // ── Sizes section ────────────────────────────────
                          if (detail.sizes.isNotEmpty) ...[
                            const SizedBox(height: 28),
                            _SizesSection(loadedState: loadedState),
                          ],

                          // ── Addons section ───────────────────────────────
                          if (detail.addons.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _AddonsSection(loadedState: loadedState),
                          ],
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

// ── Sizes Section ─────────────────────────────────────────────────────────────

class _SizesSection extends StatelessWidget {
  const _SizesSection({required this.loadedState});

  final ProductDetailLoaded loadedState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الحجم',
          style: AppTextStyles.skipButton(color: Colors.black87)
              .copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: loadedState.detail.sizes
              .map((size) => _SizeChip(
                    size: size,
                    isSelected:
                        loadedState.selectedSize?.id == size.id,
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({
    required this.size,
    required this.isSelected,
  });

  final Size size;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ProductDetailCubit>().selectSize(size),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primaryBlue : AppColors.searchBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : AppColors.inactiveDot,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              size.name,
              style: AppTextStyles.skipButton(
                color: isSelected ? AppColors.white : Colors.black87,
              ).copyWith(fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              Formatters.formatPrice(size.price),
              style: AppTextStyles.onboardingSubtitle(
                color: isSelected
                    ? AppColors.white.withValues(alpha: 0.85)
                    : AppColors.subtitleGrey,
              ).copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Addons Section ────────────────────────────────────────────────────────────

class _AddonsSection extends StatelessWidget {
  const _AddonsSection({required this.loadedState});

  final ProductDetailLoaded loadedState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإضافات',
          style: AppTextStyles.skipButton(color: Colors.black87)
              .copyWith(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.searchBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: loadedState.detail.addons.map((addon) {
              final isSelected = loadedState.isAddonSelected(addon);
              final isLast =
                  addon == loadedState.detail.addons.last;
              return _AddonTile(
                addon: addon,
                isSelected: isSelected,
                showDivider: !isLast,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _AddonTile extends StatelessWidget {
  const _AddonTile({
    required this.addon,
    required this.isSelected,
    required this.showDivider,
  });

  final Addon addon;
  final bool isSelected;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () =>
              context.read<ProductDetailCubit>().toggleAddon(addon),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: CheckboxListTile(
              value: isSelected,
              onChanged: (_) =>
                  context.read<ProductDetailCubit>().toggleAddon(addon),
              activeColor: AppColors.primaryBlue,
              checkboxShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              title: Text(
                addon.name,
                style: AppTextStyles.skipButton(color: Colors.black87)
                    .copyWith(fontSize: 14),
              ),
              subtitle: Text(
                '+ ${Formatters.formatPrice(addon.price)}',
                style: AppTextStyles.onboardingSubtitle(
                  color: AppColors.primaryBlue,
                ).copyWith(fontSize: 12),
              ),
              controlAffinity: ListTileControlAffinity.trailing,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12),
              dense: true,
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 12,
            endIndent: 12,
            color: AppColors.inactiveDot.withValues(alpha: 0.6),
          ),
      ],
    );
  }
}

// ── Bottom Add-to-Cart Bar ────────────────────────────────────────────────────

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({required this.loadedState});

  final ProductDetailLoaded loadedState;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartLoaded) {
          SnackbarUtils.showSuccessSnackBar(context, 'تمت الإضافة إلى السلة');
        } else if (state is CartActionError) {
          SnackbarUtils.showErrorSnackBar(context, state.message);
        } else if (state is CartMultipleRestaurantsConflict) {
          _showMultipleRestaurantsDialog(context, state.pendingProductId);
        }
      },
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Dynamic price display ──────────────────────────────────
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الإجمالي',
                    style: AppTextStyles.onboardingSubtitle()
                        .copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.formatPrice(loadedState.dynamicTotalPrice),
                    style: AppTextStyles.skipButton(
                      color: AppColors.primaryBlue,
                    ).copyWith(fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // ── Add to cart button ─────────────────────────────────────
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () => _onAddToCart(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                    label: Text(
                      'أضف للسلة',
                      style: AppTextStyles.primaryButton(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onAddToCart(BuildContext context) {
    final cartCubit = context.read<CartCubit>();

    cartCubit.addToCart(
      loadedState.detail.id,
      quantity: 1,
      menuSizeId: loadedState.selectedSize?.id,
      addonIds: loadedState.selectedAddons.map((e) => e.id).toList(),
    );
  }

  void _showMultipleRestaurantsDialog(BuildContext context, int productId) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تضارب في السلة'),
          content: const Text(
            'سلتك تحتوي على منتجات من مطعم آخر. هل تريد إفراغ السلة وإضافة هذا المنتج؟',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context
                    .read<CartCubit>()
                    .dismissMultipleRestaurantsConflict();
              },
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context
                    .read<CartCubit>()
                    .resolveMultipleRestaurantsConflict(productId);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: const Text('إفراغ وإضافة'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable sub-widgets (unchanged) ─────────────────────────────────────────

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
