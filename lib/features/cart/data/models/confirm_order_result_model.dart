import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/confirm_order_result.dart';

class ConfirmOrderResultModel extends ConfirmOrderResult {
  const ConfirmOrderResultModel({
    super.message,
    super.orderId,
  });

  factory ConfirmOrderResultModel.fromJson(Map<String, dynamic> json) {
    return ConfirmOrderResultModel(
      message: json['message']?.toString(),
      orderId: _parseOrderId(json['order_id'] ?? json['orderId']),
    );
  }

  static int? _parseOrderId(dynamic value) {
    if (value == null) return null;
    final parsed = JsonParsers.toInt(value);
    return parsed > 0 ? parsed : null;
  }

  ConfirmOrderResult toEntity() => ConfirmOrderResult(
        message: message,
        orderId: orderId,
      );
}
