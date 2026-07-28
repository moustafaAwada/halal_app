import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../home/presentation/pages/product_detail_page.dart';
import '../../../home/presentation/widgets/home_shimmer.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../domain/entities/favorite_item.dart';
import '../cubit/favorites_cubit.dart';
import '../widgets/favorite_product_card.dart';
import '../widgets/favorites_shimmer.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({
    super.key,
    this.onStartShopping,
    this.onBrowseOffers,
  });

  final VoidCallback? onStartShopping;
  final VoidCallback? onBrowseOffers;

  @override
  Widget build(BuildContext context) {
    return _FavoritesView(
      onStartShopping: onStartShopping,
      onBrowseOffers: onBrowseOffers,
    );
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView({
    this.onStartShopping,
    this.onBrowseOffers,
  });

  final VoidCallback? onStartShopping;
  final VoidCallback? onBrowseOffers;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.searchBackground,
        body: SafeArea(
          child: BlocConsumer<FavoritesCubit, FavoritesState>(
            listener: (context, state) {
              if (state is FavoritesActionError) {
                SnackbarUtils.showErrorSnackBar(context, state.message);
              }
            },
            buildWhen: (previous, current) => current is! FavoritesActionError,
            builder: (context, state) {
              return switch (state) {
                FavoritesInitial() || FavoritesLoading() => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FavoritesHeader(count: 0, showDeleteAll: false),
                      const Expanded(child: FavoritesShimmer()),
                    ],
                  ),
                FavoritesError(:final message) => Column(
                    children: [
                      _FavoritesHeader(count: 0, showDeleteAll: false),
                      Expanded(
                        child: HomeErrorView(
                          message: message,
                          onRetry: () =>
                              context.read<FavoritesCubit>().retry(),
                        ),
                      ),
                    ],
                  ),
                FavoritesLoaded(:final favorites) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FavoritesHeader(
                        count: favorites.length,
                        showDeleteAll: favorites.isNotEmpty,
                        onDeleteAll: favorites.isNotEmpty
                            ? () => _confirmDeleteAll(context)
                            : null,
                      ),
                      Expanded(
                        child: favorites.isEmpty
                            ? FavoritesEmptyView(
                                onStartShopping: onStartShopping,
                                onBrowseOffers: onBrowseOffers,
                              )
                            : _FavoritesList(favorites: favorites),
                      ),
                    ],
                  ),
                FavoritesActionError() => const SizedBox.shrink(),
              };
            },
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('حذف الكل'),
            content: const Text('هل تريد حذف جميع المنتجات من المفضلة؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text(
                  'حذف',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      await context.read<FavoritesCubit>().removeAllFavorites();
    }
  }
}

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader({
    required this.count,
    required this.showDeleteAll,
    this.onDeleteAll,
  });

  final int count;
  final bool showDeleteAll;
  final VoidCallback? onDeleteAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'المنتجات المفضلة ($count)',
              style: AppTextStyles.onboardingSubtitle(
                color: AppColors.subtitleGrey,
              ).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (showDeleteAll)
            TextButton(
              onPressed: onDeleteAll,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'حذف الكل',
                style: AppTextStyles.skipButton(color: Colors.red).copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  const _FavoritesList({required this.favorites});

  final List<FavoriteItem> favorites;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: () => context.read<FavoritesCubit>().loadFavorites(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: favorites.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = favorites[index];
          return FavoriteProductCard(
            item: item,
            onTap: () => openProductDetail(
              context,
              itemId: item.menuId,
              isOffer: false,
            ),
            onRemove: () =>
                context.read<FavoritesCubit>().removeFavorite(item.id),
            onAddToCart: () async {
              final cubit = context.read<CartCubit>();
              await cubit.addToCart(item.menuId);
              if (!context.mounted) return;
              if (cubit.state is CartLoaded) {
                SnackbarUtils.showSuccessSnackBar(
                  context,
                  'تمت الإضافة إلى السلة',
                );
              }
            },
          );
        },
      ),
    );
  }
}
