import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../pages/account_page.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'placeholder_tab_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  static const _favoritesTabIndex = 1;

  int _currentIndex = 0;
  late final FavoritesCubit _favoritesCubit;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _favoritesCubit = sl<FavoritesCubit>();
    _pages = [
      const HomePage(),
      FavoritesPage(
        onStartShopping: _goToHome,
        onBrowseOffers: _goToHome,
      ),
      const PlaceholderTabPage(
        title: 'السلة',
        icon: Icons.shopping_cart_outlined,
      ),
      const PlaceholderTabPage(
        title: 'طلباتي',
        icon: Icons.receipt_long_outlined,
      ),
      const AccountPage(),
    ];
  }

  void _goToHome() {
    setState(() => _currentIndex = 0);
  }

  @override
  void dispose() {
    _favoritesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _favoritesCubit,
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
              if (index == _favoritesTabIndex) {
                _favoritesCubit.loadFavorites();
              }
            },
          ),
        ),
      ),
    );
  }
}
