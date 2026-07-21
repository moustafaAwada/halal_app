import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';

class HomeErrorView extends StatelessWidget {
  const HomeErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'إعادة المحاولة',
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.inactiveDot.withValues(alpha: 0.35),
      highlightColor: AppColors.white,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          const SizedBox(height: 16),
          _box(height: 56, margin: const EdgeInsets.symmetric(horizontal: 20)),
          const SizedBox(height: 16),
          _box(height: 52, margin: const EdgeInsets.symmetric(horizontal: 20)),
          _sectionTitle(),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 2,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, _) => _box(height: 180, width: 280, radius: 20),
            ),
          ),
          _sectionTitle(),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, _) => _box(height: 210, width: 160, radius: 18),
            ),
          ),
          _sectionTitle(),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: _box(height: 96, radius: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _box(height: 140, radius: 18),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Expanded(child: _box(height: 22, radius: 8)),
          const SizedBox(width: 40),
          _box(height: 18, width: 60, radius: 8),
        ],
      ),
    );
  }

  Widget _box({
    required double height,
    double? width,
    EdgeInsetsGeometry? margin,
    double radius = 14,
  }) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
