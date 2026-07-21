import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/home_data_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeDataModel> getHomeData();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl({
    required Dio dio,
    required DioErrorMapper errorMapper,
  })  : _dio = dio,
        _errorMapper = errorMapper;

  final Dio _dio;
  final DioErrorMapper _errorMapper;

  @override
  Future<HomeDataModel> getHomeData() async {
    try {
      final response = await _dio.get<dynamic>(ApiConstants.menuTopUrl);
      final data = Map<String, dynamic>.from(response.data as Map);
      return HomeDataModel.fromJson(data);
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }
}
