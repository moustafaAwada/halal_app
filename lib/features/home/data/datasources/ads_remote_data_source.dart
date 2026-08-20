import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/ad_model.dart';

abstract class AdsRemoteDataSource {
  Future<List<AdModel>> getAvailableAds();
}

class AdsRemoteDataSourceImpl implements AdsRemoteDataSource {
  const AdsRemoteDataSourceImpl({
    required Dio dio,
    required DioErrorMapper errorMapper,
  })  : _dio = dio,
        _errorMapper = errorMapper;

  final Dio _dio;
  final DioErrorMapper _errorMapper;

  @override
  Future<List<AdModel>> getAvailableAds() async {
    try {
      final response = await _dio.get<dynamic>(ApiConstants.adsAvailableUrl);
      return _unwrapAdsList(response.data);
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  List<AdModel> _unwrapAdsList(dynamic data) {
    if (data is List) {
      return _parseList(data);
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final inner = map['data'] ?? map['ads'] ?? map['results'];
      if (inner is List) {
        return _parseList(inner);
      }
    }

    return [];
  }

  List<AdModel> _parseList(List<dynamic> items) {
    return items
        .whereType<Map>()
        .map((item) => AdModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
