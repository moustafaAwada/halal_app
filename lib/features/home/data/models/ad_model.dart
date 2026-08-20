import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/ad.dart';

class AdModel extends Ad {
  const AdModel({
    required super.id,
    required super.title,
    required super.targetUrl,
    required super.placement,
    required super.startDate,
    required super.durationDays,
    required super.image,
    super.notes,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: JsonParsers.toInt(json['id']),
      title: _asString(json['title']),
      targetUrl: _asNullableString(json['target_url'] ?? json['targetUrl']),
      placement: _asString(json['placement']),
      startDate: _asDateTime(json['start_date'] ?? json['startDate']),
      durationDays: JsonParsers.toInt(
        json['duration_days'] ?? json['durationDays'],
      ),
      notes: _asNullableString(json['notes']),
      image: _asImageUrl(
        json['image'] ?? json['image_url'] ?? json['imageUrl'],
      ),
    );
  }

  Ad toEntity() => Ad(
        id: id,
        title: title,
        targetUrl: targetUrl,
        placement: placement,
        startDate: startDate,
        durationDays: durationDays,
        notes: notes,
        image: image,
      );

  static String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static String? _asNullableString(dynamic value) {
    final parsed = _asString(value);
    return parsed.isEmpty ? null : parsed;
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }
    return null;
  }

  static String _asImageUrl(dynamic value) {
    if (value is String) return value.trim();
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      return _asString(map['url'] ?? map['path'] ?? map['src']);
    }
    return '';
  }
}
