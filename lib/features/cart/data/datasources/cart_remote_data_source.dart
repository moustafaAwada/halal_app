import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/usecases/add_to_cart.dart';
import '../../domain/usecases/confirm_order.dart';
import '../../domain/usecases/update_cart_item.dart';
import '../models/cart_item_model.dart';
import '../models/confirm_order_result_model.dart';
import '../models/order_model.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemModel>> getCart();

  Future<void> addToCart(AddToCartParams params);

  Future<void> updateCartItem(UpdateCartItemParams params);

  Future<void> removeCartItem({required int cartItemId});

  Future<void> clearCart();

  Future<List<OrderModel>> createOrder();

  Future<ConfirmOrderResultModel> confirmOrder(ConfirmOrderParams params);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  const CartRemoteDataSourceImpl({
    required Dio dio,
    required DioErrorMapper errorMapper,
  })  : _dio = dio,
        _errorMapper = errorMapper;

  final Dio _dio;
  final DioErrorMapper _errorMapper;

  @override
  Future<List<CartItemModel>> getCart() async {
    try {
      final response = await _dio.get<dynamic>(ApiConstants.cart);
      final data = _unwrapList(response.data);
      return data
          .whereType<Map>()
          .map(
            (item) => CartItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<void> addToCart(AddToCartParams params) async {
    try {
      await _dio.post<dynamic>(
        ApiConstants.cart,
        data: _buildCartBody(
          productId: params.productId,
          quantity: params.quantity,
          menuSizeId: params.menuSizeId,
          addonIds: params.addonIds,
          note: params.note,
        ),
      );
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<void> updateCartItem(UpdateCartItemParams params) async {
    try {
      await _dio.put<dynamic>(
        ApiConstants.cartById(params.cartItemId),
        data: _buildCartBody(
          quantity: params.quantity,
          menuSizeId: params.menuSizeId,
          addonIds: params.addonIds,
          note: params.note,
        ),
      );
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<void> removeCartItem({required int cartItemId}) async {
    try {
      await _dio.delete<dynamic>(ApiConstants.cartById(cartItemId));
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _dio.delete<dynamic>(ApiConstants.cart);
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<List<OrderModel>> createOrder() async {
    try {
      final response = await _dio.post<dynamic>(ApiConstants.createOrder);
      final data = _unwrapList(response.data);
      return data
          .whereType<Map>()
          .map(
            (item) => OrderModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<ConfirmOrderResultModel> confirmOrder(
    ConfirmOrderParams params,
  ) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConstants.confirmOrder,
        data: {
          'order_id': params.orderId,
          'latitude': params.latitude,
          'longitude': params.longitude,
          'delivery_fee': params.deliveryFee,
          'delivery_time': params.deliveryTime,
          'total_price': params.totalPrice,
          'payment_method': params.paymentMethod,
        },
      );

      final body = _parseResponseMap(response.data);
      return ConfirmOrderResultModel.fromJson(body);
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  Map<String, dynamic> _buildCartBody({
    int? productId,
    required int quantity,
    int? menuSizeId,
    List<int>? addonIds,
    String? note,
  }) {
    final body = <String, dynamic>{'quantity': quantity};

    if (productId != null) {
      body['product_id'] = productId;
    }
    if (menuSizeId != null) {
      body['menu_size_id'] = menuSizeId;
    }
    if (addonIds != null && addonIds.isNotEmpty) {
      body['addons'] = addonIds;
    }
    if (note != null && note.isNotEmpty) {
      body['note'] = note;
    }

    return body;
  }

  Map<String, dynamic> _parseResponseMap(dynamic data) {
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

  List<dynamic> _unwrapList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final inner = data['data'];
      if (inner is List) return inner;
    }
    return const [];
  }
}
