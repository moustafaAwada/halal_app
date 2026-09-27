import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart' as get_it;
import 'package:dio/dio.dart' as dio_pkg;

import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/usecases/get_stored_user_id.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/update_user_profile.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetStoredUserIdUseCase getStoredUserIdUseCase,
    required GetUserProfileUseCase getUserProfileUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
  })  : _getStoredUserIdUseCase = getStoredUserIdUseCase,
        _getUserProfileUseCase = getUserProfileUseCase,
        _updateUserProfileUseCase = updateUserProfileUseCase,
        super(const ProfileInitial());

  final GetStoredUserIdUseCase _getStoredUserIdUseCase;
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;

  UserProfile? _cachedProfile;

  Future<void> fetchProfile() async {
    emit(const ProfileLoading());

    final userIdResult = await _getStoredUserIdUseCase(const NoParams());

    await userIdResult.fold(
      (failure) async => emit(ProfileError(message: failure.message)),
      (userId) async {
        final result = await _getUserProfileUseCase(
          GetUserProfileParams(userId: userId),
        );

        result.fold(
          (failure) => emit(ProfileError(message: failure.message)),
          (profile) {
            _cachedProfile = profile;
            emit(ProfileLoaded(profile: profile));
          },
        );
      },
    );
  }

  Future<void> retry() => fetchProfile();

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String city,
  }) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(currentState.copyWith(isUpdating: true));
    }

    final userIdResult = await _getStoredUserIdUseCase(const NoParams());

    await userIdResult.fold(
      (failure) async => emit(ProfileError(message: failure.message)),
      (userId) async {
        final result = await _updateUserProfileUseCase(
          UpdateUserProfileParams(
            userId: userId,
            name: name,
            email: email,
            phone: phone,
            address: address,
            city: city,
          ),
        );

        result.fold(
          (failure) {
            if (_cachedProfile != null) {
              emit(ProfileLoaded(profile: _cachedProfile!));
              emit(ProfileActionError(message: failure.message));
            } else {
              emit(ProfileError(message: failure.message));
            }
          },
          (result) {
            _cachedProfile = result.profile;
            emit(
              ProfileUpdateSuccess(
                message: result.message,
                profile: result.profile,
              ),
            );
            emit(ProfileLoaded(profile: result.profile));
          },
        );
      },
    );
  }

  Future<void> deleteAccount() async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(currentState.copyWith(isUpdating: true));
    }
    try {
      final dio = get_it.GetIt.instance<dio_pkg.Dio>(); // We need to import it or just rely on the repository
      await dio.delete('/client/delete-account');
      emit(const ProfileActionError(message: 'Account deleted')); // The UI can handle this to logout
    } catch (e) {
      if (currentState is ProfileLoaded) {
        emit(currentState.copyWith(isUpdating: false));
      }
      emit(ProfileActionError(message: 'Failed to delete account'));
    }
  }
}
