import 'package:dio/dio.dart';

import '../constants/maps_constants.dart';

class PlaceSuggestion {
  const PlaceSuggestion({
    required this.placeId,
    required this.description,
    this.mainText,
    this.secondaryText,
  });

  final String placeId;
  final String description;
  final String? mainText;
  final String? secondaryText;
}

class PlaceDetails {
  const PlaceDetails({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    this.name,
  });

  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String? name;

  String get displayAddress {
    if (name != null && name!.isNotEmpty && name != formattedAddress) {
      return '$name — $formattedAddress';
    }
    return formattedAddress;
  }
}

/// Google Places Autocomplete + Details for map location search.
class PlacesSearchService {
  PlacesSearchService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  final Dio _dio;

  Future<List<PlaceSuggestion>> autocomplete(
    String input, {
    double? latitude,
    double? longitude,
  }) async {
    final query = input.trim();
    if (query.length < 2) return const [];

    try {
      final response = await _dio.get<dynamic>(
        MapsConstants.placesAutocompleteUrl,
        queryParameters: {
          'input': query,
          'key': MapsConstants.apiKey,
          'language': MapsConstants.defaultLanguage,
          'components': 'country:${MapsConstants.defaultCountry}',
          if (latitude != null && longitude != null)
            'location': '$latitude,$longitude',
          if (latitude != null && longitude != null) 'radius': 50000,
        },
      );

      final data = response.data;
      if (data is! Map) return const [];

      final status = data['status']?.toString();
      if (status != 'OK' && status != 'ZERO_RESULTS') {
        return const [];
      }

      final predictions = data['predictions'];
      if (predictions is! List) return const [];

      return predictions.whereType<Map>().map((item) {
        final map = Map<String, dynamic>.from(item);
        final structured = map['structured_formatting'];
        String? mainText;
        String? secondaryText;
        if (structured is Map) {
          mainText = structured['main_text']?.toString();
          secondaryText = structured['secondary_text']?.toString();
        }
        return PlaceSuggestion(
          placeId: map['place_id']?.toString() ?? '',
          description: map['description']?.toString() ?? '',
          mainText: mainText,
          secondaryText: secondaryText,
        );
      }).where((s) => s.placeId.isNotEmpty).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    if (placeId.isEmpty) return null;

    try {
      final response = await _dio.get<dynamic>(
        MapsConstants.placeDetailsUrl,
        queryParameters: {
          'place_id': placeId,
          'key': MapsConstants.apiKey,
          'language': MapsConstants.defaultLanguage,
          'fields': 'geometry,formatted_address,name',
        },
      );

      final data = response.data;
      if (data is! Map) return null;
      if (data['status']?.toString() != 'OK') return null;

      final result = data['result'];
      if (result is! Map) return null;

      final resultMap = Map<String, dynamic>.from(result);
      final geometry = resultMap['geometry'];
      if (geometry is! Map) return null;
      final location = geometry['location'];
      if (location is! Map) return null;

      final lat = _asDouble(location['lat']);
      final lng = _asDouble(location['lng']);
      if (lat == null || lng == null) return null;

      return PlaceDetails(
        latitude: lat,
        longitude: lng,
        formattedAddress:
            resultMap['formatted_address']?.toString() ?? '',
        name: resultMap['name']?.toString(),
      );
    } catch (_) {
      return null;
    }
  }

  static double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
