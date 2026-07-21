import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/search_product.dart';
import '../repositories/search_repository.dart';

class SearchProductsUseCase
    implements UseCase<List<SearchProduct>, SearchProductsParams> {
  const SearchProductsUseCase(this._repository);

  final SearchRepository _repository;

  @override
  Future<Either<Failure, List<SearchProduct>>> call(
    SearchProductsParams params,
  ) {
    return _repository.searchProducts(
      search: params.search,
      categoryName: params.categoryName,
    );
  }
}

class SearchProductsParams extends Equatable {
  const SearchProductsParams({
    this.search,
    this.categoryName,
  });

  final String? search;
  final String? categoryName;

  @override
  List<Object?> get props => [search, categoryName];
}
