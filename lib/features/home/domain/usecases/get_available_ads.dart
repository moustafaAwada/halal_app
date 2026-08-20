import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ad.dart';
import '../repositories/ads_repository.dart';

class GetAvailableAdsUseCase implements UseCase<List<Ad>, NoParams> {
  const GetAvailableAdsUseCase(this._repository);

  final AdsRepository _repository;

  @override
  Future<Either<Failure, List<Ad>>> call(NoParams params) {
    return _repository.getAvailableAds();
  }
}
