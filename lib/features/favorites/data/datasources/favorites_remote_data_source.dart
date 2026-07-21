import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/favorite_item_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<FavoriteItemModel>> getFavorites();

  Future<FavoriteItemModel> addFavorite({required int productId});

  Future<void> removeFavorite({required int favoriteId});
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  const FavoritesRemoteDataSourceImpl({
    required Dio dio,
    required DioErrorMapper errorMapper,
  })  : _dio = dio,
        _errorMapper = errorMapper;

  final Dio _dio;
  final DioErrorMapper _errorMapper;

  @override
  Future<List<FavoriteItemModel>> getFavorites() async {
    try {
      final response = await _dio.get<dynamic>(ApiConstants.favorites);

      final data = response.data;
      if (data is! List) return [];

      return data
          .whereType<Map>()
          .map(
            (item) => FavoriteItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<FavoriteItemModel> addFavorite({required int productId}) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConstants.favorites,
        data: {'product_id': productId},
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = body['data'];
      if (data is Map) {
        return FavoriteItemModel.fromJson(Map<String, dynamic>.from(data));
      }

      return FavoriteItemModel.fromJson(body);
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<void> removeFavorite({required int favoriteId}) async {
    try {
      await _dio.delete<dynamic>(ApiConstants.favoriteById(favoriteId));
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }
}
