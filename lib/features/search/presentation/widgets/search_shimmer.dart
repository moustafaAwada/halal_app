import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';

class SearchShimmer extends StatelessWidget {
  const SearchShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.inactiveDot.withValues(alpha: 0.35),
      highlightColor: AppColors.white,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _box(height: 56),
          const SizedBox(height: 16),
          _box(height: 52),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _box(height: 22, radius: 8)),
              const SizedBox(width: 40),
              _box(height: 18, width: 60, radius: 8),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, _) => _box(height: 44, width: 90, radius: 24),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(3, (_) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _box(height: 280, radius: 20),
              )),
        ],
      ),
    );
  }

  Widget _box({
    required double height,
    double? width,
    double radius = 14,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class SearchEmptyView extends StatelessWidget {
  const SearchEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: AppColors.primaryBlue.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد منتجات',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'جرّب البحث بكلمات مختلفة أو اختر قسماً آخر',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.subtitleGrey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
