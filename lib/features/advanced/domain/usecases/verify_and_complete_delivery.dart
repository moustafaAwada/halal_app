import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/advanced_features_repository.dart';

class VerifyAndCompleteDeliveryUseCase
    implements UseCase<String, VerifyAndCompleteDeliveryParams> {
  const VerifyAndCompleteDeliveryUseCase(this._repository);

  final AdvancedFeaturesRepository _repository;

  @override
  Future<Either<Failure, String>> call(
    VerifyAndCompleteDeliveryParams params,
  ) {
    return _repository.verifyAndCompleteDelivery(
      params.orderId,
      pin: params.pin,
    );
  }
}

class VerifyAndCompleteDeliveryParams extends Equatable {
  const VerifyAndCompleteDeliveryParams({
    required this.orderId,
    this.pin,
  });

  final int orderId;
  final String? pin;

  @override
  List<Object?> get props => [orderId, pin];
}
