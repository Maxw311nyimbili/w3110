// packages/chat_repository/lib/src/models/chat_query_request.dart

import 'package:equatable/equatable.dart';

/// Request body for sending chat message to backend
class ChatQueryRequest extends Equatable {
  const ChatQueryRequest({
    required this.query,
    this.conversationId,
    this.imageUrl,
    this.userRole,
    this.interests,
  });

  final String query;
  final String? conversationId;
  final String? imageUrl;
  final String? userRole;
  final List<String>? interests;

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      if (conversationId != null) 'conversation_id': conversationId,
      if (imageUrl != null) 'image_url': imageUrl,
      if (userRole != null) 'user_role': userRole,
      if (interests != null) 'interests': interests,
    };
  }

  @override
  List<Object?> get props => [query, conversationId, imageUrl, userRole, interests];
}