import 'package:dartz/dartz.dart' hide Order;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_details.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl({
    required OrdersRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final OrdersRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<Order>>> getOrders({String? status}) async {
    try {
      final result = await _remoteDataSource.getOrders(status: status);
      return Right(result.map((order) => order.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'حدث خطأ أثناء جلب الطلبات',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء جلب الطلبات'),
      );
    }
  }

  @override
  Future<Either<Failure, OrderDetails>> getOrderDetails(int id) async {
    try {
      final result = await _remoteDataSource.getOrderDetails(id);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message.isNotEmpty ? e.message : 'الطلب غير موجود',
        ),
      );
    } catch (_) {
      return const Left(ServerFailure(message: 'حدث خطأ غير متوقع'));
    }
  }
}
