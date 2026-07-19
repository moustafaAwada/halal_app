import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../cubit/onboarding_cubit.dart';
import 'onboarding_hero_image.dart';

class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({super.key, required this.page});

  final OnboardingPageData page;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final imageMaxHeight = screenHeight * 0.42;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              SizedBox(height: screenHeight * 0.02),
              TweenAnimationBuilder<double>(
                key: ValueKey('${page.title}_image'),
                tween: Tween(begin: 0.88, end: 1.0),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: OnboardingHeroImage(
                  page: page,
                  maxHeight: imageMaxHeight,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              TweenAnimationBuilder<double>(
                key: ValueKey('${page.title}_text'),
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 18 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth,
                  ),
                  child: Column(
                    children: [
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.onboardingTitle(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        page.subtitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.onboardingSubtitle().copyWith(
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
            ],
          );
        },
      ),
    );
  }
}
