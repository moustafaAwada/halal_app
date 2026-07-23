import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';

class NotificationsShimmer extends StatelessWidget {
  const NotificationsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.searchBackground,
        highlightColor: AppColors.white,
        child: Container(
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
