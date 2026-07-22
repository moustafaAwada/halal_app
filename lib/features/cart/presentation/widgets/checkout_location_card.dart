import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'checkout_card.dart';

class CheckoutLocationCard extends StatelessWidget {
  const CheckoutLocationCard({
    super.key,
    required this.isLocating,
    required this.hasLocation,
    required this.onSelectOnMap,
    required this.onUseGps,
    this.latitude,
    this.longitude,
  });

  final bool isLocating;
  final bool hasLocation;
  final double? latitude;
  final double? longitude;
  final VoidCallback? onSelectOnMap;
  final VoidCallback? onUseGps;

  @override
  Widget build(BuildContext context) {
    return CheckoutCard(
      icon: Icons.location_on_rounded,
      title: 'موقع التوصيل',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LocationStatusBanner(
            isLocating: isLocating,
            hasLocation: hasLocation,
          ),
          if (isLocating) ...[
            const SizedBox(height: 16),
            const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          ] else if (hasLocation) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _CoordChip(
                    label: 'العرض',
                    value: latitude!.toStringAsFixed(5),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CoordChip(
                    label: 'الطول',
                    value: longitude!.toStringAsFixed(5),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: onSelectOnMap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.map_rounded),
              label: Text(
                hasLocation
                    ? 'تغيير الموقع من الخريطة'
                    : 'اختيار الموقع من الخريطة',
                style: AppTextStyles.primaryButton(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onUseGps,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: AppColors.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(
                hasLocation
                    ? Icons.refresh_rounded
                    : Icons.my_location_rounded,
              ),
              label: Text(
                'استخدام موقعي الحالي',
                style: AppTextStyles.skipButton(color: AppColors.primaryBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationStatusBanner extends StatelessWidget {
  const _LocationStatusBanner({
    required this.isLocating,
    required this.hasLocation,
  });

  final bool isLocating;
  final bool hasLocation;

  @override
  Widget build(BuildContext context) {
    final title = isLocating
        ? 'جاري تحديد الموقع...'
        : hasLocation
            ? 'تم تحديد موقع التوصيل'
            : 'الموقع غير محدد';
    final subtitle = isLocating
        ? 'يرجى الانتظار قليلاً'
        : hasLocation
            ? 'يمكنك تغييره من الخريطة في أي وقت'
            : 'اختر الموقع من الخريطة أو استخدم GPS';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasLocation
            ? const Color(0xFFE8F8EF)
            : const Color(0xFFFFF6E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasLocation
              ? const Color(0xFFB7E4C7)
              : const Color(0xFFFFE0A3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              hasLocation
                  ? Icons.check_circle_rounded
                  : Icons.location_searching_rounded,
              color: hasLocation
                  ? const Color(0xFF2E9B5E)
                  : const Color(0xFFE0A100),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.skipButton(color: Colors.black87)
                      .copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.onboardingSubtitle(
                    color: Colors.black54,
                  ).copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoordChip extends StatelessWidget {
  const _CoordChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.searchBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.onboardingSubtitle(
              color: Colors.black45,
            ).copyWith(fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.skipButton(color: Colors.black87)
                .copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
