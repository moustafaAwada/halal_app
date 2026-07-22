import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';

import '../error/failures.dart';

class LocationCoordinates {
  const LocationCoordinates({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

abstract final class LocationService {
  static Future<Either<Failure, LocationCoordinates>> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const Left(
        ServerFailure(message: 'يرجى تفعيل خدمة الموقع'),
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return const Left(
        ServerFailure(message: 'تم رفض إذن الموقع'),
      );
    }

    if (permission == LocationPermission.deniedForever) {
      return const Left(
        ServerFailure(message: 'إذن الموقع مرفوض بشكل دائم'),
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return Right(
        LocationCoordinates(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(message: 'تعذر الحصول على الموقع الحالي'),
      );
    }
  }
}
