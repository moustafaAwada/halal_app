import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/send_message_result.dart';
import 'chat_message_model.dart';

class SendMessageResultModel extends SendMessageResult {
  const SendMessageResultModel({
    required super.ticketId,
    required super.message,
    required super.successMessage,
  });

  factory SendMessageResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    Map<String, dynamic> dataMap = const {};
    if (data is Map) {
      dataMap = Map<String, dynamic>.from(data);
    }

    final messageJson = dataMap['message'];
    final messageMap = messageJson is Map
        ? Map<String, dynamic>.from(messageJson)
        : <String, dynamic>{};

    final ticketId = dataMap['ticketId'] != null
        ? JsonParsers.toInt(dataMap['ticketId'])
        : JsonParsers.toInt(messageMap['ticketId']);

    final apiMessage = json['message']?.toString();

    return SendMessageResultModel(
      ticketId: ticketId,
      message: ChatMessageModel.fromSendResponse(messageMap),
      successMessage: (apiMessage != null && apiMessage.isNotEmpty)
          ? apiMessage
          : 'تم إرسال الرسالة بنجاح',
    );
  }

  Map<String, dynamic> toJson() => {
        'ticketId': ticketId,
        'message': (message as ChatMessageModel).toJson(),
        'successMessage': successMessage,
      };

  SendMessageResult toEntity() => SendMessageResult(
        ticketId: ticketId,
        message: (message as ChatMessageModel).toEntity(),
        successMessage: successMessage,
      );
}
