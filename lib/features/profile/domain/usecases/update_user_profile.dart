import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/update_profile_result.dart';
import '../repositories/profile_repository.dart';

class UpdateUserProfileUseCase
    implements UseCase<UpdateProfileResult, UpdateUserProfileParams> {
  const UpdateUserProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, UpdateProfileResult>> call(UpdateUserProfileParams params) {
    return _repository.updateUserProfile(
      userId: params.userId,
      name: params.name,
      email: params.email,
      phone: params.phone,
      address: params.address,
      city: params.city,
    );
  }
}

class UpdateUserProfileParams extends Equatable {
  const UpdateUserProfileParams({
    required this.userId,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.city,
  });

  final int userId;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;

  @override
  List<Object?> get props => [userId, name, email, phone, address, city];
}
