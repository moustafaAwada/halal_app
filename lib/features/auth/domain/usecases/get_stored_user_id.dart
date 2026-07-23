import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class GetStoredUserIdUseCase implements UseCase<int, NoParams> {
  const GetStoredUserIdUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, int>> call(NoParams params) {
    return _repository.getStoredUserId();
  }
}
