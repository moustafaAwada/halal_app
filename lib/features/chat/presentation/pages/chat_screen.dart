import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../home/presentation/widgets/home_shimmer.dart';
import '../../domain/entities/chat_message.dart';
import '../cubit/chat_cubit.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_shimmer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<ChatCubit>();
      if (cubit.state is ChatInitial) {
        cubit.fetchHistory();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleSend() {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;
    context.read<ChatCubit>().sendMessage(text);
    _messageController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.searchBackground,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            color: Colors.black87,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'الدعم الفني',
            style: AppTextStyles.onboardingTitle(
              color: Colors.black87,
            ).copyWith(fontSize: 20),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<ChatCubit, ChatState>(
            listenWhen: (previous, current) =>
                current is ChatMessageSentSuccess ||
                current is ChatEmptyHistoryInfo ||
                current is ChatActionError ||
                current is ChatError,
            listener: (context, state) {
              if (state is ChatMessageSentSuccess) {
                SnackbarUtils.showSuccessSnackBar(context, state.message);
                _scrollToBottom();
              } else if (state is ChatEmptyHistoryInfo) {
                SnackbarUtils.showSuccessSnackBar(context, state.message);
              } else if (state is ChatActionError) {
                SnackbarUtils.showErrorSnackBar(
                  context,
                  state.message.isNotEmpty
                      ? state.message
                      : 'حدث خطأ أثناء إرسال الرسالة',
                );
              } else if (state is ChatError) {
                SnackbarUtils.showErrorSnackBar(
                  context,
                  state.message.isNotEmpty
                      ? state.message
                      : 'حدث خطأ أثناء جلب الرسائل',
                );
              }
            },
            buildWhen: (previous, current) =>
                current is! ChatMessageSentSuccess &&
                current is! ChatEmptyHistoryInfo &&
                current is! ChatActionError &&
                current is! ChatMessageSending,
            builder: (context, state) {
              return Column(
                children: [
                  Expanded(
                    child: switch (state) {
                      ChatInitial() || ChatLoading() => const ChatShimmer(),
                      ChatError(:final message) => HomeErrorView(
                          message: message.isNotEmpty
                              ? message
                              : 'حدث خطأ أثناء جلب الرسائل',
                          onRetry: () => context.read<ChatCubit>().retry(),
                        ),
                      ChatHistoryLoaded(:final history, :final isSending) =>
                        history.isEmpty
                            ? const _ChatEmptyView()
                            : _ChatMessagesList(
                                messages: history.messages,
                                scrollController: _scrollController,
                                isSending: isSending,
                              ),
                      _ => const ChatShimmer(),
                    },
                  ),
                  _ChatInputBar(
                    controller: _messageController,
                    focusNode: _focusNode,
                    isSending: state is ChatHistoryLoaded && state.isSending,
                    onSend: _handleSend,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChatMessagesList extends StatefulWidget {
  const _ChatMessagesList({
    required this.messages,
    required this.scrollController,
    required this.isSending,
  });

  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final bool isSending;

  @override
  State<_ChatMessagesList> createState() => _ChatMessagesListState();
}

class _ChatMessagesListState extends State<_ChatMessagesList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.scrollController.hasClients) return;
      widget.scrollController.jumpTo(
        widget.scrollController.position.maxScrollExtent,
      );
    });
  }

  @override
  void didUpdateWidget(covariant _ChatMessagesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages.length != widget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!widget.scrollController.hasClients) return;
        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      itemCount: widget.messages.length + (widget.isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (widget.isSending && index == widget.messages.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          );
        }

        return ChatBubble(message: widget.messages[index]);
      },
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.navBarBorder),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: !isSending,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك...',
                hintStyle: AppTextStyles.onboardingSubtitle(
                  color: AppColors.subtitleGrey,
                ),
                filled: true,
                fillColor: AppColors.searchBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.primaryBlue,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: isSending ? null : onSend,
              child: SizedBox(
                width: 46,
                height: 46,
                child: isSending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: AppColors.white,
                        size: 22,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatEmptyView extends StatelessWidget {
  const _ChatEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.support_agent_rounded,
              size: 72,
              color: AppColors.subtitleGrey.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 16),
            Text(
              'ابدأ محادثة مع الدعم',
              style: AppTextStyles.skipButton(color: Colors.black87)
                  .copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'اكتب رسالتك بالأسفل وسنرد عليك في أقرب وقت',
              textAlign: TextAlign.center,
              style: AppTextStyles.onboardingSubtitle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
