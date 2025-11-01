// packages/auth_repository/lib/src/secure_storage_helper.dart - CORRECT VERSION

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Helper for securely storing auth tokens and user data
/// Uses flutter_secure_storage package for encrypted storage
class SecureStorageHelper {
  SecureStorageHelper()
      : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'medlink_access_token';
  static const _refreshTokenKey = 'medlink_refresh_token';
  static const _userKey = 'medlink_user_data';
  static const _firebaseIdTokenKey = 'medlink_firebase_id_token';

  // ============ Access Token ============

  /// Save access token securely
  /// Access tokens are short-lived (typically 1 hour)
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
      print('✓ Access token saved securely');
    } catch (e) {
      throw Exception('Failed to save access token: $e');
    }
  }

  /// Get stored access token
  /// Returns null if no token is stored
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      print('Error reading access token: $e');
      return null;
    }
  }

  /// Check if access token is stored
  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ============ Refresh Token ============

  /// Save refresh token securely
  /// Refresh tokens are long-lived (typically 7 days)
  /// Used to get new access tokens when they expire
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
      print('✓ Refresh token saved securely');
    } catch (e) {
      throw Exception('Failed to save refresh token: $e');
    }
  }

  /// Get stored refresh token
  /// Returns null if no token is stored
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      print('Error reading refresh token: $e');
      return null;
    }
  }

  /// Check if refresh token is stored
  Future<bool> hasRefreshToken() async {
    final token = await getRefreshToken();
    return token != null && token.isNotEmpty;
  }

  // ============ Firebase ID Token ============

  /// Save Firebase ID token temporarily
  /// This is used during the authentication flow before exchanging with backend
  Future<void> saveFirebaseIdToken(String token) async {
    try {
      await _storage.write(key: _firebaseIdTokenKey, value: token);
      print('✓ Firebase ID token saved temporarily');
    } catch (e) {
      throw Exception('Failed to save Firebase ID token: $e');
    }
  }

  /// Get Firebase ID token
  Future<String?> getFirebaseIdToken() async {
    try {
      return await _storage.read(key: _firebaseIdTokenKey);
    } catch (e) {
      print('Error reading Firebase ID token: $e');
      return null;
    }
  }

  /// Clear Firebase ID token after successful exchange
  Future<void> clearFirebaseIdToken() async {
    try {
      await _storage.delete(key: _firebaseIdTokenKey);
    } catch (e) {
      print('Error clearing Firebase ID token: $e');
    }
  }

  // ============ User Data ============

  /// Save user data as JSON string
  /// Called after successful authentication with user info from backend
  Future<void> saveUserData(String userData) async {
    try {
      await _storage.write(key: _userKey, value: userData);
      print('✓ User data saved securely');
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  /// Get user data JSON string
  /// Returns null if no user data is stored
  Future<String?> getUserData() async {
    try {
      return await _storage.read(key: _userKey);
    } catch (e) {
      print('Error reading user data: $e');
      return null;
    }
  }

  // ============ Cleanup ============

  /// Clear all stored authentication data
  /// Called on sign out or when tokens are invalidated
  Future<void> clearAll() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _firebaseIdTokenKey),
        _storage.delete(key: _userKey),
      ]);
      print('✓ All authentication data cleared');
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }

  /// Clear only tokens (keep user data)
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
      ]);
      print('✓ Tokens cleared');
    } catch (e) {
      throw Exception('Failed to clear tokens: $e');
    }
  }

  /// Verify secure storage is working
  /// Useful for debugging storage issues
  Future<bool> testSecureStorage() async {
    try {
      const testKey = '_test_storage_key';
      const testValue = '_test_storage_value';

      // Write
      await _storage.write(key: testKey, value: testValue);

      // Read
      final value = await _storage.read(key: testKey);

      // Cleanup
      await _storage.delete(key: testKey);

      return value == testValue;
    } catch (e) {
      print('Secure storage test failed: $e');
      return false;
    }
  }
}