part of 'chat_cubit.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

final class ChatInitial extends ChatState {
  const ChatInitial();
}

final class ChatLoading extends ChatState {
  const ChatLoading();
}

final class ChatHistoryLoaded extends ChatState {
  const ChatHistoryLoaded({
    required this.history,
    this.isSending = false,
  });

  final ChatHistory history;
  final bool isSending;

  @override
  List<Object?> get props => [history, isSending];
}

final class ChatMessageSending extends ChatState {
  const ChatMessageSending({required this.history});

  final ChatHistory history;

  @override
  List<Object?> get props => [history];
}

final class ChatMessageSentSuccess extends ChatState {
  const ChatMessageSentSuccess({
    required this.message,
    required this.history,
  });

  final String message;
  final ChatHistory history;

  @override
  List<Object?> get props => [message, history];
}

final class ChatEmptyHistoryInfo extends ChatState {
  const ChatEmptyHistoryInfo({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ChatActionError extends ChatState {
  const ChatActionError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ChatError extends ChatState {
  const ChatError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
