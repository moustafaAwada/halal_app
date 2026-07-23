import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/update_profile_result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, UserProfile>> getUserProfile({
    required int userId,
  }) async {
    try {
      final result = await _remoteDataSource.getUserProfile(userId);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(ServerFailure(message: 'حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, UpdateProfileResult>> updateUserProfile({
    required int userId,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
  }) async {
    try {
      final payload = UserProfileModel(
        id: userId,
        name: name ?? '',
        email: email ?? '',
        phone: phone ?? '',
        address: address ?? '',
        city: city ?? '',
        isActive: true,
        ordersCount: 0,
        favoritesCount: 0,
      ).toUpdateJson(
        name: name,
        email: email,
        phone: phone,
        address: address,
        city: city,
      );

      final message =
          await _remoteDataSource.updateUserProfile(userId, payload);
      final profileResult = await getUserProfile(userId: userId);

      return profileResult.map(
        (profile) => UpdateProfileResult(profile: profile, message: message),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(
        ServerFailure(message: 'حدث خطأ أثناء تحديث البيانات'),
      );
    }
  }
}
