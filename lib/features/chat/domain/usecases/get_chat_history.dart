import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_history.dart';
import '../repositories/chat_repository.dart';

class GetChatHistoryUseCase implements UseCase<ChatHistory, NoParams> {
  const GetChatHistoryUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Either<Failure, ChatHistory>> call(NoParams params) {
    return _repository.getChatHistory();
  }
}
