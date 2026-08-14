import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../trip/domain/entities/trip.dart';
import '../cubit/advanced_cubit.dart';

/// Minimal driver-ready nearby trips list (no full driver shell).
class NearbyTripsList extends StatelessWidget {
  const NearbyTripsList({
    super.key,
    this.onTripTap,
  });

  final ValueChanged<Trip>? onTripTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdvancedCubit, AdvancedState>(
      builder: (context, state) {
        if (state is AdvancedLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdvancedError) {
          return Text(
            state.message,
            style: AppTextStyles.onboardingSubtitle(color: Colors.red),
            textAlign: TextAlign.center,
          );
        }

        if (state is! AdvancedNearbyLoaded) {
          return Text(
            'لا توجد رحلات قريبة حالياً',
            style: AppTextStyles.onboardingSubtitle(),
            textAlign: TextAlign.center,
          );
        }

        if (state.trips.isEmpty) {
          return Text(
            'لا توجد رحلات ضمن النطاق',
            style: AppTextStyles.onboardingSubtitle(),
            textAlign: TextAlign.center,
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.trips.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final trip = state.trips[index];
            return Material(
              color: AppColors.searchBackground,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: onTripTap == null ? null : () => onTripTap!(trip),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رحلة #${trip.id}',
                        style: AppTextStyles.skipButton(color: Colors.black87),
                      ),
                      if (trip.pickupAddress != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'من: ${trip.pickupAddress}',
                          style: AppTextStyles.onboardingSubtitle(),
                        ),
                      ],
                      if (trip.dropoffAddress != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'إلى: ${trip.dropoffAddress}',
                          style: AppTextStyles.onboardingSubtitle(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
