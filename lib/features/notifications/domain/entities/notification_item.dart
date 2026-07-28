import 'package:equatable/equatable.dart';

class NotificationItem extends Equatable {
  const NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
    this.referenceId,
  });

  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;

  final int? referenceId;
  final bool read;
  final DateTime? createdAt;

  NotificationItem copyWith({
    int? id,
    int? userId,
    String? title,
    String? message,
    String? type,
    int? referenceId,
    bool? read,
    DateTime? createdAt,
    bool clearReferenceId = false,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      referenceId: clearReferenceId ? null : (referenceId ?? this.referenceId),
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        message,
        type,
        referenceId,
        read,
        createdAt,
      ];
}
