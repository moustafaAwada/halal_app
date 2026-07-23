part of 'profile_cubit.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.profile,
    this.isUpdating = false,
  });

  final UserProfile profile;
  final bool isUpdating;

  ProfileLoaded copyWith({
    UserProfile? profile,
    bool? isUpdating,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [profile, isUpdating];
}

final class ProfileUpdateSuccess extends ProfileState {
  const ProfileUpdateSuccess({
    required this.message,
    required this.profile,
  });

  final String message;
  final UserProfile profile;

  @override
  List<Object?> get props => [message, profile];
}

final class ProfileActionError extends ProfileState {
  const ProfileActionError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ProfileError extends ProfileState {
  const ProfileError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
