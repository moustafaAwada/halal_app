import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/rate_delivery.dart';
import '../../domain/usecases/rate_order.dart';

part 'rating_state.dart';

class RatingCubit extends Cubit<RatingState> {
  RatingCubit({
    required RateOrderUseCase rateOrderUseCase,
    required RateDeliveryUseCase rateDeliveryUseCase,
  })  : _rateOrderUseCase = rateOrderUseCase,
        _rateDeliveryUseCase = rateDeliveryUseCase,
        super(const RatingInitial());

  final RateOrderUseCase _rateOrderUseCase;
  final RateDeliveryUseCase _rateDeliveryUseCase;

  /// Submits restaurant/order and delivery ratings together.
  Future<void> submitOrderAndDeliveryRating({
    required int orderId,
    required int orderRating,
    String? orderComment,
    required int deliveryRating,
    String? deliveryComment,
  }) async {
    if (!_isValidRating(orderRating) || !_isValidRating(deliveryRating)) {
      emit(const RatingError(message: 'يرجى اختيار تقييم من 1 إلى 5'));
      return;
    }

    emit(const RatingLoading());

    final results = await Future.wait([
      _rateOrderUseCase(
        RateOrderParams(
          orderId: orderId,
          ratingValue: orderRating,
          comment: orderComment,
        ),
      ),
      _rateDeliveryUseCase(
        RateDeliveryParams(
          orderId: orderId,
          ratingValue: deliveryRating,
          comment: deliveryComment,
        ),
      ),
    ]);

    for (final result in results) {
      final failure = result.fold((f) => f, (_) => null);
      if (failure != null) {
        emit(RatingError(message: failure.message));
        return;
      }
    }

    emit(const RatingSuccess(message: 'تم تسجيل التقييم بنجاح'));
  }

  bool _isValidRating(int value) => value >= 1 && value <= 5;
}
