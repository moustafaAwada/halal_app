part of 'product_detail_cubit.dart';

sealed class ProductDetailState extends Equatable {
  const ProductDetailState();

  @override
  List<Object?> get props => [];
}

final class ProductDetailInitial extends ProductDetailState {
  const ProductDetailInitial();
}

final class ProductDetailLoading extends ProductDetailState {
  const ProductDetailLoading();
}

final class ProductDetailLoaded extends ProductDetailState {
  const ProductDetailLoaded({
    required this.detail,
    this.selectedSize,
    this.selectedAddons = const [],
    this.dynamicTotalPrice = 0,
  });

  final ProductDetail detail;

  /// The currently selected size. `null` only when the product has no sizes.
  final Size? selectedSize;

  /// The list of currently selected add-ons (may be empty).
  final List<Addon> selectedAddons;

  /// Dynamically computed price: `selectedSize.price + Σ selectedAddon.price`.
  final double dynamicTotalPrice;

  /// Returns true if [addon] is in the currently selected list.
  bool isAddonSelected(Addon addon) =>
      selectedAddons.any((a) => a.id == addon.id);

  ProductDetailLoaded copyWith({
    ProductDetail? detail,
    Size? selectedSize,
    List<Addon>? selectedAddons,
    double? dynamicTotalPrice,
  }) {
    return ProductDetailLoaded(
      detail: detail ?? this.detail,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedAddons: selectedAddons ?? this.selectedAddons,
      dynamicTotalPrice: dynamicTotalPrice ?? this.dynamicTotalPrice,
    );
  }

  @override
  List<Object?> get props => [
        detail,
        selectedSize,
        selectedAddons,
        dynamicTotalPrice,
      ];
}

final class ProductDetailError extends ProductDetailState {
  const ProductDetailError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
