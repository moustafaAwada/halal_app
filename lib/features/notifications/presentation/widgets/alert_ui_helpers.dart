import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/notification_item.dart';

class AlertVisual {
  const AlertVisual({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
}

class AlertUiHelpers {
  AlertUiHelpers._();

  /// Groups notifications into sections: Today, Yesterday, This Week, Earlier.
  static Map<String, List<NotificationItem>> groupAlerts(
    List<NotificationItem> alerts,
  ) {
    final Map<String, List<NotificationItem>> grouped = {
      'اليوم': [],
      'أمس': [],
      'هذا الأسبوع': [],
      'أقدم': [],
    };

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final startOfWeek = today.subtract(Duration(days: now.weekday - 1));

    for (final alert in alerts) {
      final date = alert.createdAt?.toLocal();
      if (date == null) {
        grouped['أقدم']!.add(alert);
        continue;
      }

      final alertDay = DateTime(date.year, date.month, date.day);

      if (alertDay == today) {
        grouped['اليوم']!.add(alert);
      } else if (alertDay == yesterday) {
        grouped['أمس']!.add(alert);
      } else if (alertDay.isAfter(startOfWeek) || alertDay == startOfWeek) {
        grouped['هذا الأسبوع']!.add(alert);
      } else {
        grouped['أقدم']!.add(alert);
      }
    }

    // Remove empty sections
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }

  /// Determines icon and color styling based on notification content/type keywords.
  static AlertVisual alertVisualFor(NotificationItem alert) {
    final text = '${alert.type} ${alert.title} ${alert.message}'.toLowerCase();

    if (text.contains('cancel') ||
        text.contains('reject') ||
        text.contains('إلغاء') ||
        text.contains('رفض')) {
      return AlertVisual(
        icon: Icons.highlight_off_rounded,
        color: const Color(0xFFE53935),
        backgroundColor: const Color(0xFFFFEBEE),
      );
    }

    if (text.contains('review') ||
        text.contains('rating') ||
        text.contains('تقييم') ||
        text.contains('رأي')) {
      return AlertVisual(
        icon: Icons.star_rounded,
        color: const Color(0xFFFB8C00),
        backgroundColor: const Color(0xFFFFF3E0),
      );
    }

    if (text.contains('payment') ||
        text.contains('paid') ||
        text.contains('دفع') ||
        text.contains('مبلغ')) {
      return AlertVisual(
        icon: Icons.payments_rounded,
        color: const Color(0xFF43A047),
        backgroundColor: const Color(0xFFE8F5E9),
      );
    }

    if (text.contains('order') ||
        text.contains('طلب') ||
        text.contains('شراء')) {
      return AlertVisual(
        icon: Icons.receipt_long_rounded,
        color: AppColors.primaryBlue,
        backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
      );
    }

    return AlertVisual(
      icon: Icons.notifications_active_rounded,
      color: AppColors.primaryBlue,
      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
    );
  }

  /// Formats relative time strings (e.g. "الآن", "منذ 5 دقائق", "منذ ساعتين", etc.).
  static String formatAlertTime(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date.toLocal());

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      if (mins == 1) return 'منذ دقيقة واحدة';
      if (mins == 2) return 'منذ دقيقتين';
      if (mins >= 3 && mins <= 10) return 'منذ $mins دقائق';
      return 'منذ $mins دقيقة';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      if (hours == 1) return 'منذ ساعة واحدة';
      if (hours == 2) return 'منذ ساعتين';
      if (hours >= 3 && hours <= 10) return 'منذ $hours ساعات';
      return 'منذ $hours ساعة';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      if (days == 1) return 'أمس';
      if (days == 2) return 'منذ يومين';
      if (days >= 3 && days <= 10) return 'منذ $days أيام';
      return 'منذ $days يوم';
    } else {
      final d = date.toLocal();
      final day = d.day.toString().padLeft(2, '0');
      final month = d.month.toString().padLeft(2, '0');
      return '$day/$month/${d.year}';
    }
  }
}
