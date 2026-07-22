import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CheckoutHintBanner extends StatelessWidget {
  const CheckoutHintBanner({
    super.key,
    required this.text,
    this.isWarning = false,
  });

  final String text;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isWarning
            ? const Color(0xFFFFF6E8)
            : AppColors.reviewsBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            isWarning
                ? Icons.info_outline_rounded
                : Icons.lock_outline_rounded,
            size: 18,
            color: isWarning
                ? const Color(0xFFE0A100)
                : AppColors.primaryBlue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.onboardingSubtitle(
                color: Colors.black54,
              ).copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
