import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/billing.dart';

class BillingSummaryCard extends StatelessWidget {
  const BillingSummaryCard({super.key, required this.billing});

  final Billing billing;

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
            'ملخص الفاتورة',
            style: AppTextStyles.skipButton(color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _BillingRow(
            label: 'المجموع الفرعي',
            value: Formatters.formatPrice(billing.subtotal),
          ),
          _BillingRow(
            label: 'رسوم التوصيل',
            value: Formatters.formatPrice(billing.deliveryFee),
          ),
          _BillingRow(
            label: 'رسوم الخدمة',
            value: Formatters.formatPrice(billing.serviceFee),
          ),
          const Divider(height: 24),
          _BillingRow(
            label: 'الإجمالي',
            value: Formatters.formatPrice(billing.totalAmount),
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _BillingRow extends StatelessWidget {
  const _BillingRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final style = isTotal
        ? AppTextStyles.skipButton(color: Colors.black87).copyWith(fontSize: 16)
        : AppTextStyles.onboardingSubtitle(color: Colors.black54)
            .copyWith(fontSize: 14);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(
            value,
            style: isTotal
                ? AppTextStyles.skipButton(color: AppColors.primaryBlue)
                    .copyWith(fontSize: 16)
                : AppTextStyles.skipButton(color: Colors.black87)
                    .copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
