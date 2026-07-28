import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/chat_history.dart';
import 'chat_message_model.dart';

class ChatHistoryModel extends ChatHistory {
  const ChatHistoryModel({
    required super.messages,
    required super.count,
    super.ticketId,
    super.status,
    super.infoMessage,
  });

  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final messages = <ChatMessageModel>[];

    if (data is List) {
      for (final item in data) {
        if (item is Map) {
          messages.add(
            ChatMessageModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final ticketIdRaw = json['ticketId'];
    final infoMessage = json['message']?.toString();

    return ChatHistoryModel(
      ticketId: ticketIdRaw == null ? null : JsonParsers.toInt(ticketIdRaw),
      status: json['status']?.toString(),
      count: json['count'] != null
          ? JsonParsers.toInt(json['count'])
          : messages.length,
      messages: messages,
      infoMessage: (infoMessage != null && infoMessage.isNotEmpty)
          ? infoMessage
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (ticketId != null) 'ticketId': ticketId,
        if (status != null) 'status': status,
        'count': count,
        if (infoMessage != null) 'message': infoMessage,
        'data': messages
            .map((m) => (m as ChatMessageModel).toJson())
            .toList(),
      };

  ChatHistory toEntity() => ChatHistory(
        ticketId: ticketId,
        status: status,
        count: count,
        messages: messages
            .map((m) => (m as ChatMessageModel).toEntity())
            .toList(),
        infoMessage: infoMessage,
      );
}
