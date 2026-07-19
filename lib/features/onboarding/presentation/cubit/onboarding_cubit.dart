import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit()
      : super(
          const OnboardingInitial(
            currentPage: 0,
            pages: _pages,
          ),
        );

  static const List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'اختر من آلاف المطاعم',
      subtitle: 'تصفح مجموعة واسعة من المطاعم والأكلات',
      imageAsset: AppAssets.onboarding1,
      placeholderIcon: Icons.fastfood_outlined,
      placeholderLabel: 'onboarding1.png',
      imageAlignment: Alignment.bottomCenter,
      imageScale: 1.08,
      imagePadding: EdgeInsets.fromLTRB(12, 16, 12, 0),
    ),
    OnboardingPageData(
      title: 'توصيل سريع',
      subtitle: 'نصل طلبك سريعاً إلى باب منزلك',
      imageAsset: AppAssets.onboarding2,
      placeholderIcon: Icons.delivery_dining_outlined,
      placeholderLabel: 'onboarding2.png',
      imageAlignment: Alignment.center,
      imageScale: 1.15,
      imagePadding: EdgeInsets.fromLTRB(4, 24, 4, 12),
    ),
    OnboardingPageData(
      title: 'اكسب نقاط ومكافآت',
      subtitle: 'اجمع النقاط واستبدلها بعروض ومكافآت',
      imageAsset: AppAssets.onboarding3,
      placeholderIcon: Icons.card_giftcard_outlined,
      placeholderLabel: 'onboarding3.png',
      imageAlignment: Alignment.bottomCenter,
      imageScale: 1.28,
      imagePadding: EdgeInsets.fromLTRB(8, 8, 8, 0),
      imageFit: BoxFit.cover,
    ),
  ];

  void onPageChanged(int index) {
    if (index == state.currentPage) return;
    emit(OnboardingInitial(currentPage: index, pages: state.pages));
  }

  int? getNextPageIndex() {
    if (state.isLastPage) return null;
    return state.currentPage + 1;
  }
}
