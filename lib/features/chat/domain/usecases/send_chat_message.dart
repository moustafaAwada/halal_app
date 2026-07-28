import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/send_message_result.dart';
import '../repositories/chat_repository.dart';

class SendChatMessageUseCase
    implements UseCase<SendMessageResult, SendChatMessageParams> {
  const SendChatMessageUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Either<Failure, SendMessageResult>> call(SendChatMessageParams params) {
    return _repository.sendMessage(messageText: params.messageText);
  }
}

class SendChatMessageParams extends Equatable {
  const SendChatMessageParams({required this.messageText});

  final String messageText;

  @override
  List<Object?> get props => [messageText];
}
