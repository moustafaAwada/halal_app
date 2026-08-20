import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/phone_launcher.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../home/presentation/widgets/home_shimmer.dart';
import '../../domain/entities/order_details.dart';
import '../cubit/order_details_cubit.dart';
import '../utils/order_status_ui.dart';
import '../widgets/billing_summary_card.dart';
import '../widgets/rating_modal_bottom_sheet.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.searchBackground,
        body: BlocConsumer<OrderDetailsCubit, OrderDetailsState>(
          listener: (context, state) {
            if (state is OrderDetailsError) {
              SnackbarUtils.showErrorSnackBar(context, state.message);
            }
          },
          builder: (context, state) {
            return switch (state) {
              OrderDetailsInitial() || OrderDetailsLoading() =>
                const Center(child: CircularProgressIndicator()),
              OrderDetailsError(:final message) => Scaffold(
                  appBar: AppBar(
                    backgroundColor: AppColors.white,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 18),
                      color: Colors.black87,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  body: HomeErrorView(
                    message: message,
                    onRetry: () =>
                        context.read<OrderDetailsCubit>().retry(orderId),
                  ),
                ),
              OrderDetailsLoaded(:final details) => _OrderDetailsContent(
                  details: details,
                ),
            };
          },
        ),
      ),
    );
  }
}

class _OrderDetailsContent extends StatefulWidget {
  const _OrderDetailsContent({required this.details});

  final OrderDetails details;

  @override
  State<_OrderDetailsContent> createState() => _OrderDetailsContentState();
}

class _OrderDetailsContentState extends State<_OrderDetailsContent> {
  bool _ratingPromptShown = false;

  OrderDetails get details => widget.details;

  bool get _isDelivered => details.status.toLowerCase() == 'delivered';

  @override
  void initState() {
    super.initState();
    if (_isDelivered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _ratingPromptShown) return;
        _ratingPromptShown = true;
        showRatingModalBottomSheet(context, orderId: details.orderId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildRestaurantHeader(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRestaurantInfo(),
                const SizedBox(height: 16),
                _buildContactActions(context),
                const SizedBox(height: 24),
                _buildOrderStatus(),
                const SizedBox(height: 24),
                Text(
                  'المنتجات',
                  style: AppTextStyles.skipButton(color: Colors.black87),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        _buildOrderItems(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BillingSummaryCard(billing: details.billing),
                if (_isDelivered) ...[
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'قيّم الطلب',
                    onPressed: () => showRatingModalBottomSheet(
                      context,
                      orderId: details.orderId,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantHeader(BuildContext context) {
    final restaurantName = details.restaurant.nameAr.isNotEmpty
        ? details.restaurant.nameAr
        : details.restaurant.nameEn;

    return SliverAppBar(
      backgroundColor: AppColors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      expandedHeight: 220,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        color: Colors.black87,
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          restaurantName,
          style: AppTextStyles.skipButton(color: Colors.black87).copyWith(
            fontSize: 18,
            shadows: [
              const Shadow(color: Colors.white, blurRadius: 4),
            ],
          ),
        ),
        titlePadding: const EdgeInsetsDirectional.only(start: 48, bottom: 16),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover Image
            if (details.restaurant.cover.isNotEmpty)
              CachedNetworkImage(
                imageUrl: details.restaurant.cover,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.storefront, size: 48, color: Colors.grey),
                ),
              )
            else
              Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.storefront, size: 48, color: Colors.grey),
              ),
            // Gradient Overlay for text readability
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.white70],
                ),
              ),
            ),
            // Logo overlapping at the bottom
            PositionedDirectional(
              bottom: 16,
              end: 20, 
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: details.restaurant.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: details.restaurant.imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Icon(
                              Icons.restaurant, color: Colors.grey),
                        )
                      : const Icon(Icons.restaurant, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    final restaurant = details.restaurant;
    final addressParts = [
      if (restaurant.city.isNotEmpty) restaurant.city,
      if (restaurant.area.isNotEmpty) restaurant.area,
      if (restaurant.address.isNotEmpty) restaurant.address,
    ];
    final fullAddress = addressParts.join(' - ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          restaurant.nameAr.isNotEmpty ? restaurant.nameAr : restaurant.nameEn,
          style: AppTextStyles.skipButton(color: Colors.black87)
              .copyWith(fontSize: 20),
        ),
        if (restaurant.shortDescription.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            restaurant.shortDescription,
            style: AppTextStyles.onboardingSubtitle(color: Colors.black54),
          ),
        ],
        if (fullAddress.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  fullAddress,
                  style: AppTextStyles.onboardingSubtitle(color: Colors.black87)
                      .copyWith(height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildContactActions(BuildContext context) {
    final restaurant = details.restaurant;
    final hasPhone = restaurant.phone.isNotEmpty;
    final hasWhatsapp = restaurant.whatsapp.isNotEmpty;

    if (!hasPhone && !hasWhatsapp) return const SizedBox.shrink();

    return Row(
      children: [
        if (hasPhone)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => PhoneLauncher.call(restaurant.phone),
              icon: const Icon(Icons.phone_outlined, size: 18),
              label: const Text('اتصال'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: AppColors.primaryBlue),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        if (hasPhone && hasWhatsapp) const SizedBox(width: 12),
        if (hasWhatsapp)
          Expanded(
            child: FilledButton.icon(
              onPressed: () => PhoneLauncher.openWhatsApp(restaurant.whatsapp),
              icon: const Icon(Icons.chat_outlined, size: 18),
              label: const Text('واتساب'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOrderStatus() {
    final statusColor = OrderStatusUi.color(details.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.receipt_long_outlined, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طلب #${details.orderId} - ${OrderStatusUi.label(details.status)}',
                  style: AppTextStyles.skipButton(color: statusColor)
                      .copyWith(fontSize: 16),
                ),
                if (details.preparationTime > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'وقت التحضير: ${details.preparationTime} دقيقة',
                    style: AppTextStyles.onboardingSubtitle(
                      color: Colors.black54,
                    ).copyWith(fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = details.items[index];
            final addonsText = item.addons.map((addon) => addon.name).join('، ');

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.reviewsBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.fastfood_outlined,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.menuName ?? 'منتج #${item.id}',
                            style: AppTextStyles.skipButton(color: Colors.black87)
                                .copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'الكمية: ${item.quantity}'
                            '${item.sizeName != null ? ' • ${item.sizeName}' : ''}',
                            style: AppTextStyles.onboardingSubtitle(
                                    color: Colors.black54)
                                .copyWith(fontSize: 12),
                          ),
                          if (addonsText.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'إضافات: $addonsText',
                              style: AppTextStyles.onboardingSubtitle(
                                color: AppColors.subtitleGrey,
                              ).copyWith(fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      Formatters.formatPrice(item.total),
                      style: AppTextStyles.skipButton(color: AppColors.primaryBlue)
                          .copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: details.items.length,
        ),
      ),
    );
  }
}
