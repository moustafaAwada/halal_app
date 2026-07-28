import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';

class ChatShimmer extends StatelessWidget {
  const ChatShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: 6,
      itemBuilder: (context, index) {
        final isMine = index.isEven;
        return Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Shimmer.fromColors(
            baseColor: AppColors.searchBackground,
            highlightColor: AppColors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              width: MediaQuery.sizeOf(context).width * (isMine ? 0.55 : 0.65),
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }
}
