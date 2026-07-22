import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import 'checkout_card.dart';

class CheckoutDeliveryDetailsCard extends StatelessWidget {
  const CheckoutDeliveryDetailsCard({
    super.key,
    required this.deliveryFee,
    required this.deliveryTime,
    required this.paymentMethod,
    required this.totalPrice,
  });

  final double deliveryFee;
  final String deliveryTime;
  final String paymentMethod;
  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    return CheckoutCard(
      icon: Icons.local_shipping_rounded,
      title: 'تفاصيل التوصيل',
      child: Column(
        children: [
          _DetailTile(
            icon: Icons.payments_outlined,
            label: 'رسوم التوصيل',
            value: Formatters.formatPrice(deliveryFee),
          ),
          const SizedBox(height: 10),
          _DetailTile(
            icon: Icons.schedule_rounded,
            label: 'مدة التوصيل',
            value: deliveryTime,
          ),
          const SizedBox(height: 10),
          _DetailTile(
            icon: Icons.account_balance_wallet_outlined,
            label: 'طريقة الدفع',
            value: paymentMethod,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.reviewsBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'COD',
                style: AppTextStyles.skipButton(
                  color: AppColors.primaryBlue,
                ).copyWith(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.reviewsBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'الإجمالي النهائي',
                    style: AppTextStyles.skipButton(color: Colors.black87),
                  ),
                ),
                Text(
                  Formatters.formatPrice(totalPrice),
                  style: AppTextStyles.skipButton(
                    color: AppColors.primaryBlue,
                  ).copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.searchBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.onboardingSubtitle(
                    color: Colors.black45,
                  ).copyWith(fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.skipButton(color: Colors.black87)
                      .copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
