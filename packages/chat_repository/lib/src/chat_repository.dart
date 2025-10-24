// packages/chat_repository/lib/src/chat_repository.dart

import 'package:api_client/api_client.dart';
import 'models/chat_message.dart';
import 'models/chat_query_request.dart';
import 'models/chat_response.dart';
import 'local_chat_cache.dart';

/// Chat repository - handles AI chat interactions and message caching
class ChatRepository {
  ChatRepository({
    required ApiClient apiClient,
    required LocalChatCache localCache,
  })  : _apiClient = apiClient,
        _localCache = localCache;

  final ApiClient _apiClient;
  final LocalChatCache _localCache;

  /// Send message to AI backend
  ///
  /// Backend endpoint: POST /chat/query
  /// Request: { "message": "...", "conversation_id": "...", "image_url": "..." }
  /// Response: { "response": "...", "sentences": [...], "sources": [...], "confidence": 0.9 }
  Future<ChatResponse> sendMessage(ChatQueryRequest request) async {
    try {
      final response = await _apiClient.post(
        '/chat/query',
        data: request.toJson(),
      );

      // Cast response.data to Map
      final responseData = response.data as Map<String, dynamic>;

      return ChatResponse.fromJson(responseData);
    } catch (e) {
      throw ChatException('Failed to send message: ${e.toString()}');
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
}

/// Custom exception for chat repository errors
class ChatException implements Exception {
  ChatException(this.message);
  final String message;

  @override
  String toString() => 'ChatException: $message';
}