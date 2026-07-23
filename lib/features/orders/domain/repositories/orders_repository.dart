import 'package:dartz/dartz.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../entities/order.dart';
import '../entities/order_details.dart';

abstract class OrdersRepository {
  Future<Either<Failure, List<Order>>> getOrders({String? status});

  Future<Either<Failure, OrderDetails>> getOrderDetails(int id);
}
