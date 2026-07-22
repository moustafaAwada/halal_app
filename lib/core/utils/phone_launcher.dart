import 'package:url_launcher/url_launcher.dart';

/// Opens phone dialer and WhatsApp using platform URL schemes.
abstract final class PhoneLauncher {
  static String _digitsOnly(String value) =>
      value.replaceAll(RegExp(r'[^\d+]'), '');

  static String _whatsappNumber(String phone) {
    var normalized = _digitsOnly(phone);

    if (normalized.startsWith('+')) {
      normalized = normalized.substring(1);
    } else if (normalized.startsWith('00')) {
      normalized = normalized.substring(2);
    } else if (normalized.startsWith('0')) {
      normalized = '20${normalized.substring(1)}';
    }

    return normalized;
  }

  static Future<bool> call(String phone) async {
    final normalized = _digitsOnly(phone);
    if (normalized.isEmpty) return false;

    final uri = Uri(scheme: 'tel', path: normalized);
    return _launch(uri);
  }

  static Future<bool> openWhatsApp(String phone) async {
    final normalized = _whatsappNumber(phone);
    if (normalized.isEmpty) return false;

    final whatsAppUri = Uri.parse('https://wa.me/$normalized');
    if (await _launch(whatsAppUri, external: true)) {
      return true;
    }

    final fallbackUri = Uri.parse('whatsapp://send?phone=$normalized');
    return _launch(fallbackUri, external: true);
  }

  static Future<bool> _launch(Uri uri, {bool external = false}) async {
    final mode = external ? LaunchMode.externalApplication : LaunchMode.platformDefault;

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: mode);
    }

    return launchUrl(uri, mode: mode);
  }
}
