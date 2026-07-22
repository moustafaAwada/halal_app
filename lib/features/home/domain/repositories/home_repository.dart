import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/home_data.dart';
import '../entities/product_detail.dart';
import '../entities/restaurant_detail.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeData>> getHomeData();

  Future<Either<Failure, ProductDetail>> getProductDetails(int id);

  Future<Either<Failure, ProductDetail>> getOfferDetails(int id);

  Future<Either<Failure, RestaurantDetail>> getRestaurantDetails(int vendorId);
}
