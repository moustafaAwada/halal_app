import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(int id);

  Future<String> updateUserProfile(int id, Map<String, dynamic> data);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl({
    required Dio dio,
    required DioErrorMapper errorMapper,
  })  : _dio = dio,
        _errorMapper = errorMapper;

  final Dio _dio;
  final DioErrorMapper _errorMapper;

  @override
  Future<UserProfileModel> getUserProfile(int id) async {
    try {
      final response = await _dio.get<dynamic>(ApiConstants.userProfileById(id));
      final body = _unwrapMap(response.data);
      return UserProfileModel.fromJson(body);
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<String> updateUserProfile(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put<dynamic>(
        ApiConstants.updateUserProfile(id),
        data: data,
      );
      final body = _unwrapMap(response.data);
      final message = body['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
      return 'تم تحديث البيانات بنجاح';
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  Map<String, dynamic> _unwrapMap(dynamic data) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final inner = map['data'];
      if (inner is Map) {
        return Map<String, dynamic>.from(inner);
      }
      return map;
    }
    return const {};
  }
}
