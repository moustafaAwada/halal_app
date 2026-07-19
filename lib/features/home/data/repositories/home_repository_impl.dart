import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/welcome_message.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/welcome_message_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<Either<Failure, WelcomeMessage>> getWelcomeMessage() async {
    const model = WelcomeMessageModel(text: 'Welcome to Halal App');
    return Right(model.toEntity());
  }
}
