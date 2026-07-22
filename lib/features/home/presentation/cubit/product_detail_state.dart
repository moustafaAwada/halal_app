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
  const ProductDetailLoaded({required this.detail});

  final ProductDetail detail;

  @override
  List<Object?> get props => [detail];
}

final class ProductDetailError extends ProductDetailState {
  const ProductDetailError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
