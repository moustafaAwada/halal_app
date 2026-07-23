import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/user_profile.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'بيانات الحساب',
            style: AppTextStyles.skipButton(color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'الاسم', value: profile.name),
          _InfoRow(label: 'البريد الإلكتروني', value: profile.email),
          _InfoRow(label: 'رقم الهاتف', value: profile.phone),
          _InfoRow(label: 'العنوان', value: profile.address),
          _InfoRow(label: 'المدينة', value: profile.city),
          if (profile.createdAt != null) ...[
            const SizedBox(height: 4),
            _InfoRow(
              label: 'تاريخ الانضمام',
              value: _formatDate(profile.createdAt!),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '${date.year}/$month/$day';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty ? 'غير محدد' : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyles.onboardingSubtitle(color: Colors.black54)
                  .copyWith(fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: AppTextStyles.skipButton(color: Colors.black87)
                  .copyWith(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
