import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/order_item.dart';

class OrderItemsList extends StatelessWidget {
  const OrderItemsList({super.key, required this.items});

  final List<OrderItem> items;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'المنتجات',
            style: AppTextStyles.skipButton(color: Colors.black87),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OrderItemTile(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final addonsText = item.addons.map((addon) => addon.name).join('، ');

    return Row(
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
                style: AppTextStyles.onboardingSubtitle(color: Colors.black54)
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
    );
  }
}
