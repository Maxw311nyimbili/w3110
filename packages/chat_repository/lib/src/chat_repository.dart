// packages/chat_repository/lib/src/chat_repository.dart

import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart'; // Needed for FormData
import 'models/chat_message.dart';
import 'models/chat_query_request.dart';
import 'models/chat_response.dart';
import 'models/validated_answer_response.dart';
import 'local_chat_cache.dart';

/// Chat repository - handles AI chat interactions and message caching
class ChatRepository {
  ChatRepository({
    required ApiClient apiClient,
    required LocalChatCache localCache,
  }) : _apiClient = apiClient,
       _localCache = localCache;

  final ApiClient _apiClient;
  final LocalChatCache _localCache;

  /// Send message to v1 RAG backend
  ///
  /// Backend endpoint: POST /chat/query
  Future<ChatResponse> sendMessage(ChatQueryRequest request) async {
    try {
      final response = await _apiClient.post(
        '/chat/query',
        data: request.toJson(),
      );

      final responseData = response.data as Map<String, dynamic>;
      return ChatResponse.fromJson(responseData);
    } catch (e) {
      throw ChatException('Failed to send message: ${e.toString()}');
    }
  }

  /// Send message to v1.1 validation pipeline
  ///
  /// Backend endpoint: POST /chat/validate
  /// This endpoint can take up to 90 seconds, so we use an extended timeout
  Future<ValidatedAnswerResponse> sendMessageValidated(
    ChatQueryRequest request,
  ) async {
    try {
      print('🔄 Sending validated request...');

      // Use extended timeout for validation pipeline (backend takes ~40-90s)
      final response = await _apiClient.post(
        '/chat/validate',
        data: request.toJson(),
        receiveTimeout: const Duration(seconds: 120), // 2 minutes to be safe
      );

      print('✅ Got response');

      final responseData = response.data as Map<String, dynamic>;
      return ValidatedAnswerResponse.fromJson(responseData);
    } catch (e) {
      print('❌ Validation Error: $e');
      throw ChatException('Failed to validate message: ${e.toString()}');
    }
  }

  /// Send voice message to backend
  ///
  /// Backend endpoint: POST /chat/voice
  Future<Map<String, dynamic>> sendVoiceMessage({
    required String audioPath,
    String? sessionId,
    String? userRole,
    List<String>? interests,
    String? inputLanguage,
    String? outputLanguage,
  }) async {
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioPath,
          filename: 'voice_query.m4a',
        ),
        'session_id': sessionId,
        if (userRole != null) 'user_role': userRole,
        if (interests != null) 'interests': interests,
        if (inputLanguage != null) 'input_language': inputLanguage,
        if (outputLanguage != null) 'output_language': outputLanguage,
      });

      final response = await _apiClient.post(
        '/chat/voice',
        data: formData,
        receiveTimeout: const Duration(seconds: 120),
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ChatException('Failed to send voice message: ${e.toString()}');
    }
  }

  /// Get cached messages from local storage
  Future<List<ChatMessage>> getCachedMessages() async {
    try {
      return await _localCache.getCachedMessages();
    } catch (e) {
      throw ChatException('Failed to get cached messages: ${e.toString()}');
    }
  }

  /// Cache a message locally
  Future<void> cacheMessage(ChatMessage message) async {
    try {
      await _localCache.cacheMessage(message);
    } catch (e) {
      // Don't throw - caching is best-effort
    }
  }

  /// Clear cached messages
  Future<void> clearCache() async {
    try {
      await _localCache.clearCache();
    } catch (e) {
      throw ChatException('Failed to clear cache: ${e.toString()}');
    }
  }

  /// Speak a message in a specific language
  /// Backend endpoint: POST /chat/{message_id}/speak
  Future<Map<String, dynamic>> speakMessage({
    required int messageId,
    required String language,
  }) async {
    try {
      final response = await _apiClient.post(
        '/chat/$messageId/speak',
        queryParameters: {'language': language},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ChatException('Failed to synthesize speech: ${e.toString()}');
    }
  }
}

/// Custom exception for chat repository errors
class ChatException implements Exception {
  ChatException(this.message);
  final String message;

  @override
  String toString() => 'ChatException: $message';
}
