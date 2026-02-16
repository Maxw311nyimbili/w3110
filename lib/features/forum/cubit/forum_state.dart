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
    this.searchResults = const [],
    this.searchQuery = '',
    this.selectedPost,
    this.comments = const [],
    
    this.answerLines = const [],
    this.currentAnswerId,
    this.selectedLineId,
    this.lineComments = const [],
    this.activeFilter = 'all',
    
    this.error,
    this.isSyncing = false,
    this.hasPendingSync = false,
    this.lastSyncTime,
  });

  final ForumStatus status;
  final ForumView view;
  
  // Legacy/General Forum
  final List<ForumPost> posts;
  final List<ForumPost> searchResults;
  final String searchQuery;
  final ForumPost? selectedPost;
  final List<ForumComment> comments;
  
  // New: Line-Level Discussion
  final String? currentAnswerId; // The ID of the answer currently in forum view
  final List<ForumAnswerLine> answerLines;
  final String? selectedLineId; // Currently tappable line
  final List<ForumLineComment> lineComments; // Comments for the selected line
  final String activeFilter; // 'all', 'clinician', etc.
  
  final String? error;
  final bool isSyncing;
  final bool hasPendingSync; // Has unsynced local changes
  final DateTime? lastSyncTime;

  // Getters
  bool get isLoading => status == ForumStatus.loading;
  bool get hasPosts => posts.isNotEmpty;
  bool get hasComments => comments.isNotEmpty;
  bool get isSearching => searchQuery.isNotEmpty;
  List<ForumPost> get displayPosts => isSearching ? searchResults : posts;
  
  // Return either general comments or line comments based on view context
  // BUT UI expects a simple list for ThreadSummaryHeader
  List<ForumComment> get displayComments => comments;
  
  // COMPATIBILITY GETTER for UI
  String? get errorMessage => error; 

  ForumState copyWith({
    ForumStatus? status,
    ForumView? view,
    List<ForumPost>? posts,
    List<ForumPost>? searchResults,
    String? searchQuery,
    ForumPost? selectedPost,
    List<ForumComment>? comments,
    
    List<ForumAnswerLine>? answerLines,
    String? currentAnswerId,
    String? selectedLineId,
    List<ForumLineComment>? lineComments,
    String? activeFilter,
    
    String? error,
    bool? isSyncing,
    bool? hasPendingSync,
    DateTime? lastSyncTime,
  }) {
    return ForumState(
      status: status ?? this.status,
      view: view ?? this.view,
      posts: posts ?? this.posts,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedPost: selectedPost ?? this.selectedPost,
      comments: comments ?? this.comments,
      
      answerLines: answerLines ?? this.answerLines,
      currentAnswerId: currentAnswerId ?? this.currentAnswerId,
      selectedLineId: selectedLineId ?? this.selectedLineId, 
      lineComments: lineComments ?? this.lineComments,
      activeFilter: activeFilter ?? this.activeFilter,
      
      error: error,
      isSyncing: isSyncing ?? this.isSyncing,
      hasPendingSync: hasPendingSync ?? this.hasPendingSync,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
  
  // Special copyWith to allow clearing nullable fields
  ForumState copyWithNullableLineId({
    String? selectedLineId,
    String? currentAnswerId,
    bool clearLineId = false,
    bool clearAnswerId = false,
  }) {
     return ForumState(
      status: status,
      view: view,
      posts: posts,
      searchResults: searchResults,
      searchQuery: searchQuery,
      selectedPost: selectedPost,
      comments: comments,
      answerLines: answerLines,
      currentAnswerId: clearAnswerId ? null : (currentAnswerId ?? this.currentAnswerId),
      selectedLineId: clearLineId ? null : (selectedLineId ?? this.selectedLineId),
      lineComments: lineComments,
      activeFilter: activeFilter,
      error: error,
      isSyncing: isSyncing,
      hasPendingSync: hasPendingSync,
      lastSyncTime: lastSyncTime,
    );
  }

  ForumState clearError() {
    return copyWith(error: null);
  }
  
  // Helper to find title for a line
  String? getLineDiscussionTitle(String lineId) {
    try {
      return answerLines.firstWhere((l) => l.lineId == lineId).discussionTitle;
    } catch (_) {
      return null;
    }
  }
  
  // Helper to get text for a line
  String getLineText(String lineId) {
    try {
      return answerLines.firstWhere((l) => l.lineId == lineId).text;
    } catch (_) {
      return '';
    }
  }
  
  // Helper to get comment count
  int getCommentCountForLine(String lineId) {
    try {
      return answerLines.firstWhere((l) => l.lineId == lineId).commentCount;
    } catch (_) {
      return 0;
    }
  }
  
  // Helper to retrieve all comments for a line (optionally filtering is done in UI or Cubit, but state has the source)
  List<ForumLineComment> getCommentsForLine(String lineId) {
    // If we only store *currently selected* line comments, this is just that list.
    // This design assumes we fetch comments when line is selected.
    if (selectedLineId == lineId) return lineComments;
    return [];
  }

  @override
  List<Object?> get props => [
    status,
    view,
    posts,
    searchResults,
    searchQuery,
    selectedPost,
    comments,
    answerLines,
    selectedLineId,
    lineComments,
    activeFilter,
    error,
    isSyncing,
    hasPendingSync,
    lastSyncTime,
  ];
}

// Removed local ForumPost and ForumComment definitions to use package:forum_repository versions
