import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/addon.dart';
import '../../domain/entities/product_detail.dart';
import '../../domain/entities/size.dart';
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
      emit(_buildLoadedState(seed));
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
        emit(_buildLoadedState(merged));
      },
    );
  }

  Future<void> retry({required int id, required bool isOffer}) =>
      load(id: id, isOffer: isOffer, seed: _seed);

  // ── Selection Actions ──────────────────────────────────────────────────────

  /// Selects a new size and recalculates the total price.
  void selectSize(Size size) {
    final current = state;
    if (current is! ProductDetailLoaded) return;

    final newTotal = _calculateTotalPrice(
      selectedSize: size,
      selectedAddons: current.selectedAddons,
    );

    emit(current.copyWith(selectedSize: size, dynamicTotalPrice: newTotal));
  }

  /// Toggles an addon on or off and recalculates the total price.
  ///
  /// If [addon] is already selected it is removed; otherwise it is appended.
  void toggleAddon(Addon addon) {
    final current = state;
    if (current is! ProductDetailLoaded) return;

    final alreadySelected =
        current.selectedAddons.any((a) => a.id == addon.id);

    final updatedAddons = alreadySelected
        ? current.selectedAddons.where((a) => a.id != addon.id).toList()
        : [...current.selectedAddons, addon];

    final newTotal = _calculateTotalPrice(
      selectedSize: current.selectedSize,
      selectedAddons: updatedAddons,
    );

    emit(
      current.copyWith(selectedAddons: updatedAddons, dynamicTotalPrice: newTotal),
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Builds the initial [ProductDetailLoaded] state.
  ///
  /// Auto-selects the first available size (if any) and computes the opening
  /// total price from that size alone (no addons selected by default).
  ProductDetailLoaded _buildLoadedState(ProductDetail detail) {
    final initialSize = detail.sizes.isNotEmpty ? detail.sizes.first : null;
    final initialTotal = _calculateTotalPrice(
      selectedSize: initialSize,
      selectedAddons: const [],
    );

    return ProductDetailLoaded(
      detail: detail,
      selectedSize: initialSize,
      selectedAddons: const [],
      dynamicTotalPrice: initialTotal,
    );
  }

  /// Core price formula:
  ///   **Total = selectedSize.price + Σ selectedAddon.price**
  ///
  /// Falls back to [ProductDetail.price] when no size is selected (e.g. the
  /// product has no size options).
  double _calculateTotalPrice({
    required Size? selectedSize,
    required List<Addon> selectedAddons,
  }) {
    // Use the size price as the base; it already represents the full unit cost.
    final base = selectedSize?.price ?? 0.0;
    final addonsTotal =
        selectedAddons.fold<double>(0, (sum, addon) => sum + addon.price);
    return base + addonsTotal;
  }
}
