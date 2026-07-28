import 'package:equatable/equatable.dart';

import 'chat_message.dart';

/// Result returned after successfully sending a chat message.
class SendMessageResult extends Equatable {
  const SendMessageResult({
    required this.ticketId,
    required this.message,
    required this.successMessage,
  });

  final int ticketId;
  final ChatMessage message;
  final String successMessage;

  @override
  List<Object?> get props => [ticketId, message, successMessage];
}
