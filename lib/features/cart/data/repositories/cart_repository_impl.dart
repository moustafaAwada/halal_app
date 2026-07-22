import 'package:dartz/dartz.dart' hide Order;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/confirm_order_result.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/add_to_cart.dart';
import '../../domain/usecases/confirm_order.dart';
import '../../domain/usecases/update_cart_item.dart';
import '../datasources/cart_remote_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl({
    required CartRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final CartRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<CartItem>>> getCart() async {
    try {
      final result = await _remoteDataSource.getCart();
      return Right(result.map((item) => item.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(_mapException(e));
    } catch (_) {
      return const Left(ServerFailure(message: 'حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> addToCart(
    AddToCartParams params,
  ) async {
    try {
      await _remoteDataSource.addToCart(params);
      return getCart();
    } on ServerException catch (e) {
      return Left(_mapException(e));
    } catch (_) {
      return const Left(ServerFailure(message: 'حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> updateCartItem(
    UpdateCartItemParams params,
  ) async {
    try {
      await _remoteDataSource.updateCartItem(params);
      return getCart();
    } on ServerException catch (e) {
      return Left(_mapException(e));
    } catch (_) {
      return const Left(ServerFailure(message: 'حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, void>> removeCartItem({
    required int cartItemId,
  }) async {
    try {
      await _remoteDataSource.removeCartItem(cartItemId: cartItemId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(_mapException(e));
    } catch (_) {
      return const Left(ServerFailure(message: 'حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await _remoteDataSource.clearCart();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(_mapException(e));
    } catch (_) {
      return const Left(ServerFailure(message: 'حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> createOrder() async {
    try {
      final result = await _remoteDataSource.createOrder();
      return Right(result.map((order) => order.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(_mapException(e));
    } catch (_) {
      return const Left(ServerFailure(message: 'حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, ConfirmOrderResult>> confirmOrder(
    ConfirmOrderParams params,
  ) async {
    try {
      final result = await _remoteDataSource.confirmOrder(params);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(_mapException(e));
    } catch (_) {
      return const Left(ServerFailure(message: 'حدث خطأ غير متوقع'));
    }
  }

  Failure _mapException(ServerException exception) {
    if (exception.code == 'MULTIPLE_RESTAURANTS') {
      return MultipleRestaurantsFailure(message: exception.message);
    }
    return ServerFailure(message: exception.message);
  }
}
