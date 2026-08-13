import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product_detail.dart';
import '../../domain/usecases/get_offer_details.dart';
import '../../domain/usecases/get_product_details.dart';

part 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit({
    required GetProductDetailsUseCase getProductDetailsUseCase,
    required GetOfferDetailsUseCase getOfferDetailsUseCase,
  })  : _getProductDetailsUseCase = getProductDetailsUseCase,
        _getOfferDetailsUseCase = getOfferDetailsUseCase,
        super(const ProductDetailInitial());

  final GetProductDetailsUseCase _getProductDetailsUseCase;
  final GetOfferDetailsUseCase _getOfferDetailsUseCase;

  ProductDetail? _seed;

  Future<void> load({
    required int id,
    required bool isOffer,
    ProductDetail? seed,
  }) async {
    _seed = seed;

    if (seed != null) {
      emit(ProductDetailLoaded(detail: seed));
    } else {
      emit(const ProductDetailLoading());
    }

    final result = isOffer
        ? await _getOfferDetailsUseCase(OfferDetailsParams(id: id))
        : await _getProductDetailsUseCase(ProductDetailsParams(id: id));

    result.fold(
      (failure) {
        if (_seed == null) {
          emit(ProductDetailError(message: failure.message));
        }
      },
      (detail) {
        final merged = _seed == null ? detail : detail.mergeWith(_seed!);
        emit(ProductDetailLoaded(detail: merged));
      },
    );
  }

  Future<void> retry({required int id, required bool isOffer}) =>
      load(id: id, isOffer: isOffer, seed: _seed);
}
