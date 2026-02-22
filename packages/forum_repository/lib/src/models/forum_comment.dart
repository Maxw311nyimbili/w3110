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
    this.authorRole = 'user',
    this.authorProfession,
    this.parentCommentId,
    this.isDeleted = false,
    this.version = 1,
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
  final String authorRole; // 'user', 'doctor', 'healthcare_professional'
  final String? authorProfession;
  final String? parentCommentId;
  final bool isDeleted;
  final int version;

  String get text => content;

  bool get isPendingSync => syncStatus == SyncStatus.pending;

  /// Create from Drift database row
  factory ForumComment.fromDatabase(ForumCommentData d) {
    return ForumComment(
      id: d.serverId,
      localId: d.localId,
      postId: d.postId,
      authorId: d.authorId,
      authorName: d.authorName,
      content: d.content,
      createdAt: d.createdAt,
      updatedAt: d.updatedAt,
      likeCount: d.likeCount,
      isLiked: d.isLiked,
      syncStatus: _parseSyncStatus(d.syncStatus),
      authorRole: d.authorRole ?? 'user',
      authorProfession: d.authorProfession,
      parentCommentId: d.parentCommentId,
      isDeleted: d.isDeleted,
      version: d.version,
    );
  }

  /// Create from backend JSON
  factory ForumComment.fromJson(Map<String, dynamic> json) {
    return ForumComment(
      id: json['id'].toString(),
      localId: (json['client_id'] ?? json['id'])
          .toString(), // Prioritize client_id (UUID)
      postId: json['post_id'].toString(),
      authorId: (json['user_id'] ?? json['author_id']).toString(),
      authorName: (json['author_name'] ?? 'Unknown').toString(),
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      syncStatus: SyncStatus.synced,
      authorRole: json['author_role'] as String? ?? 'user',
      authorProfession: json['author_profession'] as String?,
      parentCommentId: json['parent_comment_id']?.toString(),
      isDeleted: json['is_deleted'] as bool? ?? false,
      version: json['version'] as int? ?? 1,
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
    String? authorRole,
    String? authorProfession,
    String? parentCommentId,
    bool? isDeleted,
    int? version,
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
      authorRole: authorRole ?? this.authorRole,
      authorProfession: authorProfession ?? this.authorProfession,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
    );
  }

  static SyncStatus _parseSyncStatus(String status) {
    switch (status) {
      case 'pending':
        return SyncStatus.pending;
      case 'syncing':
        return SyncStatus.syncing;
      case 'error':
        return SyncStatus.error;
      default:
        return SyncStatus.synced;
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
    authorRole,
    authorProfession,
    parentCommentId,
    isDeleted,
    version,
  ];
}
