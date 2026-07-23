import 'dart:convert';

import 'json_parsers.dart';

/// Helpers for reading common claims from JWT access tokens.
abstract final class JwtUtils {
  static int? extractUserId(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;

      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded);
      if (json is! Map) return null;

      final map = Map<String, dynamic>.from(json);
      final id = JsonParsers.toInt(
        map['user_id'] ?? map['userId'] ?? map['id'] ?? map['sub'],
      );

      return id > 0 ? id : null;
    } catch (_) {
      return null;
    }
  }
}
