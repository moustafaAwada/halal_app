import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/restaurant_detail.dart';
import '../../domain/usecases/get_restaurant_details.dart';

part 'restaurant_detail_state.dart';

class RestaurantDetailCubit extends Cubit<RestaurantDetailState> {
  RestaurantDetailCubit({
    required GetRestaurantDetailsUseCase getRestaurantDetailsUseCase,
  })  : _getRestaurantDetailsUseCase = getRestaurantDetailsUseCase,
        super(const RestaurantDetailInitial());

  final GetRestaurantDetailsUseCase _getRestaurantDetailsUseCase;

  Future<void> load(int vendorId) async {
    emit(const RestaurantDetailLoading());

    final result = await _getRestaurantDetailsUseCase(
      RestaurantDetailsParams(vendorId: vendorId),
    );

    result.fold(
      (failure) => emit(RestaurantDetailError(message: failure.message)),
      (detail) => emit(RestaurantDetailLoaded(detail: detail)),
    );
  }

  Future<void> retry(int vendorId) => load(vendorId);
}
