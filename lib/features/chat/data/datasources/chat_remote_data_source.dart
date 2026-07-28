import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/chat_history_model.dart';
import '../models/send_message_result_model.dart';

abstract class ChatRemoteDataSource {
  Future<SendMessageResultModel> sendMessage({required String messageText});

  Future<ChatHistoryModel> getChatHistory();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  const ChatRemoteDataSourceImpl({
    required Dio dio,
    required DioErrorMapper errorMapper,
  })  : _dio = dio,
        _errorMapper = errorMapper;

  final Dio _dio;
  final DioErrorMapper _errorMapper;

  @override
  Future<SendMessageResultModel> sendMessage({
    required String messageText,
  }) async {
    try {
      // Absolute URL — customer-chat uses a different base path than /client.
      // Customer is resolved from the JWT Bearer token.
      final response = await _dio.post<dynamic>(
        ApiConstants.sendChatMessageUrl,
        data: {
          'messageText': messageText,
        },
      );

      final body = _unwrapMap(response.data);
      return SendMessageResultModel.fromJson(body);
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  @override
  Future<ChatHistoryModel> getChatHistory() async {
    try {
      final response = await _dio.get<dynamic>(ApiConstants.chatHistoryUrl);
      final body = _unwrapMap(response.data);
      return ChatHistoryModel.fromJson(body);
    } on DioException catch (e) {
      throw _errorMapper.mapToException(e);
    }
  }

  Map<String, dynamic> _unwrapMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return const {};
  }
}
