import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.searchBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.subtitleGrey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.onboardingSubtitle(
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن مطاعم أو أكلات...',
                        hintStyle: AppTextStyles.onboardingSubtitle(),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: onChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // const SizedBox(width: 12),
          // Material(
          //   color: AppColors.primaryBlue,
          //   borderRadius: BorderRadius.circular(14),
          //   child: InkWell(
          //     onTap: () {},
          //     borderRadius: BorderRadius.circular(14),
          //     child: const SizedBox(
          //       width: 52,
          //       height: 52,
          //       child: Icon(Icons.tune_rounded, color: AppColors.white),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
