import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/notification_item.dart';

class NotificationModel extends NotificationItem {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.message,
    required super.type,
    required super.read,
    required super.createdAt,
    super.referenceId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: JsonParsers.toInt(json['id']),
      userId: JsonParsers.toInt(json['userId']),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      referenceId: json['referenceId'] == null
          ? null
          : JsonParsers.toInt(json['referenceId']),
      read: JsonParsers.toBool(json['read']),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'referenceId': referenceId,
        'read': read,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  NotificationItem toEntity() => NotificationItem(
        id: id,
        userId: userId,
        title: title,
        message: message,
        type: type,
        referenceId: referenceId,
        read: read,
        createdAt: createdAt,
      );
}
