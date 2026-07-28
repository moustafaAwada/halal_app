import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/chat_history.dart';
import '../entities/send_message_result.dart';

abstract class ChatRepository {
  /// Sends a customer message (creates an open ticket if needed).
  /// Customer identity comes from the JWT Bearer token.
  Future<Either<Failure, SendMessageResult>> sendMessage({
    required String messageText,
  });

  /// Returns the full chat history for the authenticated customer (may be empty).
  Future<Either<Failure, ChatHistory>> getChatHistory();
}
