import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/order_details_model.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderModel>> getOrders({String? status});

  Future<OrderDetailsModel> getOrderDetails(int id);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  const OrdersRemoteDataSourceImpl({
    required Dio dio,
    required DioErrorMapper errorMapper,
  })  : _dio = dio,
        _errorMapper = errorMapper;

  final Dio _dio;
  final DioErrorMapper _errorMapper;

  @override
  Future<List<OrderModel>> getOrders({String? status}) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.orders,
        queryParameters: status == null ? null : {'status': status},
      );

      return _unwrapOrdersList(response.data);
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<OrderDetailsModel> getOrderDetails(int id) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.orderDetails(id),
      );
      final body = _unwrapMap(response.data);
      return OrderDetailsModel.fromJson(body);
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  List<OrderModel> _unwrapOrdersList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final inner = map['data'];
      if (inner is List) {
        return inner
            .whereType<Map>()
            .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }

    return [];
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
