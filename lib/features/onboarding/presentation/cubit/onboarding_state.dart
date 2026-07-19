part of 'onboarding_cubit.dart';

class OnboardingPageData extends Equatable {
  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.placeholderIcon,
    required this.placeholderLabel,
    this.imageAlignment = Alignment.center,
    this.imageScale = 1.0,
    this.imageFit = BoxFit.contain,
    this.imagePadding = const EdgeInsets.all(20),
  });

  final String title;
  final String subtitle;
  final String imageAsset;
  final IconData placeholderIcon;
  final String placeholderLabel;
  final Alignment imageAlignment;
  final double imageScale;
  final BoxFit imageFit;
  final EdgeInsets imagePadding;

  @override
  List<Object?> get props => [
        title,
        subtitle,
        imageAsset,
        placeholderIcon,
        placeholderLabel,
        imageAlignment,
        imageScale,
        imageFit,
        imagePadding,
      ];
}

sealed class OnboardingState extends Equatable {
  const OnboardingState({
    required this.currentPage,
    required this.pages,
  });

  final int currentPage;
  final List<OnboardingPageData> pages;

  bool get isLastPage => currentPage == pages.length - 1;

  @override
  List<Object?> get props => [currentPage, pages];
}

final class OnboardingInitial extends OnboardingState {
  const OnboardingInitial({
    required super.currentPage,
    required super.pages,
  });
}
