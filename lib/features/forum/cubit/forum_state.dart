// lib/features/forum/cubit/forum_state.dart

import 'package:equatable/equatable.dart';
import 'package:forum_repository/forum_repository.dart'; // Import Repo models

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

  // Getters
  bool get isLoading => status == ForumStatus.loading;
  bool get hasPosts => posts.isNotEmpty;
  bool get hasComments => comments.isNotEmpty;
  
  // COMPATIBILITY GETTER for UI
  String? get errorMessage => error; 

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
      error: error, // Allow clearing error by passing null explicitly if desired, but typical copyWith structure:
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

// Removed local ForumPost and ForumComment definitions to use package:forum_repository versions
