import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';

class CheckoutBottomBar extends StatelessWidget {
  const CheckoutBottomBar({
    super.key,
    required this.total,
    required this.isSubmitting,
    required this.enabled,
    required this.onConfirm,
  });

  final double total;
  final bool isSubmitting;
  final bool enabled;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'المبلغ المستحق',
                    style: AppTextStyles.onboardingSubtitle(
                      color: Colors.black54,
                    ).copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.formatPrice(total),
                    style: AppTextStyles.skipButton(
                      color: AppColors.primaryBlue,
                    ).copyWith(fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 170,
              height: 52,
              child: FilledButton(
                onPressed: enabled ? onConfirm : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor:
                      AppColors.primaryBlue.withValues(alpha: 0.45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        'تأكيد الطلب',
                        style: AppTextStyles.primaryButton(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
