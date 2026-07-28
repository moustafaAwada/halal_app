import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/chat_history.dart';
import '../../domain/entities/send_message_result.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl({
    required ChatRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ChatRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, SendMessageResult>> sendMessage({
    required String messageText,
  }) async {
    try {
      final result = await _remoteDataSource.sendMessage(
        messageText: messageText,
      );
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'حدث خطأ أثناء إرسال الرسالة',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء إرسال الرسالة'),
      );
    }
  }

  @override
  Future<Either<Failure, ChatHistory>> getChatHistory() async {
    try {
      final result = await _remoteDataSource.getChatHistory();
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'حدث خطأ أثناء جلب الرسائل',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء جلب الرسائل'),
      );
    }
  }
}
