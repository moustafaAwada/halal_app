import 'package:equatable/equatable.dart';

/// High-demand ETA payload from GET /client/eta.
class ETAInfo extends Equatable {
  const ETAInfo({
    required this.etaMinutes,
    required this.isHighDemand,
    required this.message,
  });

  final int etaMinutes;
  final bool isHighDemand;
  final String message;

  @override
  List<Object?> get props => [etaMinutes, isHighDemand, message];
}
