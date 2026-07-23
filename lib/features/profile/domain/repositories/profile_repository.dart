import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/update_profile_result.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile({required int userId});

  Future<Either<Failure, UpdateProfileResult>> updateUserProfile({
    required int userId,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
  });
}
