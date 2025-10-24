// packages/chat_repository/lib/src/models/chat_query_request.dart

import 'package:equatable/equatable.dart';

/// Request body for sending chat message to backend
class ChatQueryRequest extends Equatable {
  const ChatQueryRequest({
    required this.message,
    this.conversationId,
    this.imageUrl,
  });

  final String message;
  final String? conversationId; // For maintaining conversation context
  final String? imageUrl; // For image-based queries (from MedScanner)

  /// Convert to JSON for POST /chat/query
  /// Expected request body:
  /// {
  ///   "message": "Is ibuprofen safe during pregnancy?",
  ///   "conversation_id": "uuid-here",
  ///   "image_url": "https://..."
  /// }
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (conversationId != null) 'conversation_id': conversationId,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  @override
  List<Object?> get props => [message, conversationId, imageUrl];
}