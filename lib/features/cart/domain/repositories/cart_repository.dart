import 'package:dartz/dartz.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../entities/cart_item.dart';
import '../entities/confirm_order_result.dart';
import '../entities/order.dart';
import '../usecases/add_to_cart.dart';
import '../usecases/confirm_order.dart';
import '../usecases/update_cart_item.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItem>>> getCart();

  Future<Either<Failure, List<CartItem>>> addToCart(AddToCartParams params);

  Future<Either<Failure, List<CartItem>>> updateCartItem(
    UpdateCartItemParams params,
  );

  Future<Either<Failure, void>> removeCartItem({required int cartItemId});

  Future<Either<Failure, void>> clearCart();

  Future<Either<Failure, List<Order>>> createOrder();

  Future<Either<Failure, ConfirmOrderResult>> confirmOrder(
    ConfirmOrderParams params,
  );
}
