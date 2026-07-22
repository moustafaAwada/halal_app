import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../search/domain/entities/search_product.dart';
import '../../../search/presentation/cubit/search_cubit.dart';
import '../../../search/presentation/widgets/search_category_chip.dart';
import '../../../search/presentation/widgets/search_product_card.dart';
import '../../../search/presentation/widgets/search_shimmer.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/restaurant.dart';
import '../cubit/home_cubit.dart';
import '../../domain/entities/product_offer.dart';
import '../pages/home_view_all_page.dart';
import '../pages/product_detail_page.dart';
import '../pages/restaurant_detail_page.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_section_header.dart';
import '../widgets/home_shimmer.dart';
import '../widgets/offer_card.dart';
import '../widgets/product_card.dart';
import '../widgets/restaurant_tile.dart';
import '../widgets/review_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<HomeCubit>()..loadHomeData()),
        BlocProvider(create: (_) => sl<SearchCubit>()),
      ],
      child: _HomeView(searchController: _searchController),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, searchState) {
            final searchCubit = context.read<SearchCubit>();
            final isSearchActive = searchCubit.isSearchActive;

            if (isSearchActive) {
              return _HomeSearchContent(
                searchController: searchController,
                searchState: searchState,
                selectedCategoryKey: searchCubit.selectedCategoryKey,
              );
            }

            return BlocBuilder<HomeCubit, HomeState>(
              builder: (context, homeState) {
                return switch (homeState) {
                  HomeInitial() || HomeLoading() => const HomeShimmer(),
                  HomeError(:final message) => HomeErrorView(
                      message: message,
                      onRetry: () => context.read<HomeCubit>().retry(),
                    ),
                  HomeLoaded(:final data) => _HomeContent(
                      data: data,
                      searchController: searchController,
                    ),
                };
              },
            );
          },
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.data,
    required this.searchController,
  });

  final HomeData data;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoritesCubit, FavoritesState>(
      listener: (context, state) {
        if (state is FavoritesActionError) {
          SnackbarUtils.showErrorSnackBar(context, state.message);
        }
      },
      child: RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: () => context.read<HomeCubit>().loadHomeData(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const HomeHeader(),
          HomeSearchBar(
            controller: searchController,
            onChanged: context.read<SearchCubit>().onSearchChanged,
          ),
          if (data.topProductsOffer.isNotEmpty) ...[
            HomeSectionHeader(
              title: 'عروض حصرية',
              onViewAll: () => _openViewAllOffers(
                context,
                data.topProductsOffer,
              ),
            ),
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: data.topProductsOffer.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final offer = data.topProductsOffer[index];
                  return OfferCard(
                    offer: offer,
                    onTap: () => _openProductDetail(
                      context,
                      offer,
                      isOffer: true,
                    ),
                  );
                },
              ),
            ),
          ],
          if (data.topProducts.isNotEmpty) ...[
            HomeSectionHeader(
              title: 'الأكثر مبيعاً',
              onViewAll: () => _openViewAllProducts(
                context,
                data.topProducts,
              ),
            ),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: data.topProducts.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final product = data.topProducts[index];
                  return ProductCard(
                    product: product,
                    onTap: () => _openProductDetail(context, product),
                  );
                },
              ),
            ),
          ],
          if (data.restaurants.isNotEmpty) ...[
            HomeSectionHeader(
              title: 'المطاعم المميزة',
              onViewAll: () => _openViewAllRestaurants(
                context,
                data.restaurants,
              ),
            ),
            ...data.restaurants.map(
              (restaurant) => RestaurantTile(
                restaurant: restaurant,
                onTap: () => _openRestaurantDetail(context, restaurant),
              ),
            ),
          ],
          if (data.reviews.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                decoration: BoxDecoration(
                  color: AppColors.reviewsBackground,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      'آراء عملائنا',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 150,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: data.reviews.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return ReviewCard(review: data.reviews[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }
}

void _openProductDetail(
  BuildContext context,
  Product product, {
  bool isOffer = false,
}) {
  openProductDetail(
    context,
    itemId: product.id,
    isOffer: isOffer,
  );
}

void _openRestaurantDetail(BuildContext context, Restaurant restaurant) {
  final favoritesCubit = context.read<FavoritesCubit>();

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: favoritesCubit,
        child: RestaurantDetailPage(vendorId: restaurant.id),
      ),
    ),
  );
}

