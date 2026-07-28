import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/chat_message.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isSentByMe;

    return Align(
      // Spec: mine → right, support → left.
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMine ? AppColors.primaryBlue : AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMine ? 16 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 16),
            ),
            border: isMine
                ? null
                : Border.all(color: AppColors.navBarBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMine && message.senderName.isNotEmpty) ...[
                Text(
                  message.senderName,
                  style: AppTextStyles.onboardingSubtitle(
                    color: AppColors.primaryBlue,
                  ).copyWith(fontSize: 11, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                message.messageText,
                style: AppTextStyles.onboardingSubtitle(
                  color: isMine ? AppColors.white : Colors.black87,
                ).copyWith(fontSize: 14, height: 1.35),
              ),
              if (message.createdAt != null) ...[
                const SizedBox(height: 6),
                Text(
                  _formatTime(message.createdAt!),
                  style: AppTextStyles.onboardingSubtitle(
                    color: isMine
                        ? AppColors.white.withValues(alpha: 0.75)
                        : AppColors.subtitleGrey,
                  ).copyWith(fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final local = date.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
