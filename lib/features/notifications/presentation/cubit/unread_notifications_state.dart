part of 'unread_notifications_cubit.dart';

sealed class UnreadNotificationsState extends Equatable {
  const UnreadNotificationsState();

  @override
  List<Object?> get props => [];
}

final class UnreadNotificationsInitial extends UnreadNotificationsState {
  const UnreadNotificationsInitial();
}

final class UnreadNotificationsLoaded extends UnreadNotificationsState {
  const UnreadNotificationsLoaded({
    required this.hasUnread,
    required this.count,
  });

  final bool hasUnread;
  final int count;

  @override
  List<Object?> get props => [hasUnread, count];
}
