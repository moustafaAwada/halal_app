import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ad.dart';
import '../cubit/ads_cubit.dart';
import 'ad_card_widget.dart';

/// Home ads section: loading shimmer, horizontal carousel, or hidden if empty.
class HomeAdsBanner extends StatelessWidget {
  const HomeAdsBanner({super.key});

  static const double _bannerHeight = 148;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdsCubit, AdsState>(
      builder: (context, state) {
        return switch (state) {
          AdsInitial() || AdsLoading() => const _AdsBannerShimmer(
              height: _bannerHeight,
            ),
          AdsError() => const SizedBox.shrink(),
          AdsLoaded(:final ads) => ads.isEmpty
              ? const SizedBox.shrink()
              : _AdsCarousel(ads: ads, height: _bannerHeight),
        };
      },
    );
  }
}

class _AdsCarousel extends StatelessWidget {
  const _AdsCarousel({
    required this.ads,
    required this.height,
  });

  final List<Ad> ads;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (ads.length == 1) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: AdCardWidget(ad: ads.first, height: height),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: ads.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final screenWidth = MediaQuery.sizeOf(context).width;
            return AdCardWidget(
              ad: ads[index],
              width: screenWidth - 56,
              height: height,
            );
          },
        ),
      ),
    );
  }
}

class _AdsBannerShimmer extends StatelessWidget {
  const _AdsBannerShimmer({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Shimmer.fromColors(
        baseColor: AppColors.inactiveDot.withValues(alpha: 0.35),
        highlightColor: AppColors.white,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.inactiveDot,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
