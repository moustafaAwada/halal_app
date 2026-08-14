import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../trip/data/models/trip_model.dart';
import '../../../trip/domain/entities/trip_status.dart';
import '../models/eta_info_model.dart';

abstract class AdvancedRemoteDataSource {
  Future<ETAInfoModel> getHighDemandETA();

  Future<TripModel> rebookTrip(int tripId);

  Future<List<TripModel>> getNearbyTrips(
    double lat,
    double lng,
    double radius,
  );

  Future<TripStatus> startTrip(int tripId);

  Future<String> verifyAndCompleteDelivery(
    int orderId, {
    String? pin,
  });
}

class AdvancedRemoteDataSourceImpl implements AdvancedRemoteDataSource {
  const AdvancedRemoteDataSourceImpl({
    required Dio dio,
    required DioErrorMapper errorMapper,
  })  : _dio = dio,
        _errorMapper = errorMapper;

  final Dio _dio;
  final DioErrorMapper _errorMapper;

  @override
  Future<ETAInfoModel> getHighDemandETA() async {
    try {
      final response = await _dio.get<dynamic>(ApiConstants.eta);
      return ETAInfoModel.fromJson(_unwrapDataMap(response.data));
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<TripModel> rebookTrip(int tripId) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConstants.rebookTripUrl(tripId),
      );
      return TripModel.fromJson(_unwrapDataMap(response.data));
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<List<TripModel>> getNearbyTrips(
    double lat,
    double lng,
    double radius,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.nearbyTripsUrl,
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'radius': radius,
        },
      );
      return _unwrapTripList(response.data);
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<TripStatus> startTrip(int tripId) async {
    try {
      final response = await _dio.put<dynamic>(
        ApiConstants.startTripUrl(tripId),
      );
      return _statusFromResponse(
        response.data,
        fallback: TripStatus.inProgress,
      );
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<String> verifyAndCompleteDelivery(
    int orderId, {
    String? pin,
  }) async {
    try {
      final trimmedPin = pin?.trim();
      final response = await _dio.put<dynamic>(
        ApiConstants.deliveryStatusUrl(orderId),
        data: {
          'status': 'success',
          if (trimmedPin != null && trimmedPin.isNotEmpty) 'pin': trimmedPin,
        },
      );
      final body = _asMap(response.data);
      return body['message']?.toString() ?? 'تم تأكيد التسليم بنجاح';
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  List<TripModel> _unwrapTripList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => TripModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final inner = map['data'];
      if (inner is List) {
        return inner
            .whereType<Map>()
            .map((item) => TripModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }

    return const [];
  }

  TripStatus _statusFromResponse(
    dynamic raw, {
    required TripStatus fallback,
  }) {
    final body = _asMap(raw);
    final dataMap = body['data'];
    final statusValue = dataMap is Map
        ? dataMap['status']?.toString()
        : body['status']?.toString();
    if (statusValue == null) return fallback;
    return TripStatus.fromApi(statusValue);
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

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }
}
