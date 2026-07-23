import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../home/presentation/widgets/home_shimmer.dart';
import '../cubit/notifications_cubit.dart';
import '../widgets/notification_card.dart';
import '../widgets/notifications_shimmer.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<NotificationsCubit>();
      if (cubit.state is NotificationsInitial) {
        cubit.loadNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.searchBackground,
        appBar: AppBar(
          backgroundColor: AppColors.searchBackground,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'التنبيهات',
            style: AppTextStyles.onboardingTitle(
              color: Colors.black87,
            ).copyWith(fontSize: 22),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            color: Colors.black87,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<NotificationsCubit, NotificationsState>(
            listenWhen: (previous, current) =>
                current is NotificationsMarkAsReadSuccess ||
                current is NotificationsActionError ||
                current is NotificationsError,
            listener: (context, state) {
              if (state is NotificationsMarkAsReadSuccess) {
                SnackbarUtils.showSuccessSnackBar(context, state.message);
              } else if (state is NotificationsActionError) {
                SnackbarUtils.showErrorSnackBar(context, state.message);
              } else if (state is NotificationsError) {
                SnackbarUtils.showErrorSnackBar(
                  context,
                  state.message.isNotEmpty
                      ? state.message
                      : 'حدث خطأ أثناء جلب التنبيهات',
                );
              }
            },
            buildWhen: (previous, current) =>
                current is! NotificationsMarkAsReadSuccess &&
                current is! NotificationsActionError,
            builder: (context, state) {
              final selectedFilter = switch (state) {
                NotificationsLoaded(:final filter) => filter,
                _ => context.read<NotificationsCubit>().filter,
              };

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _NotificationsFilterToggle(selectedFilter: selectedFilter),
                  const SizedBox(height: 8),
                  Expanded(
                    child: switch (state) {
                      NotificationsInitial() || NotificationsLoading() =>
                        const NotificationsShimmer(),
                      NotificationsError(:final message) => HomeErrorView(
                          message: message.isNotEmpty
                              ? message
                              : 'حدث خطأ أثناء جلب التنبيهات',
                          onRetry: () =>
                              context.read<NotificationsCubit>().retry(),
                        ),
                      NotificationsLoaded(:final notifications) =>
                        notifications.isEmpty
                            ? _NotificationsEmptyView(
                                filter: selectedFilter,
                              )
                            : RefreshIndicator(
                                color: AppColors.primaryBlue,
                                onRefresh: () => context
                                    .read<NotificationsCubit>()
                                    .loadNotifications(
                                      filter: selectedFilter,
                                    ),
                                child: ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    8,
                                    20,
                                    24,
                                  ),
                                  itemCount: notifications.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final item = notifications[index];
                                    return NotificationCard(
                                      notification: item,
                                      onTap: () => context
                                          .read<NotificationsCubit>()
                                          .markAsRead(item.id),
                                    );
                                  },
                                ),
                              ),
                      _ => const NotificationsShimmer(),
                    },
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

class _NotificationsFilterToggle extends StatelessWidget {
  const _NotificationsFilterToggle({required this.selectedFilter});

  final NotificationsFilter selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.navBarBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: _FilterButton(
                label: 'الكل',
                isSelected: selectedFilter == NotificationsFilter.all,
                onTap: () => context
                    .read<NotificationsCubit>()
                    .switchFilter(NotificationsFilter.all),
              ),
            ),
            Expanded(
              child: _FilterButton(
                label: 'غير مقروءة',
                isSelected: selectedFilter == NotificationsFilter.unread,
                onTap: () => context
                    .read<NotificationsCubit>()
                    .switchFilter(NotificationsFilter.unread),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primaryBlue.withValues(alpha: 0.12)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.onboardingSubtitle(
              color: isSelected ? AppColors.primaryBlue : Colors.black87,
            ).copyWith(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationsEmptyView extends StatelessWidget {
  const _NotificationsEmptyView({required this.filter});

  final NotificationsFilter filter;

  @override
  Widget build(BuildContext context) {
    final isUnread = filter == NotificationsFilter.unread;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUnread
                  ? Icons.mark_email_read_outlined
                  : Icons.notifications_none_rounded,
              size: 72,
              color: AppColors.subtitleGrey.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              isUnread ? 'لا توجد تنبيهات غير مقروءة' : 'لا توجد تنبيهات',
              style: AppTextStyles.skipButton(color: Colors.black87)
                  .copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              isUnread
                  ? 'لقد قرأت جميع التنبيهات'
                  : 'ستظهر تنبيهاتك هنا عند وصول إشعارات جديدة',
              textAlign: TextAlign.center,
              style: AppTextStyles.onboardingSubtitle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
