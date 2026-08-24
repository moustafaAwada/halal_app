import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/notification_item.dart';
import 'alert_ui_helpers.dart';

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
    final visual = AlertUiHelpers.alertVisualFor(notification);

    return Material(
      color: isUnread
          ? visual.backgroundColor.withValues(alpha: 0.35)
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
                      ? visual.backgroundColor
                      : AppColors.searchBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  visual.icon,
                  size: 22,
                  color: isUnread ? visual.color : AppColors.subtitleGrey,
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
                            decoration: BoxDecoration(
                              color: visual.color,
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
                        AlertUiHelpers.formatAlertTime(notification.createdAt),
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
}
