import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/trip_status.dart';
import '../models/complete_trip_result_model.dart';
import '../models/trip_model.dart';
import '../models/trip_tracking_model.dart';

abstract class TripRemoteDataSource {
  Future<TripModel> requestTrip(Map<String, dynamic> data);

  Future<TripStatus> acceptTrip(int tripId);

  Future<TripStatus> driverArrived(int tripId);

  Future<TripStatus> startTrip(int tripId);

  Future<TripTrackingModel> updateTracking(
    int tripId,
    double lat,
    double lng,
  );

  Future<CompleteTripResultModel> completeTrip(int tripId);

  Future<String> cancelTrip(
    int tripId,
    String reason,
    String cancelledBy,
  );

  Future<String> rateTrip(int tripId, Map<String, dynamic> data);

  Future<TripModel> getTripDetails(int tripId);
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  const TripRemoteDataSourceImpl({
    required Dio dio,
    required DioErrorMapper errorMapper,
  })  : _dio = dio,
        _errorMapper = errorMapper;

  final Dio _dio;
  final DioErrorMapper _errorMapper;

  @override
  Future<TripModel> requestTrip(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConstants.requestTripUrl,
        data: data,
      );
      final body = _asMap(response.data);
      final dataMap = _unwrapDataMap(body) ?? body;
      return TripModel.fromJson(_extractTripJson(dataMap));
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<TripStatus> acceptTrip(int tripId) async {
    try {
      final response = await _dio.put<dynamic>(
        ApiConstants.acceptTripUrl(tripId),
      );
      return _statusFromResponse(response.data, fallback: TripStatus.accepted);
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<TripStatus> driverArrived(int tripId) async {
    try {
      final response = await _dio.put<dynamic>(
        ApiConstants.driverArrivedUrl(tripId),
      );
      return _statusFromResponse(
        response.data,
        fallback: TripStatus.driverArrived,
      );
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
  Future<TripTrackingModel> updateTracking(
    int tripId,
    double lat,
    double lng,
  ) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConstants.tripTrackingUrl(tripId),
        data: {'lat': lat, 'lng': lng},
      );
      final body = _asMap(response.data);
      final dataMap = _unwrapDataMap(body) ?? body;
      return TripTrackingModel.fromJson(dataMap);
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<CompleteTripResultModel> completeTrip(int tripId) async {
    try {
      final response = await _dio.put<dynamic>(
        ApiConstants.completeTripUrl(tripId),
      );
      final body = _asMap(response.data);
      final dataMap = _unwrapDataMap(body) ?? body;
      return CompleteTripResultModel.fromJson(
        dataMap,
        message: body['message']?.toString(),
      );
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<String> cancelTrip(
    int tripId,
    String reason,
    String cancelledBy,
  ) async {
    try {
      final response = await _dio.put<dynamic>(
        ApiConstants.cancelTripUrl(tripId),
        data: {
          'reason': reason,
          'cancelledBy': cancelledBy,
        },
      );
      final body = _asMap(response.data);
      return body['message']?.toString() ?? 'تم إلغاء الرحلة';
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<String> rateTrip(int tripId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConstants.rateTripUrl(tripId),
        data: data,
      );
      final body = _asMap(response.data);
      return body['message']?.toString() ?? 'تم التقييم بنجاح';
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<TripModel> getTripDetails(int tripId) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.getTripByIdUrl(tripId),
      );
      final body = _asMap(response.data);
      final dataMap = _unwrapDataMap(body) ?? body;
      return TripModel.fromJson(_extractTripJson(dataMap));
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  TripStatus _statusFromResponse(
    dynamic raw, {
    required TripStatus fallback,
  }) {
    final body = _asMap(raw);
    final dataMap = _unwrapDataMap(body);
    final statusValue =
        dataMap?['status']?.toString() ?? body['status']?.toString();
    if (statusValue == null) return fallback;
    return TripStatus.fromApi(statusValue);
  }

  Map<String, dynamic>? _unwrapDataMap(Map<String, dynamic> body) {
    final inner = body['data'];
    if (inner is Map) {
      return Map<String, dynamic>.from(inner);
    }
    return null;
  }

  Map<String, dynamic> _extractTripJson(Map<String, dynamic> dataMap) {
    final trip = dataMap['trip'];
    if (trip is Map) {
      return Map<String, dynamic>.from(trip);
    }
    return dataMap;
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }
}