void _openViewAllOffers(BuildContext context, List<ProductOffer> offers) {
  final favoritesCubit = context.read<FavoritesCubit>();

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: favoritesCubit,
        child: HomeViewAllPage(
          title: 'عروض حصرية',
          children: offers
              .map(
                (offer) => OfferCard(
                  offer: offer,
                  fullWidth: true,
                  onTap: () => _openProductDetail(
                    context,
                    offer,
                    isOffer: true,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    ),
  );
}

void _openViewAllProducts(BuildContext context, List<Product> products) {
  final favoritesCubit = context.read<FavoritesCubit>();

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: favoritesCubit,
        child: HomeViewAllPage(
          title: 'الأكثر مبيعاً',
          children: products
              .map(
                (product) => SizedBox(
                  height: 220,
                  child: ProductCard(
                    product: product,
                    fullWidth: true,
                    onTap: () => _openProductDetail(context, product),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    ),
  );
}

void _openViewAllRestaurants(
  BuildContext context,
  List<Restaurant> restaurants,
) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => HomeViewAllPage(
        title: 'المطاعم المميزة',
        children: restaurants
            .map(
              (restaurant) => RestaurantTile(
                restaurant: restaurant,
                onTap: () => _openRestaurantDetail(context, restaurant),
              ),
            )
            .toList(),
      ),
    ),
  );
}

class _HomeSearchContent extends StatelessWidget {
  const _HomeSearchContent({
    required this.searchController,
    required this.searchState,
    required this.selectedCategoryKey,
  });

  final TextEditingController searchController;
  final SearchState searchState;
  final String? selectedCategoryKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HomeHeader(),
        HomeSearchBar(
          controller: searchController,
          onChanged: context.read<SearchCubit>().onSearchChanged,
        ),
        _HomeSearchCategoryFilters(
          selectedCategoryKey: selectedCategoryKey,
        ),
        Expanded(
          child: BlocListener<FavoritesCubit, FavoritesState>(
            listener: (context, state) {
              if (state is FavoritesActionError) {
                SnackbarUtils.showErrorSnackBar(context, state.message);
              }
            },
            child: switch (searchState) {
              SearchInitial() || SearchLoading() => const SearchShimmer(),
              SearchError(:final message) => HomeErrorView(
                  message: message,
                  onRetry: () => context.read<SearchCubit>().retry(),
                ),
              SearchLoaded(:final products) => products.isEmpty
                  ? const SearchEmptyView()
                  : _HomeSearchProductList(products: products),
            },
          ),
        ),
      ],
    );
  }
}

class _HomeSearchCategoryFilters extends StatelessWidget {
  const _HomeSearchCategoryFilters({required this.selectedCategoryKey});

  final String? selectedCategoryKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'الأقسام',
              style: AppTextStyles.onboardingTitle(color: Colors.black87),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: SearchCubit.categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = SearchCubit.categories[index];
              return SearchCategoryChip(
                label: category.label,
                isSelected: selectedCategoryKey == category.key,
                onTap: () =>
                    context.read<SearchCubit>().onCategorySelected(category.key),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HomeSearchProductList extends StatelessWidget {
  const _HomeSearchProductList({required this.products});

  final List<SearchProduct> products;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      buildWhen: (previous, current) => current is! FavoritesActionError,
      builder: (context, favoritesState) {
        final favoriteMenuIds = favoritesState is FavoritesLoaded
            ? favoritesState.favorites.map((item) => item.menuId).toSet()
            : <int>{};

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          itemCount: products.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final product = products[index];
            final isFavorite = favoriteMenuIds.contains(product.id);

            return SearchProductCard(
              product: product,
              isFavorite: isFavorite,
              onTap: () => openProductDetail(
                context,
                itemId: product.id,
                isOffer: false,
              ),
              onFavoriteTap: () async {
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
              onAddToCart: () async {
                final cubit = context.read<CartCubit>();
                await cubit.addToCart(product.id);
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
        );
      },
    );
  }
}
