import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/search_product.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<SearchProduct>>> searchProducts({
    String? search,
    String? categoryName,
  });
}
