import 'package:equatable/equatable.dart';

/// Base class for domain-level failures returned via [Either].
abstract class Failure extends Equatable {
  const Failure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred'});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

class MultipleRestaurantsFailure extends Failure {
  const MultipleRestaurantsFailure({
    super.message =
        'سلتك تحتوي على منتجات من مطعم آخر، هل ترغب في تفريغ السلة؟',
  });
}
