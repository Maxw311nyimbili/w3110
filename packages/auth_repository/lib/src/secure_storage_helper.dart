// packages/auth_repository/lib/src/secure_storage_helper.dart

/// Helper for securely storing auth tokens
/// Uses flutter_secure_storage package
class SecureStorageHelper {
  SecureStorageHelper();

  // TODO: Uncomment when flutter_secure_storage is added
  // final _storage = const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user_data';

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    // TODO: Uncomment when flutter_secure_storage is added
    // await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    // TODO: Uncomment when flutter_secure_storage is added
    // return await _storage.read(key: _accessTokenKey);
    return null; // Temporary
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    // TODO: Uncomment when flutter_secure_storage is added
    // await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    // TODO: Uncomment when flutter_secure_storage is added
    // return await _storage.read(key: _refreshTokenKey);
    return null; // Temporary
  }

  /// Save user data as JSON string
  Future<void> saveUserData(String userData) async {
    // TODO: Uncomment when flutter_secure_storage is added
    // await _storage.write(key: _userKey, value: userData);
  }

  /// Get user data JSON string
  Future<String?> getUserData() async {
    // TODO: Uncomment when flutter_secure_storage is added
    // return await _storage.read(key: _userKey);
    return null; // Temporary
  }

  /// Clear all stored data (on sign out)
  Future<void> clearAll() async {
    // TODO: Uncomment when flutter_secure_storage is added
    // await _storage.deleteAll();
  }
}