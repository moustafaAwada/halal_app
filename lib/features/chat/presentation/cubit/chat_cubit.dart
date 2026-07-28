import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/chat_history.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/get_chat_history.dart';
import '../../domain/usecases/send_chat_message.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required GetChatHistoryUseCase getChatHistoryUseCase,
    required SendChatMessageUseCase sendChatMessageUseCase,
  })  : _getChatHistoryUseCase = getChatHistoryUseCase,
        _sendChatMessageUseCase = sendChatMessageUseCase,
        super(const ChatInitial());

  final GetChatHistoryUseCase _getChatHistoryUseCase;
  final SendChatMessageUseCase _sendChatMessageUseCase;

  ChatHistory _history = const ChatHistory(messages: [], count: 0);

  Future<void> fetchHistory() async {
    emit(const ChatLoading());

    final result = await _getChatHistoryUseCase(const NoParams());

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (history) {
        _history = history;
        emit(ChatHistoryLoaded(history: history));

        // Surface the documented empty-history message once via snackbar.
        if (history.isEmpty) {
          emit(
            ChatEmptyHistoryInfo(
              message: history.infoMessage?.isNotEmpty == true
                  ? history.infoMessage!
                  : 'لا توجد محادثات سابقة لهذا العميل',
            ),
          );
          emit(ChatHistoryLoaded(history: history));
        }
      },
    );
  }

  Future<void> retry() => fetchHistory();

  Future<void> sendMessage(String messageText) async {
    final trimmed = messageText.trim();
    if (trimmed.isEmpty) return;

    final current = state;
    if (current is ChatHistoryLoaded && current.isSending) return;

    emit(ChatMessageSending(history: _history));
    emit(ChatHistoryLoaded(history: _history, isSending: true));

    final result = await _sendChatMessageUseCase(
      SendChatMessageParams(messageText: trimmed),
    );

    result.fold(
      (failure) {
        emit(ChatActionError(message: failure.message));
        emit(ChatHistoryLoaded(history: _history));
      },
      (sendResult) {
        final updatedMessages = <ChatMessage>[
          ..._history.messages,
          sendResult.message,
        ];

        _history = _history.copyWith(
          ticketId: sendResult.ticketId,
          status: _history.status ?? 'OPEN',
          count: updatedMessages.length,
          messages: updatedMessages,
          clearInfoMessage: true,
        );

        emit(
          ChatMessageSentSuccess(
            message: sendResult.successMessage,
            history: _history,
          ),
        );
        emit(ChatHistoryLoaded(history: _history));
      },
    );
  }
}
