import 'package:equatable/equatable.dart';

/// A single message in the customer support conversation.
class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.messageText,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.isSentByMe,
    required this.createdAt,
  });

  final int id;
  final String messageText;
  final int senderId;
  final String senderName;

  /// Typically `CUSTOMER` or `SUPPORT`.
  final String senderRole;

  /// Drives bubble alignment in the chat UI.
  final bool isSentByMe;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        messageText,
        senderId,
        senderName,
        senderRole,
        isSentByMe,
        createdAt,
      ];
}
