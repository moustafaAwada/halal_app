import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/rating_model.dart';

abstract class RatingRemoteDataSource {
  Future<RatingModel> rateOrder(
    int orderId,
    int ratingValue,
    String? comment,
  );

  Future<RatingModel> rateDelivery(
    int orderId,
    int ratingValue,
    String? comment,
  );
}

class RatingRemoteDataSourceImpl implements RatingRemoteDataSource {
  const RatingRemoteDataSourceImpl({
    required Dio dio,
    required DioErrorMapper errorMapper,
  })  : _dio = dio,
        _errorMapper = errorMapper;

  final Dio _dio;
  final DioErrorMapper _errorMapper;

  @override
  Future<RatingModel> rateOrder(
    int orderId,
    int ratingValue,
    String? comment,
  ) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConstants.rateOrderUrl(orderId),
        data: _buildBody(ratingValue, comment),
      );
      return RatingModel.fromJson(_unwrapDataMap(response.data));
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<RatingModel> rateDelivery(
    int orderId,
    int ratingValue,
    String? comment,
  ) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConstants.rateDeliveryUrl(orderId),
        data: _buildBody(ratingValue, comment),
      );
      return RatingModel.fromJson(_unwrapDataMap(response.data));
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  Map<String, dynamic> _buildBody(int ratingValue, String? comment) {
    final trimmed = comment?.trim();
    return {
      'ratingValue': ratingValue,
      if (trimmed != null && trimmed.isNotEmpty) 'comment': trimmed,
    };
  }

  Map<String, dynamic> _unwrapDataMap(dynamic responseData) {
    if (responseData is Map) {
      final map = Map<String, dynamic>.from(responseData);
      final data = map['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return map;
    }
    return const {};
  }
}
