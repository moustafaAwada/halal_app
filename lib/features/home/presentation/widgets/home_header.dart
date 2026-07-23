import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../notifications/presentation/cubit/unread_notifications_cubit.dart';
import '../../../notifications/presentation/pages/notifications_screen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  Future<void> _openNotifications(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => sl<NotificationsCubit>()..loadNotifications(),
          child: const NotificationsScreen(),
        ),
      ),
    );

    // Refresh the red badge after the user leaves the notifications screen.
    if (context.mounted) {
      context.read<UnreadNotificationsCubit>().checkUnread();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          BlocBuilder<UnreadNotificationsCubit, UnreadNotificationsState>(
            builder: (context, state) {
              final hasUnread = state is UnreadNotificationsLoaded &&
                  state.hasUnread;

              return _CircleIconButton(
                icon: Icons.notifications_none_rounded,
                showBadge: hasUnread,
                onPressed: () => _openNotifications(context),
              );
            },
          ),
          Expanded(
            child: Column(
              children: [

                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const AppAssetImage(
              assetPath: AppAssets.logo,
              fit: BoxFit.contain,
              placeholderIcon: Icons.restaurant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.showBadge = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.searchBackground,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(icon, color: Colors.black87),
              if (showBadge)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.searchBackground,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
