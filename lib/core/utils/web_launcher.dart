import 'package:url_launcher/url_launcher.dart';

/// Opens http(s) URLs in the browser or an in-app web view.
abstract final class WebLauncher {
  static Future<bool> open(String? rawUrl) async {
    final uri = _parseHttpUrl(rawUrl);
    if (uri == null) return false;

    try {
      if (await canLaunchUrl(uri)) {
        return launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      return launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } catch (_) {
      return false;
    }
  }

  static Uri? _parseHttpUrl(String? rawUrl) {
    final trimmed = rawUrl?.trim() ?? '';
    if (trimmed.isEmpty) return null;

    final parsed = Uri.tryParse(trimmed);
    if (parsed == null) return null;

    if (parsed.hasScheme) {
      if (parsed.isScheme('http') || parsed.isScheme('https')) {
        return parsed;
      }
      return null;
    }

    return Uri.tryParse('https://$trimmed');
  }
}
