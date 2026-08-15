import 'dart:io';
import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/recharge_response_model.dart';
import '../models/wallet_balance_model.dart';
import '../models/wallet_request_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletBalanceModel> getBalance();
  Future<List<WalletRequestModel>> getMyRequests();
  Future<RechargeResponseModel> submitRechargeRequest({
    required double amount,
    required String paymentMethod,
    required File receiptFile,
  });
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  WalletRemoteDataSourceImpl({
    required this.dio,
    required this.errorMapper,
  });

  final Dio dio;
  final DioErrorMapper errorMapper;

  @override
  Future<WalletBalanceModel> getBalance() async {
    try {
      final response = await dio.get(ApiConstants.walletBalanceUrl);
      return WalletBalanceModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw errorMapper.mapToException(e);
    }
  }

  @override
  Future<List<WalletRequestModel>> getMyRequests() async {
    try {
      final response = await dio.get(ApiConstants.walletMyRequestsUrl);
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => WalletRequestModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data.containsKey('data')) {
        final list = data['data'] as List;
        return list
            .map((e) => WalletRequestModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw errorMapper.mapToException(e);
    }
  }

  @override
  Future<RechargeResponseModel> submitRechargeRequest({
    required double amount,
    required String paymentMethod,
    required File receiptFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'amount': amount.toString(),
        'payment_method': paymentMethod,
        'receipt': await MultipartFile.fromFile(
          receiptFile.path,
          filename: receiptFile.path.split('/').last,
        ),
      });

      final response = await dio.post(
        ApiConstants.walletRechargeUrl,
        data: formData,
      );

      // If the API returns a response message or structure
      if (response.data is Map<String, dynamic>) {
        return RechargeResponseModel.fromJson(
            response.data as Map<String, dynamic>);
      }
      return const RechargeResponseModel(
        success: true,
        message: 'Request submitted successfully',
      );
    } on DioException catch (e) {
      throw errorMapper.mapToException(e);
    }
  }
}
