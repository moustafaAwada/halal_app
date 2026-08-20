import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  static const _items = <_NavItem>[
    _NavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'الرئيسية',
    ),
    _NavItem(
      icon: Icons.favorite_border,
      selectedIcon: Icons.favorite,
      label: 'المفضلة',
    ),
    _NavItem(
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart_outlined,
      label: '',
      isCart: true,
    ),
    _NavItem(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      label: 'الطلبات',
    ),
    _NavItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'الحساب',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SizedBox(
        height: 72,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.navBarBackground,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.navBarBorder),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.navBarShadow,
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(_items.length, (index) {
                  final item = _items[index];
                  if (item.isCart) {
                    return const Expanded(child: SizedBox());
                  }

                  return Expanded(
                    child: _NavBarItem(
                      item: item,
                      isSelected: currentIndex == index,
                      onTap: () => onItemSelected(index),
                    ),
                  );
                }),
              ),
            ),
            Positioned(
              top: 0,
              // BlocBuilder is scoped tightly to the cart button only,
              // so only this widget rebuilds when hasNewItems changes.
              child: BlocBuilder<CartCubit, CartState>(
                buildWhen: (previous, current) {
                  // Rebuild only when the badge visibility actually changes.
                  final prevHas =
                      previous is CartLoaded && previous.hasNewItems;
                  final currHas =
                      current is CartLoaded && current.hasNewItems;
                  return prevHas != currHas;
                },
                builder: (context, state) {
                  final hasNewItems =
                      state is CartLoaded && state.hasNewItems;
                  return _CartButton(
                    isSelected: currentIndex == 2,
                    hasNewItems: hasNewItems,
                    onTap: () => onItemSelected(2),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primaryBlue : AppColors.navBarInactive;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: AppColors.primaryBlue.withValues(alpha: 0.08),
        highlightColor: AppColors.primaryBlue.withValues(alpha: 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? item.selectedIcon : item.icon,
              color: color,
              size: 24,
            ),
            if (item.label.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                item.label,
                style: AppTextStyles.onboardingSubtitle(color: color).copyWith(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({
    required this.isSelected,
    required this.onTap,
    required this.hasNewItems,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final bool hasNewItems;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppColors.primaryBlue,
          elevation: isSelected ? 6 : 4,
          shadowColor: AppColors.primaryBlue.withValues(alpha: 0.45),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.white,
                size: 26,
              ),
            ),
          ),
        ),
        // Red dot badge — only visible when hasNewItems is true.
        if (hasNewItems)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.isCart = false,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isCart;
}
