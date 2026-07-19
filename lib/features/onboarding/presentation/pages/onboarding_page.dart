import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/page_indicator.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/onboarding_cubit.dart';
import '../widgets/onboarding_page_content.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed(BuildContext context, OnboardingState state) {
    if (state.isLastPage) {
      AppRouter.goToLogin(context);
      return;
    }

    final cubit = context.read<OnboardingCubit>();
    final nextIndex = cubit.getNextPageIndex();
    if (nextIndex == null) return;

    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OnboardingCubit>(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.white,
                  AppColors.white.withValues(
                    alpha: 0.95,
                  ),
                ],
              ),
            ),
            child: SafeArea(
              child: BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  return Stack(
                    children: [
                      // Main Content
                      Column(
                        children: [
                          AnimatedOpacity(
                            opacity: state.isLastPage ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: IgnorePointer(
                              ignoring: state.isLastPage,
                              child: _SkipBar(
                                onSkip: () => AppRouter.goToLogin(context),
                              ),
                            ),
                          ),
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: state.pages.length,
                              onPageChanged: context
                                  .read<OnboardingCubit>()
                                  .onPageChanged,
                              itemBuilder: (context, index) {
                                return OnboardingPageContent(
                                  page: state.pages[index],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),

                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.white,
                                AppColors.white.withValues(alpha: 0.0),
                              ],
                              stops: const [
                                0.6,
                                1.0,
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PageIndicator(
                                count: state.pages.length,
                                activeIndex: state.currentPage,
                              ),
                              const SizedBox(height: 32),
                              PrimaryButton(
                                label: state.isLastPage
                                    ? 'ابدأ الآن'
                                    : 'التالي',
                                onPressed: () => _onNextPressed(context, state),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkipBar extends StatelessWidget {
  const _SkipBar({required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: TextButton(
          onPressed: onSkip,
          style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
          child: Text('تخطي', style: AppTextStyles.skipButton()),
        ),
      ),
    );
  }
}
