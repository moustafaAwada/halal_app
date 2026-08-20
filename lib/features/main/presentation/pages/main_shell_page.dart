import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/pages/orders_screen.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../widgets/app_bottom_nav_bar.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  static const _favoritesTabIndex = 1;
  static const _cartTabIndex = 2;
  static const _ordersTabIndex = 3;
  static const _accountTabIndex = 4;

  int _currentIndex = 0;
  late final FavoritesCubit _favoritesCubit;
  late final CartCubit _cartCubit;
  late final OrdersCubit _ordersCubit;
  late final ProfileCubit _profileCubit;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _favoritesCubit = sl<FavoritesCubit>();
    _cartCubit = sl<CartCubit>();
    _ordersCubit = sl<OrdersCubit>();
    _profileCubit = sl<ProfileCubit>();
    _pages = [
      const HomePage(),
      FavoritesPage(
        onStartShopping: _goToHome,
        onBrowseOffers: _goToHome,
      ),
      const CartPage(),
      const OrdersScreen(),
      const ProfileScreen(),
    ];

    // Load favorites on home open so product heart icons show the correct state.
    _favoritesCubit.loadFavorites();
  }

  void _goToHome() {
    setState(() => _currentIndex = 0);
  }

  Future<void> _showMultipleRestaurantsDialog(int productId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('مطعم مختلف'),
          content: const Text(
            'سلتك تحتوي على منتجات من مطعم آخر. هل ترغب في تفريغ السلة وإضافة هذا المنتج؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('تفريغ وإضافة'),
            ),
          ],
        ),
      ),
    );

    if (!mounted) return;

    if (confirmed == true) {
      await _cartCubit.resolveMultipleRestaurantsConflict(productId);
      if (!mounted) return;
      if (_cartCubit.state is CartLoaded) {
        SnackbarUtils.showSuccessSnackBar(context, 'تمت الإضافة إلى السلة');
      }
    } else {
      await _cartCubit.dismissMultipleRestaurantsConflict();
    }
  }

  @override
  void dispose() {
    _favoritesCubit.close();
    _cartCubit.close();
    _ordersCubit.close();
    _profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _favoritesCubit),
        BlocProvider.value(value: _cartCubit),
        BlocProvider.value(value: _ordersCubit),
        BlocProvider.value(value: _profileCubit),
      ],
      child: BlocListener<CartCubit, CartState>(
        listener: (context, state) {
          if (state is CartActionError) {
            SnackbarUtils.showErrorSnackBar(context, state.message);
          } else if (state is CartMultipleRestaurantsConflict) {
            _showMultipleRestaurantsDialog(state.pendingProductId);
          }
        },
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.white,
            extendBody: true,
            body: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: _currentIndex,
              onItemSelected: (index) {
                setState(() => _currentIndex = index);
                if (index == 0 || index == _favoritesTabIndex) {
                  _favoritesCubit.loadFavorites();
                } else if (index == _cartTabIndex) {
                  _cartCubit
                    ..markCartAsSeen()
                    ..loadCart();
                } else if (index == _ordersTabIndex) {
                  _ordersCubit.loadOrders(
                    status: _ordersCubit.selectedStatus,
                  );
                } else if (index == _accountTabIndex) {
                  _profileCubit.fetchProfile();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
