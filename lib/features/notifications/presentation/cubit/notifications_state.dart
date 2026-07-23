part of 'notifications_cubit.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

final class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

final class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded({
    required this.notifications,
    required this.filter,
  });

  final List<NotificationItem> notifications;
  final NotificationsFilter filter;

  @override
  List<Object?> get props => [notifications, filter];
}

final class NotificationsMarkAsReadSuccess extends NotificationsState {
  const NotificationsMarkAsReadSuccess({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class NotificationsActionError extends NotificationsState {
  const NotificationsActionError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class NotificationsError extends NotificationsState {
  const NotificationsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
