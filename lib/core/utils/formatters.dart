/// Shared formatting helpers for UI display.
abstract final class Formatters {
  static String formatPrice(num value) {
    final rounded = value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
    return '$rounded ج.م';
  }

  static String formatBuyersCount(int count) {
    if (count >= 1000000) {
      return '+${(count / 1000000).toStringAsFixed(1)}m مشتري';
    }
    if (count >= 1000) {
      final value = count / 1000;
      final formatted = value >= 10 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
      return '+${formatted}k مشتري';
    }
    return '+$count مشتري';
  }

  static String formatRelativeDateAr(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'منذ دقائق';
      }
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    }
    if (difference.inDays == 1) {
      return 'منذ يوم';
    }
    if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    }
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'منذ $weeks ${weeks == 1 ? 'أسبوع' : 'أسابيع'}';
    }
    return 'منذ ${(difference.inDays / 30).floor()} شهر';
  }

  static String userInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }
}
