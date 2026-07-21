import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'placeholder_tab_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    HomePage(),
    PlaceholderTabPage(
      title: 'المفضلة',
      icon: Icons.favorite_border,
    ),
    PlaceholderTabPage(
      title: 'السلة',
      icon: Icons.shopping_cart_outlined,
    ),
    PlaceholderTabPage(
      title: 'طلباتي',
      icon: Icons.receipt_long_outlined,
    ),
    PlaceholderTabPage(
      title: 'حسابي',
      icon: Icons.person_outline,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
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
          },
        ),
      ),
    );
  }
}
