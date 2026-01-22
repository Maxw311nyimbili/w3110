// packages/forum_repository/lib/src/models/forum_post.dart

import 'package:equatable/equatable.dart';
import 'sync_status.dart';
import 'forum_post_source.dart';
import '../database/forum_database.dart';
import 'dart:convert';

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
    this.viewCount = 0,
    this.isLiked = false,
    this.syncStatus = SyncStatus.synced,
    this.sources = const [],
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
  final int viewCount;
  final bool isLiked;
  final SyncStatus syncStatus;
  final List<ForumPostSource> sources;

  // Helpers
  bool get isPendingSync => syncStatus == SyncStatus.pending;
  bool get isSyncing => syncStatus == SyncStatus.syncing;
  bool get isSynced => syncStatus == SyncStatus.synced;
  bool get hasSyncError => syncStatus == SyncStatus.error;

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
      viewCount: data.viewCount ?? 0,
      isLiked: data.isLiked,
      syncStatus: _parseSyncStatus(data.syncStatus),
      sources: data.sources != null 
          ? (jsonDecode(data.sources!) as List)
              .map((e) => ForumPostSource.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  /// Create from backend JSON
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
      viewCount: json['view_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      syncStatus: SyncStatus.synced, // From server = already synced
      sources: (json['sources'] as List? ?? [])
          .map((e) => ForumPostSource.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  ForumPost copyWith({
    String? id,
    String? localId,
    String? authorId,
    String? authorName,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? commentCount,
    int? likeCount,
    int? viewCount,
    bool? isLiked,
    SyncStatus? syncStatus,
  }) {
    return ForumPost(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      viewCount: viewCount ?? this.viewCount,
      isLiked: isLiked ?? this.isLiked,
      syncStatus: syncStatus ?? this.syncStatus,
      sources: sources ?? this.sources,
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
    authorId,
    authorName,
    title,
    content,
    createdAt,
    updatedAt,
    commentCount,
    likeCount,
    viewCount,
    isLiked,
    syncStatus,
    sources,
  ];
}
