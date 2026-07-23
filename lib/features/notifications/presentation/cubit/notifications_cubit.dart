import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/usecases/get_stored_user_id.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/usecases/get_all_notifications.dart';
import '../../domain/usecases/get_unread_notifications.dart';
import '../../domain/usecases/mark_notification_as_read.dart';

part 'notifications_state.dart';

enum NotificationsFilter { all, unread }

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    required GetStoredUserIdUseCase getStoredUserIdUseCase,
    required GetAllNotificationsUseCase getAllNotificationsUseCase,
    required GetUnreadNotificationsUseCase getUnreadNotificationsUseCase,
    required MarkNotificationAsReadUseCase markNotificationAsReadUseCase,
  })  : _getStoredUserIdUseCase = getStoredUserIdUseCase,
        _getAllNotificationsUseCase = getAllNotificationsUseCase,
        _getUnreadNotificationsUseCase = getUnreadNotificationsUseCase,
        _markNotificationAsReadUseCase = markNotificationAsReadUseCase,
        super(const NotificationsInitial());

  final GetStoredUserIdUseCase _getStoredUserIdUseCase;
  final GetAllNotificationsUseCase _getAllNotificationsUseCase;
  final GetUnreadNotificationsUseCase _getUnreadNotificationsUseCase;
  final MarkNotificationAsReadUseCase _markNotificationAsReadUseCase;

  NotificationsFilter _filter = NotificationsFilter.all;
  List<NotificationItem> _notifications = const [];
  int? _clientId;

  NotificationsFilter get filter => _filter;

  Future<void> loadNotifications({
    NotificationsFilter filter = NotificationsFilter.all,
  }) async {
    _filter = filter;
    emit(const NotificationsLoading());

    final clientId = await _resolveClientId();
    if (clientId == null) return;

    if (filter == NotificationsFilter.unread) {
      await _fetchUnread(clientId);
    } else {
      await _fetchAll(clientId);
    }
  }

  Future<void> switchFilter(NotificationsFilter filter) {
    if (_filter == filter && state is NotificationsLoaded) {
      return Future.value();
    }
    return loadNotifications(filter: filter);
  }

  Future<void> retry() => loadNotifications(filter: _filter);

  /// Marks [notificationId] as read, then updates the local list in-place.
  Future<void> markAsRead(int notificationId) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    // Skip if already read or not in the current list.
    NotificationItem? target;
    for (final item in current.notifications) {
      if (item.id == notificationId) {
        target = item;
        break;
      }
    }
    if (target == null || target.read) return;

    final result = await _markNotificationAsReadUseCase(
      MarkNotificationAsReadParams(notificationId: notificationId),
    );

    result.fold(
      (failure) {
        // Keep the loaded list visible; surface error via transient state.
        emit(NotificationsActionError(message: failure.message));
        emit(
          NotificationsLoaded(
            notifications: _notifications,
            filter: _filter,
          ),
        );
      },
      (message) {
        _notifications = _notifications.map((item) {
          if (item.id != notificationId) return item;
          return item.copyWith(read: true);
        }).toList();

        // On the unread tab, drop items that are no longer unread.
        final visible = _filter == NotificationsFilter.unread
            ? _notifications.where((item) => !item.read).toList()
            : _notifications;

        emit(NotificationsMarkAsReadSuccess(message: message));
        emit(
          NotificationsLoaded(
            notifications: visible,
            filter: _filter,
          ),
        );
      },
    );
  }

  Future<int?> _resolveClientId() async {
    if (_clientId != null) return _clientId;

    final userIdResult = await _getStoredUserIdUseCase(const NoParams());
    return userIdResult.fold(
      (failure) {
        emit(NotificationsError(message: failure.message));
        return null;
      },
      (userId) {
        _clientId = userId;
        return userId;
      },
    );
  }

  Future<void> _fetchAll(int clientId) async {
    final result = await _getAllNotificationsUseCase(
      GetAllNotificationsParams(clientId: clientId),
    );

    result.fold(
      (failure) => emit(NotificationsError(message: failure.message)),
      (notifications) {
        _notifications = notifications;
        emit(
          NotificationsLoaded(
            notifications: notifications,
            filter: NotificationsFilter.all,
          ),
        );
      },
    );
  }

  Future<void> _fetchUnread(int clientId) async {
    final result = await _getUnreadNotificationsUseCase(
      GetUnreadNotificationsParams(clientId: clientId),
    );

    result.fold(
      (failure) => emit(NotificationsError(message: failure.message)),
      (notifications) {
        _notifications = notifications;
        emit(
          NotificationsLoaded(
            notifications: notifications,
            filter: NotificationsFilter.unread,
          ),
        );
      },
    );
  }
}
