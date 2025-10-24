// packages/chat_repository/lib/src/local_chat_cache.dart

import 'dart:convert';
import 'models/chat_message.dart';

/// Helper for caching chat messages locally
/// Uses shared_preferences or local database
class LocalChatCache {
  LocalChatCache();

  // TODO: Uncomment when shared_preferences is added
  // late final SharedPreferences _prefs;

  static const _messagesKey = 'chat_messages';
  static const _maxCachedMessages = 100;

  /// Initialize cache
  Future<void> initialize() async {
    // TODO: Uncomment when shared_preferences is added
    // _prefs = await SharedPreferences.getInstance();
  }

  /// Cache a message
  Future<void> cacheMessage(ChatMessage message) async {
    try {
      final messages = await getCachedMessages();
      messages.add(message);

      // Keep only last N messages
      if (messages.length > _maxCachedMessages) {
        messages.removeRange(0, messages.length - _maxCachedMessages);
      }

      final messagesJson = messages.map((m) => m.toJson()).toList();

      // TODO: Uncomment when shared_preferences is added
      // await _prefs.setString(_messagesKey, jsonEncode(messagesJson));
    } catch (e) {
      // Silent fail - caching is not critical
    }
  }

  /// Get all cached messages
  Future<List<ChatMessage>> getCachedMessages() async {
    try {
      // TODO: Uncomment when shared_preferences is added
      // final data = _prefs.getString(_messagesKey);
      // if (data != null) {
      //   final List<dynamic> messagesJson = jsonDecode(data);
      //   return messagesJson
      //       .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
      //       .toList();
      // }
      return []; // Temporary
    } catch (e) {
      return [];
    }
  }

  /// Clear all cached messages
  Future<void> clearCache() async {
    try {
      // TODO: Uncomment when shared_preferences is added
      // await _prefs.remove(_messagesKey);
    } catch (e) {
      // Silent fail
    }
  }
}