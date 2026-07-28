import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.messageText,
    required super.senderId,
    required super.senderName,
    required super.senderRole,
    required super.isSentByMe,
    required super.createdAt,
  });

  /// Parses a history message payload (includes UI helper fields).
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: JsonParsers.toInt(json['id']),
      messageText: json['messageText']?.toString() ?? '',
      senderId: JsonParsers.toInt(json['senderId']),
      senderName: json['senderName']?.toString() ?? '',
      senderRole: json['senderRole']?.toString() ?? '',
      isSentByMe: JsonParsers.toBool(json['isSentByMe']),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  /// Parses the nested message returned by POST /customer/message (fewer fields).
  factory ChatMessageModel.fromSendResponse(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: JsonParsers.toInt(json['id']),
      messageText: json['messageText']?.toString() ?? '',
      senderId: JsonParsers.toInt(json['senderId']),
      senderName: json['senderName']?.toString() ?? '',
      senderRole: json['senderRole']?.toString() ?? 'CUSTOMER',
      isSentByMe: json['isSentByMe'] != null
          ? JsonParsers.toBool(json['isSentByMe'])
          : true,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'messageText': messageText,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'isSentByMe': isSentByMe,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  ChatMessage toEntity() => ChatMessage(
        id: id,
        messageText: messageText,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        isSentByMe: isSentByMe,
        createdAt: createdAt,
      );
}
