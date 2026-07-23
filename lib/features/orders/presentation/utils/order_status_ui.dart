import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Maps API order statuses to Arabic labels and colors.
abstract final class OrderStatusUi {
  static const filters = <OrderStatusFilter>[
    OrderStatusFilter(label: 'الكل', value: null),
    OrderStatusFilter(label: 'قيد الانتظار', value: 'pending'),
    OrderStatusFilter(label: 'مقبول', value: 'accepted'),
    OrderStatusFilter(label: 'قيد التحضير', value: 'preparing'),
    OrderStatusFilter(label: 'جاهز', value: 'ready'),
    OrderStatusFilter(label: 'قيد التوصيل', value: 'delivering'),
    OrderStatusFilter(label: 'تم التوصيل', value: 'delivered'),
    OrderStatusFilter(label: 'ملغي', value: 'cancelled'),
  ];

  static String label(String status) {
    return switch (status.toLowerCase()) {
      'pending' => 'قيد الانتظار',
      'accepted' => 'مقبول',
      'preparing' => 'قيد التحضير',
      'ready' => 'جاهز',
      'delivering' => 'قيد التوصيل',
      'delivered' => 'تم التوصيل',
      'cancelled' => 'ملغي',
      _ => status,
    };
  }

  static Color color(String status) {
    return switch (status.toLowerCase()) {
      'pending' => const Color(0xFFFF9800),
      'accepted' => AppColors.primaryBlue,
      'preparing' => const Color(0xFF7E57C2),
      'ready' => const Color(0xFF26A69A),
      'delivering' => const Color(0xFF42A5F5),
      'delivered' => const Color(0xFF43A047),
      'cancelled' => const Color(0xFFE53935),
      _ => AppColors.subtitleGrey,
    };
  }
}

class OrderStatusFilter {
  const OrderStatusFilter({required this.label, required this.value});

  final String label;
  final String? value;
}
