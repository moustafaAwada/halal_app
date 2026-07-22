import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/add_to_cart.dart';
import '../../domain/usecases/clear_cart.dart';
import '../../domain/usecases/confirm_order.dart';
import '../../domain/usecases/create_order.dart';
import '../../domain/usecases/get_cart.dart';
import '../../domain/usecases/remove_cart_item.dart';
import '../../domain/usecases/update_cart_item.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit({
    required GetCartUseCase getCartUseCase,
    required AddToCartUseCase addToCartUseCase,
    required UpdateCartItemUseCase updateCartItemUseCase,
    required RemoveCartItemUseCase removeCartItemUseCase,
    required ClearCartUseCase clearCartUseCase,
    required CreateOrderUseCase createOrderUseCase,
    required ConfirmOrderUseCase confirmOrderUseCase,
  })  : _getCartUseCase = getCartUseCase,
        _addToCartUseCase = addToCartUseCase,
        _updateCartItemUseCase = updateCartItemUseCase,
        _removeCartItemUseCase = removeCartItemUseCase,
        _clearCartUseCase = clearCartUseCase,
        _createOrderUseCase = createOrderUseCase,
        _confirmOrderUseCase = confirmOrderUseCase,
        super(const CartInitial());

  final GetCartUseCase _getCartUseCase;
  final AddToCartUseCase _addToCartUseCase;
  final UpdateCartItemUseCase _updateCartItemUseCase;
  final RemoveCartItemUseCase _removeCartItemUseCase;
  final ClearCartUseCase _clearCartUseCase;
  final CreateOrderUseCase _createOrderUseCase;
  final ConfirmOrderUseCase _confirmOrderUseCase;

  List<CartItem> _cachedItems = const [];

  List<CartItem> get _currentItems {
    final currentState = state;
    if (currentState is CartLoaded) {
      return currentState.items;
    }
    return _cachedItems;
  }

  void _emitLoaded(List<CartItem> items, {bool isBusy = false}) {
    _cachedItems = items;
    emit(CartLoaded(items: items, isBusy: isBusy));
  }

  Future<void> loadCart() async {
    emit(const CartLoading());

    final result = await _getCartUseCase(const NoParams());

    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (items) => _emitLoaded(items),
    );
  }

  Future<void> retry() => loadCart();

  Future<void> addToCart(
    int productId, {
    int quantity = 1,
  }) async {
    final result = await _addToCartUseCase(
      AddToCartParams(productId: productId, quantity: quantity),
    );

    result.fold(
      (failure) {
        if (failure is MultipleRestaurantsFailure) {
          emit(CartMultipleRestaurantsConflict(pendingProductId: productId));
          return;
        }
        emit(CartActionError(message: failure.message));
        _restoreLoadedState();
      },
      (items) => _emitLoaded(items),
    );
  }

  Future<void> resolveMultipleRestaurantsConflict(int productId) async {
    final clearResult = await _clearCartUseCase(const NoParams());

    await clearResult.fold(
      (failure) async {
        emit(CartActionError(message: failure.message));
        _restoreLoadedState();
      },
      (_) async {
        _emitLoaded(const []);
        await addToCart(productId);
      },
    );
  }

  Future<void> dismissMultipleRestaurantsConflict() async {
    _restoreLoadedState();
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    if (quantity < 1) {
      await removeItem(cartItemId);
      return;
    }

    final currentState = state;
    if (currentState is CartLoaded) {
      _emitLoaded(currentState.items, isBusy: true);
    }

    final result = await _updateCartItemUseCase(
      UpdateCartItemParams(cartItemId: cartItemId, quantity: quantity),
    );

    result.fold(
      (failure) {
        emit(CartActionError(message: failure.message));
        _restoreLoadedState();
      },
      (items) => _emitLoaded(items),
    );
  }

  Future<void> removeItem(int cartItemId) async {
    final previousItems = List<CartItem>.from(_currentItems);
    final updatedItems =
        previousItems.where((item) => item.id != cartItemId).toList();

    _emitLoaded(updatedItems, isBusy: true);

    final result = await _removeCartItemUseCase(
      RemoveCartItemParams(cartItemId: cartItemId),
    );

    result.fold(
      (failure) {
        emit(CartActionError(message: failure.message));
        _emitLoaded(previousItems);
      },
      (_) => _emitLoaded(updatedItems),
    );
  }

  Future<void> clearCart() async {
    final previousItems = List<CartItem>.from(_currentItems);
    _emitLoaded(const [], isBusy: true);

    final result = await _clearCartUseCase(const NoParams());

    result.fold(
      (failure) {
        emit(CartActionError(message: failure.message));
        _emitLoaded(previousItems);
      },
      (_) => _emitLoaded(const []),
    );
  }

  Future<void> createOrder() async {
    final currentState = state;
    if (currentState is CartLoaded) {
      _emitLoaded(currentState.items, isBusy: true);
    }

    final result = await _createOrderUseCase(const NoParams());

    result.fold(
      (failure) {
        emit(CartActionError(message: failure.message));
        _restoreLoadedState();
      },
      (orders) => emit(CartOrderCreated(orders: orders)),
    );
  }

  Future<void> confirmOrder(ConfirmOrderParams params) async {
    final result = await _confirmOrderUseCase(params);

    result.fold(
      (failure) => emit(CartActionError(message: failure.message)),
      (confirmResult) => emit(
        CartOrderConfirmed(
          message: confirmResult.message ?? 'تم تأكيد الطلب بنجاح',
        ),
      ),
    );
  }

  void _restoreLoadedState() {
    _emitLoaded(_cachedItems);
  }
}
