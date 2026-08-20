part of 'cart_cubit.dart';

sealed class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

final class CartInitial extends CartState {
  const CartInitial();
}

final class CartLoading extends CartState {
  const CartLoading();
}

final class CartLoaded extends CartState {
  const CartLoaded({
    required this.items,
    this.isBusy = false,
    this.hasNewItems = false,
  });

  final List<CartItem> items;
  final bool isBusy;

  /// `true` after a successful `addToCart` call, until the user opens the cart.
  final bool hasNewItems;

  double get total =>
      items.fold<double>(0, (sum, item) => sum + item.lineTotal);

  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);

  CartLoaded copyWith({
    List<CartItem>? items,
    bool? isBusy,
    bool? hasNewItems,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      isBusy: isBusy ?? this.isBusy,
      hasNewItems: hasNewItems ?? this.hasNewItems,
    );
  }

  @override
  List<Object?> get props => [items, isBusy, hasNewItems];
}

final class CartError extends CartState {
  const CartError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class CartActionError extends CartState {
  const CartActionError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class CartMultipleRestaurantsConflict extends CartState {
  const CartMultipleRestaurantsConflict({required this.pendingProductId});

  final int pendingProductId;

  @override
  List<Object?> get props => [pendingProductId];
}

final class CartOrderCreated extends CartState {
  const CartOrderCreated({required this.orders});

  final List<Order> orders;

  @override
  List<Object?> get props => [orders];
}

final class CartOrderConfirmed extends CartState {
  const CartOrderConfirmed({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
