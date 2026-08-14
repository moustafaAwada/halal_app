import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/eta_info.dart';

class ETAInfoModel extends ETAInfo {
  const ETAInfoModel({
    required super.etaMinutes,
    required super.isHighDemand,
    required super.message,
  });

  factory ETAInfoModel.fromJson(Map<String, dynamic> json) {
    return ETAInfoModel(
      etaMinutes: JsonParsers.toInt(json['etaMinutes']),
      isHighDemand: JsonParsers.toBool(json['isHighDemand']),
      message: json['message']?.toString() ?? '',
    );
  }

  ETAInfo toEntity() => ETAInfo(
        etaMinutes: etaMinutes,
        isHighDemand: isHighDemand,
        message: message,
      );
}
