import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SendVerificationCodeUseCase implements UseCase<void, SendCodeParams> {
  const SendVerificationCodeUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(SendCodeParams params) {
    return _repository.sendVerificationCode(email: params.email);
  }
}

class SendCodeParams extends Equatable {
  const SendCodeParams({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}
