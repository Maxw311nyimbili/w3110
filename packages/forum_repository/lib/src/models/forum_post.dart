// packages/forum_repository/lib/src/models/forum_post.dart

import 'package:equatable/equatable.dart';
import '../database/forum_database.dart';

/// Forum post model - represents a forum post in the app
class ForumPost extends Equatable {
  const ForumPost({
    required this.id,
    required this.localId,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.commentCount = 0,
    this.likeCount = 0,
    this.isLiked = false,
    this.syncStatus = 'synced',
  });

  final String id; // Server ID
  final String localId; // Local ID (UUID)
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int commentCount;
  final int likeCount;
  final bool isLiked;
  final String syncStatus;

  /// Create from Drift database row
  factory ForumPost.fromDatabase(ForumPostData data) {
    return ForumPost(
      id: data.serverId,
      localId: data.localId,
      authorId: data.authorId,
      authorName: data.authorName,
      title: data.title,
      content: data.content,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      commentCount: data.commentCount,
      likeCount: data.likeCount,
      isLiked: data.isLiked,
      syncStatus: data.syncStatus,
    );
  }

  /// Create from backend JSON
  /// Expected response from GET /forum/posts:
  /// {
  ///   "id": "server-uuid",
  ///   "author_id": "user-uuid",
  ///   "author_name": "John Doe",
  ///   "title": "Question about...",
  ///   "content": "...",
  ///   "created_at": "2025-01-15T10:30:00Z",
  ///   "updated_at": "2025-01-15T10:35:00Z",
  ///   "comment_count": 5,
  ///   "like_count": 12
  /// }
  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'] as String,
      localId: json['id'] as String, // Use server ID as local ID when from server
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      commentCount: json['comment_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      syncStatus: 'synced', // From server = already synced
    );
  }

  @override
  List<Object?> get props => [
    id,
    localId,
    authorId,
    authorName,
    title,
    content,
    createdAt,
    updatedAt,
    commentCount,
    likeCount,
    isLiked,
    syncStatus,
  ];
}