import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/home_data_model.dart';
import '../models/product_detail_model.dart';
import '../models/product_model.dart';
import '../models/product_offer_model.dart';
import '../models/restaurant_detail_model.dart';
import '../models/restaurant_model.dart';
import '../models/review_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeDataModel> getHomeData();

  Future<ProductDetailModel> getProductDetails(int id);

  Future<ProductDetailModel> getOfferDetails(int id);

  Future<RestaurantDetailModel> getRestaurantDetails(int vendorId);
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
      final responses = await Future.wait([
        _dio.get<dynamic>(ApiConstants.products),
        _dio.get<dynamic>(ApiConstants.offers),
        _dio.get<dynamic>(ApiConstants.restaurants),
      ]);

      final topProducts = _parseList(
        responses[0].data,
        ProductModel.fromJson,
      );
      final topProductsOffer = _parseList(
        responses[1].data,
        ProductOfferModel.fromJson,
      );
      final restaurants = _parseList(
        responses[2].data,
        RestaurantModel.fromJson,
      );
      final reviews = await _fetchReviews();

      return HomeDataModel(
        topProducts: topProducts,
        topProductsOffer: topProductsOffer,
        reviews: reviews,
        restaurants: restaurants,
      );
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<ProductDetailModel> getProductDetails(int id) async {
    try {
      final response = await _dio.get<dynamic>(ApiConstants.productById(id));
      return ProductDetailModel.fromJson(_extractDataMap(response.data));
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<ProductDetailModel> getOfferDetails(int id) async {
    try {
      final response = await _dio.get<dynamic>(ApiConstants.offerById(id));
      return ProductDetailModel.fromJson(_extractDataMap(response.data));
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<RestaurantDetailModel> getRestaurantDetails(int vendorId) async {
    try {
      final response =
          await _dio.get<dynamic>(ApiConstants.restaurantById(vendorId));
      return RestaurantDetailModel.fromJson(_extractDataMap(response.data));
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  Future<List<ReviewModel>> _fetchReviews() async {
    try {
      final response = await _dio.get<dynamic>(ApiConstants.menuTopUrl);
      final data = Map<String, dynamic>.from(response.data as Map);
      return _parseList(data['reviews'], ReviewModel.fromJson);
    } on DioException {
      return [];
    }
  }

  Map<String, dynamic> _extractDataMap(dynamic responseData) {
    if (responseData is Map) {
      final map = Map<String, dynamic>.from(responseData);
      final data = map['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return map;
    }

    throw FormatException('Unexpected response format');
  }

  List<T> _parseList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((item) => fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
