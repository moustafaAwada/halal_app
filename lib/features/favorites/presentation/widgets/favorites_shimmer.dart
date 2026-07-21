import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class FavoritesShimmer extends StatelessWidget {
  const FavoritesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.inactiveDot.withValues(alpha: 0.35),
      highlightColor: AppColors.white,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => Container(
          height: 134,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class FavoritesEmptyView extends StatelessWidget {
  const FavoritesEmptyView({
    super.key,
    this.onStartShopping,
    this.onBrowseOffers,
  });

  final VoidCallback? onStartShopping;
  final VoidCallback? onBrowseOffers;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.reviewsBackground,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  const Icon(
                    Icons.lunch_dining_rounded,
                    size: 48,
                    color: AppColors.primaryBlue,
                  ),
                  Positioned(
                    left: 28,
                    bottom: 36,
                    child: Icon(
                      Icons.circle,
                      size: 14,
                      color: Colors.brown.shade400,
                    ),
                  ),
                  Positioned(
                    right: 24,
                    bottom: 32,
                    child: Icon(
                      Icons.fastfood_rounded,
                      size: 28,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'لا يوجد شيء هنا بعد',
              textAlign: TextAlign.center,
              style: AppTextStyles.onboardingTitle(color: Colors.black87)
                  .copyWith(fontSize: 22),
            ),
            const SizedBox(height: 12),
            Text(
              'ابدأ باستكشاف ألذ الوجبات والمطاعم القريبة منك وأضفها إلى سلتك.',
              textAlign: TextAlign.center,
              style: AppTextStyles.onboardingSubtitle().copyWith(
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: onStartShopping,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                label: Text(
                  'ابدأ التسوق',
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
