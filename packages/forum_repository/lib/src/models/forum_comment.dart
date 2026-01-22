// packages/forum_repository/lib/src/models/forum_comment.dart

import 'package:equatable/equatable.dart';
import 'sync_status.dart';
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
    this.likeCount = 0,
    this.isLiked = false,
    this.syncStatus = SyncStatus.synced,
  });

  final String id; // Server ID
  final String localId; // Local ID (UUID)
  final String postId; // Post this comment belongs to
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likeCount;
  final bool isLiked;
  final SyncStatus syncStatus;

  bool get isPendingSync => syncStatus == SyncStatus.pending;

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
      likeCount: data.likeCount,
      isLiked: data.isLiked,
      syncStatus: _parseSyncStatus(data.syncStatus),
    );
  }

  /// Create from backend JSON
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
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      syncStatus: SyncStatus.synced, // From server = already synced
    );
  }

  ForumComment copyWith({
    String? id,
    String? localId,
    String? postId,
    String? authorId,
    String? authorName,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    bool? isLiked,
    SyncStatus? syncStatus,
  }) {
    return ForumComment(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  static SyncStatus _parseSyncStatus(String status) {
    switch (status) {
      case 'pending': return SyncStatus.pending;
      case 'syncing': return SyncStatus.syncing;
      case 'error': return SyncStatus.error;
      default: return SyncStatus.synced;
    }
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
    likeCount,
    isLiked,
    syncStatus,
  ];
}
