import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/order.dart';
import '../utils/order_status_ui.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = OrderStatusUi.color(order.status);
    final itemsCount = order.items.fold<int>(0, (sum, item) => sum + item.quantity);

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'طلب #${order.id}',
                      style: AppTextStyles.skipButton(color: Colors.black87)
                          .copyWith(fontSize: 16),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      OrderStatusUi.label(order.status),
                      style: AppTextStyles.onboardingSubtitle(color: statusColor)
                          .copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '$itemsCount منتج • ${Formatters.formatPrice(order.total)}',
                style: AppTextStyles.onboardingSubtitle(color: Colors.black54)
                    .copyWith(fontSize: 13),
              ),
              if (order.createdAt != null) ...[
                const SizedBox(height: 6),
                Text(
                  _formatDate(order.createdAt!),
                  style: AppTextStyles.onboardingSubtitle(
                    color: AppColors.subtitleGrey,
                  ).copyWith(fontSize: 12),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'عرض التفاصيل',
                    style: AppTextStyles.onboardingSubtitle(
                      color: AppColors.primaryBlue,
                    ).copyWith(fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_back_ios,
                    size: 14,
                    color: AppColors.primaryBlue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}/$month/$day';
  }
}
