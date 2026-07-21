import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/favorite_item.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  const FavoritesRepositoryImpl({
    required FavoritesRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final FavoritesRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<FavoriteItem>>> getFavorites() async {
    try {
      final result = await _remoteDataSource.getFavorites();
      return Right(result.map((item) => item.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(ServerFailure(message: 'حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, FavoriteItem>> addFavorite({
    required int productId,
  }) async {
    try {
      final result = await _remoteDataSource.addFavorite(productId: productId);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(ServerFailure(message: 'حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite({
    required int favoriteId,
  }) async {
    try {
      await _remoteDataSource.removeFavorite(favoriteId: favoriteId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(ServerFailure(message: 'حدث خطأ غير متوقع'));
    }
  }
}
