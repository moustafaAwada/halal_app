import '../../../../core/storage/secure_storage_service.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<bool> hasToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage;

  final SecureStorageService _secureStorage;

  @override
  Future<void> saveToken(String token) => _secureStorage.saveToken(token);

  @override
  Future<String?> getToken() => _secureStorage.getToken();

  @override
  Future<void> deleteToken() => _secureStorage.deleteToken();

  @override
  Future<bool> hasToken() => _secureStorage.hasToken();
}
