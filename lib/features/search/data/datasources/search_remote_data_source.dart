import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/search_product_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<SearchProductModel>> searchProducts({
    String? search,
    String? categoryName,
  });
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  const SearchRemoteDataSourceImpl({
    required Dio dio,
    required DioErrorMapper errorMapper,
  })  : _dio = dio,
        _errorMapper = errorMapper;

  final Dio _dio;
  final DioErrorMapper _errorMapper;

  @override
  Future<List<SearchProductModel>> searchProducts({
    String? search,
    String? categoryName,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      final trimmedSearch = search?.trim();
      if (trimmedSearch != null && trimmedSearch.isNotEmpty) {
        queryParameters['search'] = trimmedSearch;
      }
      if (categoryName != null && categoryName.isNotEmpty) {
        queryParameters['categoryName'] = categoryName;
      }

      final response = await _dio.get<dynamic>(
        ApiConstants.menuSearchUrl,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      final data = response.data;
      if (data is! List) return [];

      return data
          .whereType<Map>()
          .map(
            (item) => SearchProductModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }
}
