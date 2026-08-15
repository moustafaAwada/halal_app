import '../../domain/entities/recharge_response.dart';

class RechargeResponseModel extends RechargeResponse {
  const RechargeResponseModel({
    required super.success,
    required super.message,
  });

  factory RechargeResponseModel.fromJson(Map<String, dynamic> json) {
    return RechargeResponseModel(
      success: json['success'] as bool? ?? true, // Default to true if missing
      message: json['message'] as String? ?? 'Request submitted successfully',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}
