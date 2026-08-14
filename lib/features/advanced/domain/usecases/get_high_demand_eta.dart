import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/eta_info.dart';
import '../repositories/advanced_features_repository.dart';

class GetHighDemandEtaUseCase implements UseCase<ETAInfo, NoParams> {
  const GetHighDemandEtaUseCase(this._repository);

  final AdvancedFeaturesRepository _repository;

  @override
  Future<Either<Failure, ETAInfo>> call(NoParams params) {
    return _repository.getHighDemandETA();
  }
}
