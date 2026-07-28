import 'package:equatable/equatable.dart';

import 'chat_message.dart';

/// Full conversation snapshot for the customer's latest support ticket.
class ChatHistory extends Equatable {
  const ChatHistory({
    required this.messages,
    required this.count,
    this.ticketId,
    this.status,
    this.infoMessage,
  });

  final int? ticketId;

  /// Ticket status: OPEN, IN_PROGRESS, CLOSED (null when no ticket yet).
  final String? status;
  final int count;
  final List<ChatMessage> messages;

  /// Optional API info text (e.g. empty-history message).
  final String? infoMessage;

  bool get isEmpty => messages.isEmpty;

  ChatHistory copyWith({
    int? ticketId,
    String? status,
    int? count,
    List<ChatMessage>? messages,
    String? infoMessage,
    bool clearInfoMessage = false,
  }) {
    return ChatHistory(
      ticketId: ticketId ?? this.ticketId,
      status: status ?? this.status,
      count: count ?? this.count,
      messages: messages ?? this.messages,
      infoMessage: clearInfoMessage ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [ticketId, status, count, messages, infoMessage];
}
