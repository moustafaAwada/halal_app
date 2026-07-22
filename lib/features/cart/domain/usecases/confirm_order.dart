import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/confirm_order_result.dart';
import '../repositories/cart_repository.dart';

class ConfirmOrderUseCase
    implements UseCase<ConfirmOrderResult, ConfirmOrderParams> {
  const ConfirmOrderUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Either<Failure, ConfirmOrderResult>> call(ConfirmOrderParams params) {
    return _repository.confirmOrder(params);
  }
}

class ConfirmOrderParams extends Equatable {
  const ConfirmOrderParams({
    required this.orderId,
    required this.latitude,
    required this.longitude,
    required this.deliveryFee,
    required this.deliveryTime,
    required this.totalPrice,
    this.paymentMethod = 'cod',
  });

  final int orderId;
  final double latitude;
  final double longitude;
  final double deliveryFee;
  final String deliveryTime;
  final double totalPrice;
  final String paymentMethod;

  @override
  List<Object?> get props => [
        orderId,
        latitude,
        longitude,
        deliveryFee,
        deliveryTime,
        totalPrice,
        paymentMethod,
      ];
}
