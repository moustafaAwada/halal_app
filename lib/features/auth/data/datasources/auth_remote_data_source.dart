import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/auth_result_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResultModel> login({
    required String email,
    required String password,
  });

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String city,
  });

  Future<void> sendVerificationCode({required String email});

  Future<void> resetPassword({
    required String email,
    required String password,
    required String code,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    required Dio dio,
    required DioErrorMapper errorMapper,
  })  : _dio = dio,
        _errorMapper = errorMapper;

  final Dio _dio;
  final DioErrorMapper _errorMapper;

  @override
  Future<AuthResultModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      return AuthResultModel.fromJson(data);
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String city,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        ApiConstants.register,
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
          'phone': phone,
          'address': address,
          'city': city,
        },
      );
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<void> sendVerificationCode({required String email}) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        ApiConstants.sendCode,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String password,
    required String code,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        ApiConstants.forgetPassword,
        data: {
          'email': email,
          'password': password,
          'code': code,
        },
      );
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }
}
