import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/notification_item.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final NotificationItem notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.read;

    return Material(
      color: isUnread
          ? AppColors.reviewsBackground
          : AppColors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isUnread ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isUnread
                      ? AppColors.primaryBlue.withValues(alpha: 0.12)
                      : AppColors.searchBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForType(notification.type),
                  size: 22,
                  color: isUnread
                      ? AppColors.primaryBlue
                      : AppColors.subtitleGrey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.skipButton(
                              color: Colors.black87,
                            ).copyWith(
                              fontSize: 15,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: AppTextStyles.onboardingSubtitle(
                        color: Colors.black54,
                      ).copyWith(
                        fontSize: 13,
                        fontWeight: isUnread
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                    if (notification.createdAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(notification.createdAt!),
                        style: AppTextStyles.onboardingSubtitle(
                          color: AppColors.subtitleGrey,
                        ).copyWith(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'new_order' || 'order_confirmed' => Icons.receipt_long_rounded,
      'payment' => Icons.payments_outlined,
      'welcome' => Icons.waving_hand_outlined,
      'system' => Icons.info_outline_rounded,
      _ => Icons.notifications_outlined,
    };
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/${local.year} • $hour:$minute';
  }
}
