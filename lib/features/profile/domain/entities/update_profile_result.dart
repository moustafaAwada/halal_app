import 'package:equatable/equatable.dart';

import 'user_profile.dart';

class UpdateProfileResult extends Equatable {
  const UpdateProfileResult({
    required this.profile,
    required this.message,
  });

  final UserProfile profile;
  final String message;

  @override
  List<Object?> get props => [profile, message];
}
