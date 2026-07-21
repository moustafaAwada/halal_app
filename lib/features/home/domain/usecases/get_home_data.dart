import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/home_data.dart';
import '../repositories/home_repository.dart';

class GetHomeDataUseCase implements UseCase<HomeData, NoParams> {
  const GetHomeDataUseCase(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, HomeData>> call(NoParams params) {
    return _repository.getHomeData();
  }
}
