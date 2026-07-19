import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Capsule-and-dot pagination indicator used in onboarding.
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  static const double _dotSize = 8;
  static const double _activeWidth = 28;
  static const double _height = 8;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? _activeWidth : _dotSize,
          height: _height,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : AppColors.inactiveDot,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
