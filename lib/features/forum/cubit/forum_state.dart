// lib/features/forum/cubit/forum_state.dart

import 'package:equatable/equatable.dart';

enum ForumStatus {
  initial,
  loading,
  success,
  error,
}

enum ForumView {
  list,
  detail,
}

/// Immutable forum state - manages posts, comments, and sync
class ForumState extends Equatable {
  const ForumState({
    this.status = ForumStatus.initial,
    this.view = ForumView.list,
    this.posts = const [],
    this.selectedPost,
    this.comments = const [],
    this.error,
    this.isSyncing = false,
    this.hasPendingSync = false,
    this.lastSyncTime,
  });

  final ForumStatus status;
  final ForumView view;
  final List<ForumPost> posts;
  final ForumPost? selectedPost;
  final List<ForumComment> comments;
  final String? error;
  final bool isSyncing;
  final bool hasPendingSync; // Has unsynced local changes
  final DateTime? lastSyncTime;

  bool get isLoading => status == ForumStatus.loading;
  bool get hasPosts => posts.isNotEmpty;
  bool get hasComments => comments.isNotEmpty;

  ForumState copyWith({
    ForumStatus? status,
    ForumView? view,
    List<ForumPost>? posts,
    ForumPost? selectedPost,
    List<ForumComment>? comments,
    String? error,
    bool? isSyncing,
    bool? hasPendingSync,
    DateTime? lastSyncTime,
  }) {
    return ForumState(
      status: status ?? this.status,
      view: view ?? this.view,
      posts: posts ?? this.posts,
      selectedPost: selectedPost ?? this.selectedPost,
      comments: comments ?? this.comments,
      error: error,
      isSyncing: isSyncing ?? this.isSyncing,
      hasPendingSync: hasPendingSync ?? this.hasPendingSync,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  ForumState clearError() {
    return copyWith(error: null);
  }

  @override
  List<Object?> get props => [
    status,
    view,
    posts,
    selectedPost,
    comments,
    error,
    isSyncing,
    hasPendingSync,
    lastSyncTime,
  ];
}

/// Forum post model
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
    this.syncStatus = SyncStatus.synced,
  });

  final String id; // Server ID (empty if not synced yet)
  final String localId; // Local unique ID (UUID)
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int commentCount;
  final int likeCount;
  final bool isLiked;
  final SyncStatus syncStatus;

  bool get isPendingSync => syncStatus == SyncStatus.pending;
  bool get isSyncing => syncStatus == SyncStatus.syncing;
  bool get isSynced => syncStatus == SyncStatus.synced;
  bool get hasSyncError => syncStatus == SyncStatus.error;

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
      isLiked: isLiked ?? this.isLiked,
      syncStatus: syncStatus ?? this.syncStatus,
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

/// Forum comment model
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
    this.syncStatus = SyncStatus.synced,
  });

  final String id; // Server ID
  final String localId; // Local unique ID
  final String postId; // Post this comment belongs to
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final SyncStatus syncStatus;

  bool get isPendingSync => syncStatus == SyncStatus.pending;

  ForumComment copyWith({
    String? id,
    String? localId,
    String? postId,
    String? authorId,
    String? authorName,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      syncStatus: syncStatus ?? this.syncStatus,
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

/// Sync status for offline-first data
enum SyncStatus {
  synced, // Successfully synced with server
  pending, // Waiting to be synced
  syncing, // Currently syncing
  error, // Sync failed (will retry)
}