// packages/auth_repository/lib/src/auth_repository.dart - COMPLETE IMPLEMENTATION

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
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
  }) : _apiClient = apiClient,
       _secureStorage = secureStorage,
       _firebaseAuth = firebase_auth.FirebaseAuth.instance,
       _googleSignIn = GoogleSignIn(
         scopes: ['email', 'profile'],
       );

  final ApiClient _apiClient;
  final SecureStorageHelper _secureStorage;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  // ============ Firebase Sign-In ============

  /// Sign in with Google using Firebase Auth
  ///
  /// Flow:
  /// 1. Trigger Google Sign-In UI
  /// 2. User selects Google account
  /// 3. Google returns authentication tokens
  /// 4. Create Firebase credential
  /// 5. Sign in to Firebase
  /// 6. Get Firebase ID token
  /// 7. Return ID token to caller
  ///
  /// Returns:
  ///   - String: Firebase ID token (use this to exchange with backend)
  ///   - null: If user cancelled or error occurred
  Future<String?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In flow...');

      // Step 1: Trigger Google Sign-In UI
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Google Sign-In was cancelled by user');
        return null;
      }

      print('✓ Google account selected: ${googleUser.email}');

      // Step 2: Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('✓ Got Google authentication tokens');

      // Step 3: Create Firebase credential from Google tokens
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('✓ Firebase credential created');

      // Step 4: Sign in to Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      print('✓ Signed in to Firebase: ${userCredential.user?.email}');

      // Step 5: Get Firebase ID token
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      print('✓ Firebase ID token obtained');

      // Step 6: Save ID token temporarily
      await _secureStorage.saveFirebaseIdToken(idToken);

      return idToken;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error: [${e.code}] ${e.message}');
      print('   - Full error: $e');
      throw AuthException('Firebase authentication failed: ${e.message}');
    } catch (e, stackTrace) {
      print('❌ Unexpected Google Sign-In error: $e');
      print(stackTrace);

      String message = e.toString();
      if (message.contains('7:')) {
        message = 'Network error (7). Please check your internet connection.';
      } else if (message.contains('10:')) {
        message =
            'Developer error (10). This usually means the SHA-1 fingerprint or package name is incorrect in the Google Cloud Console.';
      } else if (message.contains('12500')) {
        message =
            'Sign-in failed (12500). Please ensure Google Play Services is updated.';
      } else if (message.contains('12501')) {
        message = 'Sign-in cancelled by user (12501).';
      }

      throw AuthException('Google Sign-In failed: $message');
    }
  }

  // ============ Demo Development Mode ============

  /// Sign in as a demo user (Development only)
  ///
  /// Bypasses backend and Firebase authentication.
  /// Creates a local session with fake tokens and user data.
  Future<User> signInAsDemo() async {
    print('Starting Demo Sign-In flow...');

    // Create a fake user
    final demoUser = const User(
      id: 'demo-user-id',
      email: 'demo@example.com',
      displayName: 'Demo User',
      photoUrl: null, // Could add a placeholder image
      role: 'mother',
    );

    // Create fake tokens
    final fakeTokens = AuthTokens(
      accessToken: 'fake-demo-access-token',
      refreshToken: 'fake-demo-refresh-token',
      expiresIn: 3600,
    );

    // Store fake tokens
    await _secureStorage.saveAccessToken(fakeTokens.accessToken);
    await _secureStorage.saveRefreshToken(fakeTokens.refreshToken);

    // Store user data
    await _secureStorage.saveUserData(jsonEncode(demoUser.toJson()));

    print('✓ Demo session created: ${demoUser.email}');

    return demoUser;
  }

  // ============ Token Exchange ============

  /// Exchange Firebase ID token with backend for JWT access/refresh tokens
  ///
  /// Backend endpoint: POST /auth/exchange
  /// Request body: { "id_token": "firebase_id_token_here" }
  /// Response: {
  ///   "access_token": "jwt_access_token",
  ///   "refresh_token": "jwt_refresh_token",
  ///   "expires_in": 3600,
  ///   "user": { "id": "...", "email": "...", ... }
  /// }
  ///
  /// Args:
  ///   request: Contains Firebase ID token
  ///
  /// Returns:
  ///   AuthTokens: Access token, refresh token, and user info
  Future<AuthTokens> exchangeIdToken(IdTokenExchangeRequest request) async {
    try {
      print('Exchanging Firebase ID token with backend...');

      final response = await _apiClient.post(
        '/auth/exchange',
        data: request.toJson(),
      );

      print('✓ Token exchange successful');

      // Parse response
      final responseData = response.data as Map<String, dynamic>;
      final tokens = AuthTokens.fromJson(responseData);

      // Store tokens securely
      await _secureStorage.saveAccessToken(tokens.accessToken);
      await _secureStorage.saveRefreshToken(tokens.refreshToken);

      print('✓ Tokens stored securely');

      // Store user data
      if (responseData['user'] != null) {
        await _secureStorage.saveUserData(jsonEncode(responseData['user']));
      }

      // Clear temporary Firebase ID token
      await _secureStorage.clearFirebaseIdToken();

      return tokens;
    } catch (e) {
      print('Token exchange error: $e');
      throw AuthException('Token exchange failed: ${e.toString()}');
    }
  }

  // ============ User Session ============

  /// Get current authenticated user
  /// First checks local storage (unless forceRefresh is true),
  /// then fetches from backend if needed.
  ///
  /// Returns null if user no longer exists or token is invalid.
  Future<User?> getCurrentUser({bool forceRefresh = false}) async {
    try {
      // Step 1: Check if we have cached user data (and not forcing refresh)
      if (!forceRefresh) {
        final userData = await _secureStorage.getUserData();
        if (userData != null && userData.isNotEmpty) {
          print('Using cached user data');
          final userMap = jsonDecode(userData) as Map<String, dynamic>;
          return User.fromJson(userMap);
        }
      }

      // Step 2: Check if we have an access token
      final accessToken = await _secureStorage.getAccessToken();
      if (accessToken == null) {
        print('No authentication tokens found');
        return null;
      }

      // Step 3: Fetch user from backend using access token
      print('Fetching user info from backend...');
      final response = await _apiClient.get(
        '/auth/me',
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      final responseData = response.data as Map<String, dynamic>;
      final user = User.fromJson(responseData);

      // Step 4: Cache user data locally
      await _secureStorage.saveUserData(jsonEncode(user.toJson()));

      print('✓ User info retrieved: ${user.email}');
      return user;
    } catch (e) {
      print('Error getting current user: $e');
      // If we can't fetch, token might be expired
      return null;
    }
  }

  /// Refresh access token using refresh token
  ///
  /// Backend endpoint: POST /auth/refresh
  /// Request body: { "refresh_token": "..." }
  /// Response: { "access_token": "...", "expires_in": 3600 }
  ///
  /// This is called automatically when access token expires.
  /// The ApiClient interceptor handles this transparently.
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        throw AuthException('No refresh token available');
      }

      print('Refreshing access token...');

      final response = await _apiClient.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final responseData = response.data as Map<String, dynamic>;
      final newAccessToken = responseData['access_token'] as String;

      await _secureStorage.saveAccessToken(newAccessToken);

      print('✓ Access token refreshed successfully');
    } catch (e) {
      print('Token refresh error: $e');
      // If refresh fails, user needs to re-authenticate
      await signOut();
      throw AuthException('Token refresh failed: ${e.toString()}');
    }
  }

  // ============ Sign Out ============

  /// Sign out - clear all stored data
  ///
  /// Steps:
  /// 1. Sign out from Firebase
  /// 2. Sign out from Google
  /// 3. Clear stored tokens and user data
  Future<void> signOut() async {
    try {
      print('Signing out...');

      // Sign out from Firebase
      await _firebaseAuth.signOut();
      print('✓ Signed out from Firebase');

      // Sign out from Google and clear account caching
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
      print('✓ Signed out and disconnected from Google');

      // Clear stored tokens and user data
      await _secureStorage.clearAll();
      print('✓ Cleared stored authentication data');
    } catch (e) {
      print('Sign out error: $e');
      // Even if errors occur, clear local data
      await _secureStorage.clearAll();
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  // ============ Authentication Status ============

  /// Check if user is authenticated
  /// Returns true only if we have both access and refresh tokens
  Future<bool> isAuthenticated() async {
    final hasAccess = await _secureStorage.hasAccessToken();
    final hasRefresh = await _secureStorage.hasRefreshToken();
    return hasAccess && hasRefresh;
  }

  /// Check if user is currently signed in with Firebase
  /// (Different from having backend JWT tokens)
  bool isFirebaseSignedIn() {
    return _firebaseAuth.currentUser != null;
  }

  /// Get Firebase user (if signed in)
  firebase_auth.User? getFirebaseUser() {
    return _firebaseAuth.currentUser;
  }
}

/// Custom exception for auth errors
class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => 'AuthException: $message';
}
