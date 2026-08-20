import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/driver_info.dart';
import '../../domain/entities/trip.dart';

/// A full tracking card shown when a driver has been assigned.
/// Displays the driver info card, trip route summary, and action buttons.
///
/// Used for [DriverAccepted], [DriverArrived], and [TripInProgress] states.
class TripDriverCard extends StatelessWidget {
  const TripDriverCard({
    super.key,
    required this.trip,
    required this.statusLabel,
    required this.statusSubtitle,
    required this.statusColor,
    required this.statusIcon,
    this.onCancel,
    this.showCancel = false,
  });

  final Trip trip;
  final String statusLabel;
  final String statusSubtitle;
  final Color statusColor;
  final IconData statusIcon;
  final VoidCallback? onCancel;
  final bool showCancel;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Status banner ────────────────────────────────────────────────
          _StatusBanner(
            label: statusLabel,
            subtitle: statusSubtitle,
            color: statusColor,
            icon: statusIcon,
          ),
          const SizedBox(height: 16),

          // ── Driver Info Card (shown only when driver is assigned) ─────────
          if (trip.driver != null) ...[
            _DriverInfoCard(
              driver: trip.driver!,
              onCallDriver: () => _callDriver(trip.driver!.phone),
              onCancel: showCancel ? onCancel : null,
            ),
            const SizedBox(height: 16),
          ],

          // ── Trip Route Summary Card ──────────────────────────────────────
          if (trip.pickupAddress != null || trip.dropoffAddress != null)
            _TripRouteSummaryCard(trip: trip),

          if (showCancel && onCancel != null && trip.driver == null) ...[
            const SizedBox(height: 20),
            _CancelButton(onCancel: onCancel!),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _callDriver(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

// ─── Status Banner ────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String label;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.skipButton(color: color)
                      .copyWith(fontSize: 17),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.onboardingSubtitle().copyWith(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Driver Info Card ─────────────────────────────────────────────────────────

class _DriverInfoCard extends StatelessWidget {
  const _DriverInfoCard({
    required this.driver,
    required this.onCallDriver,
    this.onCancel,
  });

  final DriverInfo driver;
  final VoidCallback onCallDriver;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Driver Identity Row ──────────────────────────────────────────
          Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.reviewsBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 34,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name.isNotEmpty ? driver.name : 'السائق',
                      style: AppTextStyles.skipButton(
                        color: const Color(0xFF111827),
                      ).copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (driver.vehicleDescription.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        driver.vehicleDescription,
                        style: AppTextStyles.onboardingSubtitle().copyWith(
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),

          // ── Action Buttons ───────────────────────────────────────────────
          Row(
            children: [
              // Call Driver (primary)
              Expanded(
                flex: 3,
                child: FilledButton.icon(
                  onPressed: onCallDriver,
                  icon: const Icon(Icons.call_rounded, size: 20),
                  label: const Text('اتصل بالسائق'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: AppTextStyles.primaryButton().copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (onCancel != null) ...[
                const SizedBox(width: 10),
                // Cancel (secondary)
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'إلغاء',
                      style: AppTextStyles.skipButton(
                        color: Colors.red.shade600,
                      ).copyWith(fontSize: 15),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Trip Route Summary Card ──────────────────────────────────────────────────

class _TripRouteSummaryCard extends StatelessWidget {
  const _TripRouteSummaryCard({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Fare amount row
          if (trip.fareAmount != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الأجرة المتوقعة',
                  style: AppTextStyles.onboardingSubtitle().copyWith(
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${trip.fareAmount!.toStringAsFixed(0)} ج.م',
                  style: AppTextStyles.skipButton(
                    color: const Color(0xFF111827),
                  ).copyWith(fontSize: 16),
                ),
              ],
            ),
            if (trip.durationMinutes != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الوقت المتوقع',
                    style: AppTextStyles.onboardingSubtitle().copyWith(
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${trip.durationMinutes} دقيقة',
                    style: AppTextStyles.onboardingSubtitle().copyWith(
                      fontSize: 13,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 14),
          ],

          // Pickup → Dropoff with dashed connector
          if (trip.pickupAddress != null) ...[
            _RouteStopRow(
              icon: Icons.my_location_rounded,
              iconColor: AppColors.primaryBlue,
              label: trip.pickupAddress!,
            ),
          ],
          if (trip.pickupAddress != null && trip.dropoffAddress != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Column(
                children: List.generate(
                  3,
                  (_) => Container(
                    width: 2,
                    height: 6,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (trip.dropoffAddress != null) ...[
            _RouteStopRow(
              icon: Icons.location_on_rounded,
              iconColor: const Color(0xFFEF4444),
              label: trip.dropoffAddress!,
            ),
          ],
        ],
      ),
    );
  }
}

class _RouteStopRow extends StatelessWidget {
  const _RouteStopRow({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.skipButton(
              color: const Color(0xFF374151),
            ).copyWith(fontSize: 14, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Cancel Button (standalone, for when there's no driver card yet) ──────────

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onCancel});
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onCancel,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red.shade700,
        side: BorderSide(color: Colors.red.shade300),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        'إلغاء الرحلة',
        style: AppTextStyles.primaryButton(color: Colors.red.shade700),
      ),
    );
  }
}
