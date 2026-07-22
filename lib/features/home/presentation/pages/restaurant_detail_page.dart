import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/phone_launcher.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../domain/entities/restaurant_detail.dart';
import '../cubit/restaurant_detail_cubit.dart';
import 'product_detail_page.dart';
import '../widgets/home_shimmer.dart';

class RestaurantDetailPage extends StatelessWidget {
  const RestaurantDetailPage({
    super.key,
    required this.vendorId,
  });

  final int vendorId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RestaurantDetailCubit>()..load(vendorId),
      child: BlocBuilder<RestaurantDetailCubit, RestaurantDetailState>(
        builder: (context, state) {
          return switch (state) {
            RestaurantDetailInitial() || RestaurantDetailLoading() =>
            const _RestaurantDetailLoadingView(),
            RestaurantDetailError(:final message) => _RestaurantDetailErrorView(
              message: message,
              onRetry: () =>
                  context.read<RestaurantDetailCubit>().retry(vendorId),
            ),
            RestaurantDetailLoaded(:final detail) =>
                _RestaurantDetailContent(detail: detail),
          };
        },
      ),
    );
  }
}

class _RestaurantDetailLoadingView extends StatelessWidget {
  const _RestaurantDetailLoadingView();

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

class _RestaurantDetailErrorView extends StatelessWidget {
  const _RestaurantDetailErrorView({
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

class _RestaurantDetailContent extends StatefulWidget {
  const _RestaurantDetailContent({required this.detail});

  final RestaurantDetail detail;

  @override
  State<_RestaurantDetailContent> createState() =>
      _RestaurantDetailContentState();
}

class _RestaurantDetailContentState extends State<_RestaurantDetailContent> {
  static const _logoSize = 96.0;
  static const _logoOverlap = _logoSize / 2;

  int? _selectedCategoryId;

  RestaurantDetail get detail => widget.detail;

  List<RestaurantCategory> get _menuCategories => detail.categoriesWithMenus;

  List<RestaurantMenuItem> get _visibleMenuItems {
    if (_selectedCategoryId == null) {
      return _menuCategories.expand((category) => category.menus).toList();
    }

    return _menuCategories
        .firstWhere((category) => category.id == _selectedCategoryId)
        .menus;
  }

  @override
  Widget build(BuildContext context) {
    final heroImage = detail.cover.isNotEmpty ? detail.cover : detail.imageUrl;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.searchBackground,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 220, // Slightly taller for better visual impact
              pinned: true,
              stretch: true, // Cool stretch effect when pulling down
              clipBehavior: Clip.none,
              backgroundColor: AppColors.white,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    _RestaurantImage(url: heroImage),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.5, 1.0],
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: _logoOverlap),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.searchBackground,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            offset: const Offset(0, -4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(20, _logoOverlap + 16, 20, 16),
                      child: Column(
                        children: [
                          Text(
                            detail.displayName,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.onboardingTitle(
                              color: Colors.black87,
                            ).copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          if (detail.shortDescription.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              detail.shortDescription,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.onboardingSubtitle().copyWith(
                                height: 1.4,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 8,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              _InfoChip(
                                icon: Icons.access_time,
                                label: detail.workingHoursLabel,
                              ),
                              _InfoChip(
                                icon: Icons.calendar_today_outlined,
                                label: detail.workingDaysLabel,
                              ),
                              _InfoChip(
                                icon: Icons.restaurant_menu_outlined,
                                label: '${detail.menuItemsCount} عنصر',
                              ),
                              _InfoChip(
                                icon: detail.pickup
                                    ? Icons.storefront_outlined
                                    : Icons.delivery_dining_outlined,
                                label: detail.pickup
                                    ? 'استلام من الفرع'
                                    : 'توصيل فقط',
                                color: detail.pickup
                                    ? AppColors.primaryBlue
                                    : AppColors.subtitleGrey,
                                backgroundColor: detail.pickup
                                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                    : AppColors.subtitleGrey.withValues(alpha: 0.1),
                              ),
                            ],
                          ),
                          if (detail.phone.isNotEmpty ||
                              detail.whatsapp.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                if (detail.phone.isNotEmpty)
                                  Expanded(
                                    child: _ContactButton(
                                      icon: Icons.phone_outlined,
                                      label: 'اتصال',
                                      color: AppColors.primaryBlue,
                                      onTap: () => _callRestaurant(
                                        context,
                                        detail.phone,
                                      ),
                                    ),
                                  ),
                                if (detail.phone.isNotEmpty &&
                                    detail.whatsapp.isNotEmpty)
                                  const SizedBox(width: 12),
                                if (detail.whatsapp.isNotEmpty)
                                  Expanded(
                                    child: _ContactButton(
                                      icon: Icons.chat_outlined,
                                      label: 'واتساب',
                                      color: const Color(0xFF25D366), // WhatsApp Green
                                      onTap: () => _openWhatsApp(
                                        context,
                                        detail.whatsapp,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _RestaurantLogo(url: detail.imageUrl, size: _logoSize),
                    ),
                  ),
                ],
              ),
            ),
            if (_menuCategories.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'المنيو',
                    style: AppTextStyles.onboardingTitle(
                      color: Colors.black87,
                    ).copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Sticky Categories Header
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyCategoryDelegate(
                  minHeight: 56.0,
                  maxHeight: 56.0,
                  child: Container(
                    color: AppColors.searchBackground,
                    alignment: Alignment.center,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      children: [
                        _CategoryChip(
                          label: 'الكل',
                          isSelected: _selectedCategoryId == null,
                          onTap: () => setState(() => _selectedCategoryId = null),
                        ),
                        ..._menuCategories.map(
                              (category) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _CategoryChip(
                              label: category.name,
                              isSelected: _selectedCategoryId == category.id,
                              onTap: () => setState(
                                    () => _selectedCategoryId = category.id,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                sliver: SliverList.separated(
                  itemCount: _visibleMenuItems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final menu = _visibleMenuItems[index];
                    return _MenuItemCard(
                      menu: menu,
                      onTap: () => _openMenuItem(context, menu),
                    );
                  },
                ),
              ),
            ] else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.restaurant_menu_outlined,
                          size: 64,
                          color: AppColors.inactiveDot,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد عناصر في المنيو حالياً',
                          style: AppTextStyles.onboardingSubtitle(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _callRestaurant(BuildContext context, String phone) async {
    final launched = await PhoneLauncher.call(phone);
    if (!launched && context.mounted) {
      SnackbarUtils.showErrorSnackBar(context, 'تعذر فتح تطبيق الاتصال');
    }
  }

  Future<void> _openWhatsApp(BuildContext context, String phone) async {
    final launched = await PhoneLauncher.openWhatsApp(phone);
    if (!launched && context.mounted) {
      SnackbarUtils.showErrorSnackBar(context, 'تعذر فتح واتساب');
    }
  }

  void _openMenuItem(BuildContext context, RestaurantMenuItem menu) {
    openProductDetail(
      context,
      itemId: menu.id,
      isOffer: menu.isOffer,
    );
  }
}

// Custom Delegate for Sticky Header
class _StickyCategoryDelegate extends SliverPersistentHeaderDelegate {
  _StickyCategoryDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StickyCategoryDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class _RestaurantLogo extends StatelessWidget {
  const _RestaurantLogo({required this.url, required this.size});

  final double size;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
        border: Border.all(color: AppColors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: url.isEmpty
            ? ColoredBox(
          color: AppColors.inactiveDot.withValues(alpha: 0.3),
          child: const Center(
            child: Icon(
              Icons.storefront_outlined,
              color: AppColors.subtitleGrey,
              size: 40,
            ),
          ),
        )
            : CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, _) => Container(
            color: AppColors.inactiveDot.withValues(alpha: 0.3),
          ),
          errorWidget: (_, _, _) => ColoredBox(
            color: AppColors.inactiveDot.withValues(alpha: 0.3),
            child: const Center(
              child: Icon(Icons.storefront_outlined, size: 40),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
    this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primaryBlue;
    final bgColor = backgroundColor ?? AppColors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: bgColor == AppColors.white
              ? Colors.grey.withValues(alpha: 0.2)
              : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: activeColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.skipButton(color: Colors.black87)
                .copyWith(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.skipButton(color: color)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: isSelected ? AppColors.primaryBlue : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        elevation: isSelected ? 2 : 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : Colors.grey.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.skipButton(
                color: isSelected ? AppColors.white : Colors.black87,
              ).copyWith(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({
    required this.menu,
    required this.onTap,
  });

  final RestaurantMenuItem menu;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final oldPrice = menu.displayPriceBeforeDiscount;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: menu.image.isEmpty
                        ? Container(
                      color: AppColors.inactiveDot.withValues(alpha: 0.2),
                      child: const Icon(Icons.fastfood_outlined, color: Colors.grey),
                    )
                        : CachedNetworkImage(
                      imageUrl: menu.image,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: AppColors.inactiveDot.withValues(alpha: 0.2),
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: AppColors.inactiveDot.withValues(alpha: 0.2),
                        child: const Icon(Icons.fastfood_outlined, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                menu.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.skipButton(
                                  color: Colors.black87,
                                ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (menu.isOffer)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.badgeYellow.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'عرض',
                                  style: AppTextStyles.skipButton(
                                    color: Colors.orange.shade800,
                                  ).copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        if (menu.showDescription) ...[
                          const SizedBox(height: 6),
                          Text(
                            menu.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.onboardingSubtitle().copyWith(fontSize: 13),
                          ),
                        ],
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (menu.hasDiscount && menu.discountPercentage > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'خصم ${menu.discountPercentage}%',
                                  style: AppTextStyles.skipButton(
                                    color: Colors.red,
                                  ).copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (oldPrice != null) ...[
                                  Text(
                                    Formatters.formatPrice(oldPrice),
                                    style: AppTextStyles.onboardingSubtitle().copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 12,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                ],
                                Text(
                                  Formatters.formatPrice(menu.price),
                                  style: AppTextStyles.skipButton(
                                    color: AppColors.primaryBlue,
                                  ).copyWith(fontSize: 16, fontWeight: FontWeight.bold, height: 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RestaurantImage extends StatelessWidget {
  const _RestaurantImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(color: AppColors.searchBackground);
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(color: AppColors.searchBackground),
      errorWidget: (_, _, _) => Container(
        color: AppColors.searchBackground,
        child: const Icon(Icons.storefront_outlined, size: 48, color: Colors.grey),
      ),
    );
  }
}