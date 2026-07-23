import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/usecases/get_stored_user_id.dart';
import '../../domain/usecases/get_unread_notifications.dart';

part 'unread_notifications_state.dart';

/// Lightweight cubit used by the home header to show a red unread badge.
class UnreadNotificationsCubit extends Cubit<UnreadNotificationsState> {
  UnreadNotificationsCubit({
    required GetStoredUserIdUseCase getStoredUserIdUseCase,
    required GetUnreadNotificationsUseCase getUnreadNotificationsUseCase,
  })  : _getStoredUserIdUseCase = getStoredUserIdUseCase,
        _getUnreadNotificationsUseCase = getUnreadNotificationsUseCase,
        super(const UnreadNotificationsInitial());

  final GetStoredUserIdUseCase _getStoredUserIdUseCase;
  final GetUnreadNotificationsUseCase _getUnreadNotificationsUseCase;

  Future<void> checkUnread() async {
    final userIdResult = await _getStoredUserIdUseCase(const NoParams());

    await userIdResult.fold(
      (_) async {
        // Fail silently for the badge — home should still render.
        emit(const UnreadNotificationsLoaded(hasUnread: false, count: 0));
      },
      (clientId) async {
        final result = await _getUnreadNotificationsUseCase(
          GetUnreadNotificationsParams(clientId: clientId),
        );

        result.fold(
          (_) => emit(
            const UnreadNotificationsLoaded(hasUnread: false, count: 0),
          ),
          (notifications) => emit(
            UnreadNotificationsLoaded(
              hasUnread: notifications.isNotEmpty,
              count: notifications.length,
            ),
          ),
        );
      },
    );
  }
}
