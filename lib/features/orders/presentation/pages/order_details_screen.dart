import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../home/presentation/widgets/home_shimmer.dart';
import '../../domain/entities/order_details.dart';
import '../cubit/order_details_cubit.dart';
import '../utils/order_status_ui.dart';
import '../widgets/billing_summary_card.dart';
import '../widgets/order_items_list.dart';
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
        appBar: AppBar(
          backgroundColor: AppColors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            color: Colors.black87,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'تفاصيل الطلب #$orderId',
            style: AppTextStyles.skipButton(color: Colors.black87)
                .copyWith(fontSize: 18),
          ),
        ),
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
              OrderDetailsError(:final message) => HomeErrorView(
                  message: message,
                  onRetry: () =>
                      context.read<OrderDetailsCubit>().retry(orderId),
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
    final statusColor = OrderStatusUi.color(details.status);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Container(
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
                      OrderStatusUi.label(details.status),
                      style: AppTextStyles.skipButton(color: statusColor)
                          .copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'وقت التحضير: ${details.preparationTime} دقيقة',
                      style: AppTextStyles.onboardingSubtitle(
                        color: Colors.black54,
                      ).copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المطعم',
                style: AppTextStyles.skipButton(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Text(
                details.restaurant.nameAr.isNotEmpty
                    ? details.restaurant.nameAr
                    : details.restaurant.nameEn,
                style: AppTextStyles.skipButton(color: Colors.black87)
                    .copyWith(fontSize: 16),
              ),
              if (details.restaurant.nameEn.isNotEmpty &&
                  details.restaurant.nameAr.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  details.restaurant.nameEn,
                  style: AppTextStyles.onboardingSubtitle(color: Colors.black54),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 18,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    details.restaurant.phone,
                    style:
                        AppTextStyles.onboardingSubtitle(color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OrderItemsList(items: details.items),
        const SizedBox(height: 16),
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
    );
  }
}
