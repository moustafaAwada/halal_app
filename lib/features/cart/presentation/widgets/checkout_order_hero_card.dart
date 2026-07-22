import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';

class CheckoutOrderHeroCard extends StatelessWidget {
  const CheckoutOrderHeroCard({
    super.key,
    required this.orderId,
    required this.totalPrice,
    this.vendorName,
  });

  final int orderId;
  final String? vendorName;
  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlueLight,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ملخص الطلب',
                      style: AppTextStyles.onboardingSubtitle(
                        color: AppColors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'طلب #$orderId',
                      style: AppTextStyles.skipButton(color: AppColors.white)
                          .copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (vendorName != null && vendorName!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.storefront_rounded,
                    size: 16,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      vendorName!,
                      style: AppTextStyles.onboardingSubtitle(
                        color: AppColors.white,
                      ).copyWith(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            'الإجمالي',
            style: AppTextStyles.onboardingSubtitle(
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.formatPrice(totalPrice),
            style: AppTextStyles.onboardingTitle(color: AppColors.white)
                .copyWith(fontSize: 30),
          ),
        ],
      ),
    );
  }
}
