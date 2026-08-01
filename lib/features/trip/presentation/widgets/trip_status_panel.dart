import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/trip.dart';
import 'trip_map_placeholder.dart';
import 'trip_route_map.dart';

/// Status banner + actions for an active trip lifecycle step.
class TripStatusPanel extends StatelessWidget {
  const TripStatusPanel({
    super.key,
    required this.trip,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onCancel,
    this.showCancel = false,
  });

  final Trip trip;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onCancel;
  final bool showCancel;

  bool get _hasMapCoords =>
      trip.pickupLat != null &&
      trip.pickupLng != null &&
      trip.dropoffLat != null &&
      trip.dropoffLng != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_hasMapCoords)
          TripRouteMap(
            pickupLat: trip.pickupLat,
            pickupLng: trip.pickupLng,
            dropoffLat: trip.dropoffLat,
            dropoffLng: trip.dropoffLng,
          )
        else
          const TripMapPlaceholder(),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.reviewsBackground,
                child: Icon(icon, size: 32, color: AppColors.primaryBlue),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTextStyles.onboardingTitle(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTextStyles.onboardingSubtitle(),
                textAlign: TextAlign.center,
              ),
              if (trip.pickupAddress != null || trip.dropoffAddress != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                if (trip.pickupAddress != null)
                  _RouteRow(
                    icon: Icons.my_location,
                    label: trip.pickupAddress!,
                  ),
                if (trip.dropoffAddress != null) ...[
                  const SizedBox(height: 8),
                  _RouteRow(
                    icon: Icons.location_on_outlined,
                    label: trip.dropoffAddress!,
                  ),
                ],
                if (trip.fareAmount != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'الأجرة المتوقعة: ${trip.fareAmount!.toStringAsFixed(0)} ج.م',
                    style: AppTextStyles.skipButton(),
                  ),
                ],
              ],
            ],
          ),
        ),
        if (showCancel && onCancel != null) ...[
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade300),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'إلغاء الرحلة',
              style: AppTextStyles.primaryButton(color: Colors.red.shade700),
            ),
          ),
        ],
      ],
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.onboardingSubtitle(),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

/// Completed trip summary with rate CTA.
class TripCompletedPanel extends StatelessWidget {
  const TripCompletedPanel({
    super.key,
    required this.trip,
    required this.paymentAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.onRate,
    required this.onNewTrip,
  });

  final Trip trip;
  final double paymentAmount;
  final String paymentMethod;
  final String paymentStatus;
  final VoidCallback onRate;
  final VoidCallback onNewTrip;

  bool get _hasMapCoords =>
      trip.pickupLat != null &&
      trip.pickupLng != null &&
      trip.dropoffLat != null &&
      trip.dropoffLng != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_hasMapCoords)
          TripRouteMap(
            height: 160,
            pickupLat: trip.pickupLat,
            pickupLng: trip.pickupLng,
            dropoffLat: trip.dropoffLat,
            dropoffLng: trip.dropoffLng,
          )
        else
          const TripMapPlaceholder(height: 160),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle,
                size: 56,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              Text(
                'تم إنهاء الرحلة',
                style: AppTextStyles.onboardingTitle(),
              ),
              const SizedBox(height: 16),
              _InfoRow(
                label: 'المبلغ',
                value: '${paymentAmount.toStringAsFixed(0)} ج.م',
              ),
              _InfoRow(label: 'طريقة الدفع', value: paymentMethod),
              _InfoRow(label: 'حالة الدفع', value: paymentStatus),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(label: 'تقييم السائق', onPressed: onRate),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onNewTrip,
          child: Text(
            'طلب رحلة جديدة',
            style: AppTextStyles.skipButton(),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: AppTextStyles.skipButton()),
          Text(label, style: AppTextStyles.onboardingSubtitle()),
        ],
      ),
    );
  }
}
