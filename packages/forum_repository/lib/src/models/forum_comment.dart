// packages/forum_repository/lib/src/models/forum_comment.dart

import 'package:equatable/equatable.dart';
import '../database/forum_database.dart';

/// Forum comment model - represents a comment on a forum post
class ForumComment extends Equatable {
  const ForumComment({
    required this.id,
    required this.localId,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.syncStatus = 'synced',
  });

  final String id; // Server ID
  final String localId; // Local ID (UUID)
  final String postId; // Post this comment belongs to
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String syncStatus;

  /// Create from Drift database row
  factory ForumComment.fromDatabase(ForumCommentData data) {
    return ForumComment(
      id: data.serverId,
      localId: data.localId,
      postId: data.postId,
      authorId: data.authorId,
      authorName: data.authorName,
      content: data.content,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      syncStatus: data.syncStatus,
    );
  }

  /// Create from backend JSON
  /// Expected response from GET /forum/posts/{id}/comments:
  /// {
  ///   "id": "server-uuid",
  ///   "post_id": "post-uuid",
  ///   "author_id": "user-uuid",
  ///   "author_name": "Jane Smith",
  ///   "content": "Great question!",
  ///   "created_at": "2025-01-15T10:45:00Z"
  /// }
  factory ForumComment.fromJson(Map<String, dynamic> json) {
    return ForumComment(
      id: json['id'] as String,
      localId: json['id'] as String, // Use server ID as local ID when from server
      postId: json['post_id'] as String,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      syncStatus: 'synced', // From server = already synced
    );
  }

  @override
  List<Object?> get props => [
    id,
    localId,
    postId,
    authorId,
    authorName,
    content,
    createdAt,
    updatedAt,
    syncStatus,
  ];
}