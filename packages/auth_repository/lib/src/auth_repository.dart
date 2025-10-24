// packages/auth_repository/lib/src/auth_repository.dart

import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'models/auth_tokens.dart';
import 'models/id_token_exchange_request.dart';
import 'models/user.dart';
import 'secure_storage_helper.dart';

/// Authentication repository - handles OAuth, token management, and user sessions
class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required SecureStorageHelper secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage;

  final ApiClient _apiClient;
  final SecureStorageHelper _secureStorage;

  /// Sign in with Google OAuth
  /// Returns Google ID token to exchange with backend
  ///
  /// Flow:
  /// 1. Trigger Firebase Google Sign-In
  /// 2. Get ID token from Firebase
  /// 3. Return ID token (caller exchanges it with backend)
  ///
  /// TODO: Implement when Firebase Auth is configured
  /// Required packages: firebase_auth, google_sign_in
  Future<String?> signInWithGoogle() async {
    /*
    try {
      // Step 1: Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null; // User cancelled sign-in
      }

      // Step 2: Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Step 3: Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in to Firebase
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Step 5: Get ID token
      final idToken = await userCredential.user?.getIdToken();

      return idToken;
    } catch (e) {
      throw AuthException('Google sign-in failed: ${e.toString()}');
    }
    */

    // TEMPORARY: Return mock token for development
    return 'mock_google_id_token_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Exchange Google ID token with backend for access/refresh tokens
  ///
  /// Backend endpoint: POST /auth/exchange
  /// Request body: { "id_token": "..." }
  /// Response: { "access_token": "...", "refresh_token": "...", "expires_in": 3600 }
  Future<AuthTokens> exchangeIdToken(IdTokenExchangeRequest request) async {
    try {
      final response = await _apiClient.post(
        '/auth/exchange',
        data: request.toJson(),
      );

      // Cast response.data to Map
      final responseData = response.data as Map<String, dynamic>;
      final tokens = AuthTokens.fromJson(responseData);

      // Store tokens securely
      await _secureStorage.saveAccessToken(tokens.accessToken);
      await _secureStorage.saveRefreshToken(tokens.refreshToken);

      return tokens;
    } catch (e) {
      throw AuthException('Token exchange failed: ${e.toString()}');
    }
  }

  /// Get current authenticated user
  ///
  /// Backend endpoint: GET /auth/me (requires access token)
  /// Response: { "id": "...", "email": "...", "display_name": "...", ... }
  Future<User?> getCurrentUser() async {
    try {
      // Check if we have stored user data
      final userData = await _secureStorage.getUserData();
      if (userData != null) {
        // Cast jsonDecode result to Map
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        return User.fromJson(userMap);
      }

      // If not, fetch from backend
      final accessToken = await _secureStorage.getAccessToken();
      if (accessToken == null) {
        return null; // Not authenticated
      }

      final response = await _apiClient.get(
        '/auth/me',
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      // Cast response.data to Map
      final responseData = response.data as Map<String, dynamic>;
      final user = User.fromJson(responseData);

      // Cache user data
      await _secureStorage.saveUserData(jsonEncode(user.toJson()));

      return user;
    } catch (e) {
      // If fetch fails, token might be expired
      return null;
    }
  }

  /// Refresh access token using refresh token
  ///
  /// Backend endpoint: POST /auth/refresh
  /// Request body: { "refresh_token": "..." }
  /// Response: { "access_token": "...", "expires_in": 3600 }
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        throw AuthException('No refresh token available');
      }

      final response = await _apiClient.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      // Cast response.data to Map
      final responseData = response.data as Map<String, dynamic>;
      final newAccessToken = responseData['access_token'] as String;

      await _secureStorage.saveAccessToken(newAccessToken);
    } catch (e) {
      // If refresh fails, user needs to re-authenticate
      await signOut();
      throw AuthException('Token refresh failed: ${e.toString()}');
    }
  }

  /// Sign out - clear all stored data
  Future<void> signOut() async {
    try {
      // TODO: Uncomment when Firebase Auth is configured
      // await FirebaseAuth.instance.signOut();
      // await GoogleSignIn().signOut();

      // Clear stored tokens and user data
      await _secureStorage.clearAll();
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final accessToken = await _secureStorage.getAccessToken();
    return accessToken != null;
  }
}

/// Custom exception for auth errors
class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => 'AuthException: $message';
}