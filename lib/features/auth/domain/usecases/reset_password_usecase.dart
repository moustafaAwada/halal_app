import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  const ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) {
    return _repository.resetPassword(
      email: params.email,
      password: params.password,
      code: params.code,
    );
  }
}

class ResetPasswordParams extends Equatable {
  const ResetPasswordParams({
    required this.email,
    required this.password,
    required this.code,
  });

  final String email;
  final String password;
  final String code;

  @override
  List<Object?> get props => [email, password, code];
}
