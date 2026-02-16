// lib/features/forum/cubit/forum_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forum_repository/forum_repository.dart'; // Unprefixed for ForumPost/ForumComment availability
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'forum_state.dart';

/// Manages forum posts, comments, and offline sync
class ForumCubit extends Cubit<ForumState> {
  ForumCubit({
    required ForumRepository forumRepository,
  })  : _forumRepository = forumRepository,
        _uuid = const Uuid(),
        super(const ForumState());

  final ForumRepository _forumRepository;
  final Uuid _uuid;
  Timer? _syncTimer;

  /// Initialize forum - load cached posts and start sync
  Future<void> initialize() async {
    try {
      emit(state.copyWith(status: ForumStatus.loading));

      // Load posts from local database
      var posts = await _forumRepository.getLocalPosts();
      
      // Demo data seeding disabled - start with clean slate
      // if (posts.isEmpty) {
      //   await _forumRepository.seedDemoData();
      //   posts = await _forumRepository.getLocalPosts();
      // }

      // Check if there are pending sync items
      final hasPendingSync = await _forumRepository.hasPendingSyncItems();

      emit(state.copyWith(
        status: ForumStatus.success,
        posts: posts, // No need to map if types are same now!
        hasPendingSync: hasPendingSync,
      ));

      // Start background sync (if online)
      _startBackgroundSync();

      // Try to sync immediately
      await syncWithBackend();
    } catch (e) {
      emit(state.copyWith(
        status: ForumStatus.error,
        error: 'Failed to load forum: ${e.toString()}',
      ));
    }
  }

  /// Reset forum - clear all local cache and re-initialize
  /// Used to clear corrupted data from demo accounts
  Future<void> resetAndReload() async {
    try {
      emit(state.copyWith(status: ForumStatus.loading));
      
      // Clear all local database tables
      await _forumRepository.clearCache();
      
      // Re-initialize (which will trigger fresh seeding if empty)
      await initialize();
    } catch (e) {
      emit(state.copyWith(
        status: ForumStatus.error,
        error: 'Failed to reset forum: ${e.toString()}',
      ));
    }
  }

  /// Load posts (from local DB, then sync with backend)
  Future<void> loadPosts() async {
    try {
      emit(state.copyWith(status: ForumStatus.loading));

      final posts = await _forumRepository.getLocalPosts();

      emit(state.copyWith(
        status: ForumStatus.success,
        posts: posts,
      ));

      // Background sync to get latest from server
      syncWithBackend();
    } catch (e) {
      emit(state.copyWith(
        status: ForumStatus.error,
        error: 'Failed to load posts: ${e.toString()}',
      ));
    }
  }

  /// Select a post and load its comments
  Future<void> selectPost(ForumPost post) async {
    try {
      // Find the most up-to-date version of this post from current state
      final currentPost = state.posts.firstWhere(
        (p) => p.id == post.id,
        orElse: () => post,
      );

      emit(state.copyWith(
        view: ForumView.detail,
        selectedPost: currentPost,
        status: ForumStatus.loading,
      ));

      // Use localId if server ID is empty
      final postId = post.id.isEmpty ? post.localId : post.id;

      // Load comments from local DB
      final comments = await _forumRepository.getLocalComments(postId);

      emit(state.copyWith(
        status: ForumStatus.success,
        comments: comments,
        currentAnswerId: postId,
      ));

      // Load sophisticated lines from repo
      await loadAnswerLines(postId);
      
      // Load general discussion comments for this post
      final generalComments = await _forumRepository.getCommentsForLine(
        'general', 
        postId: postId,
      );

      emit(state.copyWith(
        status: ForumStatus.success,
        comments: comments, // Keep old comments too if needed
        lineComments: generalComments, // This is what the drawer uses
        currentAnswerId: postId,
      ));

      // Fallback: If repo has no lines, parse content (legacy/simple posts)
      if (state.answerLines.isEmpty) {
        emit(state.copyWith(
          answerLines: _parsePostContentToLines(post),
        ));
      }

      // Background sync comments
      _syncComments(postId);
    } catch (e) {
      emit(state.copyWith(
        status: ForumStatus.error,
        error: 'Failed to load comments: ${e.toString()}',
      ));
    }
  }

  /// Go back to forum list
  void backToList() {
    emit(state.copyWith(
      view: ForumView.list,
      selectedPost: null,
      comments: const [],
      answerLines: [],
      currentAnswerId: null,
      selectedLineId: null,
    ));
  }

  /// Prepare post content (LLM Title + Formatting)
  Future<Map<String, String>> preparePost(String query, String content) async {
    final result = await _forumRepository.preparePost(query, content);
    return result;
  }

  /// Create a new post (saved locally immediately, synced in background)
  Future<void> createPost({
    required String title,
    required String content,
    required String authorId,
    required String authorName,
    List<ForumPostSource> sources = const [],
    String? originalAnswerId,
  }) async {
    print('DEBUG: ForumCubit.createPost - title: $title');
    try {
      final localId = _uuid.v4();
      final now = DateTime.now();

      // Create post locally first (instant feedback)
      final newPost = ForumPost(
        id: '', // No server ID yet
        localId: localId,
        authorId: authorId,
        authorName: authorName,
        title: title,
        content: content,
        createdAt: now,
        syncStatus: SyncStatus.pending,
        sources: sources,
        originalAnswerId: originalAnswerId,
      );

      // Save to local database
      print('DEBUG: ForumCubit.createPost - saving local post');
      await _forumRepository.createLocalPost(
        localId: localId,
        title: title,
        content: content,
        authorId: authorId,
        authorName: authorName,
        sources: sources,
        originalAnswerId: originalAnswerId,
      );

      // Add to sync queue
      print('DEBUG: ForumCubit.createPost - adding to sync queue');
      await _forumRepository.addToSyncQueue(
        entityType: 'post',
        entityId: localId,
        action: 'create',
      );

      // Update UI immediately
      emit(state.copyWith(
        posts: [newPost, ...state.posts],
        hasPendingSync: true,
      ));

      // Trigger background sync
      print('DEBUG: ForumCubit.createPost - triggering sync');
      syncWithBackend();
    } catch (e) {
      print('DEBUG: ForumCubit.createPost - ERROR: $e');
      emit(state.copyWith(
        status: ForumStatus.error,
        error: 'Failed to create post: ${e.toString()}',
      ));
    }
  }

  /// Delete a post (local and from server if synced)
  Future<void> deletePost(String localId) async {
    try {
      // Remove from local database
      await _forumRepository.deletePost(localId);

      // Update UI immediately
      emit(state.copyWith(
        posts: state.posts.where((p) => p.localId != localId).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ForumStatus.error,
        error: 'Failed to delete post: ${e.toString()}',
      ));
    }
  }

  /// Add a comment to a post (offline-first)
  Future<void> addComment({
    required String postId,
    required String content,
    required String authorId,
    required String authorName,
  }) async {
    try {
      final localId = _uuid.v4();
      final now = DateTime.now();

      final newComment = ForumComment(
        id: '',
        localId: localId,
        postId: postId,
        authorId: authorId,
        authorName: authorName,
        content: content,
        createdAt: now,
        syncStatus: SyncStatus.pending,
      );

      // Save locally
      await _forumRepository.createLocalComment(
        localId: localId,
        postId: postId,
        content: content,
        authorId: authorId,
        authorName: authorName,
      );

      // Add to sync queue
      await _forumRepository.addToSyncQueue(
        entityType: 'comment',
        entityId: localId,
        action: 'create',
      );

      // Update UI
      emit(state.copyWith(
        comments: [...state.comments, newComment],
        hasPendingSync: true,
      ));

      // Update comment count on post
      if (state.selectedPost != null) {
        final updatedPost = state.selectedPost!.copyWith(
          commentCount: state.selectedPost!.commentCount + 1,
        );
        emit(state.copyWith(selectedPost: updatedPost));
      }

      // Trigger sync
      syncWithBackend();
    } catch (e) {
      emit(state.copyWith(
        status: ForumStatus.error,
        error: 'Failed to add comment: ${e.toString()}',
      ));
    }
  }

  /// Sync with backend (upload pending changes, download new content)
  Future<void> syncWithBackend() async {
    if (state.isSyncing) return;

    try {
      emit(state.copyWith(isSyncing: true));

      // Process pending local changes
      await _forumRepository.processSyncQueue();

      // Fetch latest posts from server
      await _forumRepository.fetchPostsFromServer();

      // Reload from local storage to get merged updates
      final posts = await _forumRepository.getLocalPosts();

      emit(state.copyWith(
        posts: posts,
        isSyncing: false,
        hasPendingSync: false,
        lastSyncTime: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(
        isSyncing: false,
        error: 'Sync failed: ${e.toString()}',
      ));
    }
  }

  /// Search for posts
  Future<void> searchPosts(String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(searchQuery: '', searchResults: const []));
      return;
    }

    try {
      emit(state.copyWith(status: ForumStatus.loading, searchQuery: query));
      
      final results = await _forumRepository.searchPosts(query);
      
      emit(state.copyWith(
        status: ForumStatus.success,
        searchResults: results,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ForumStatus.error,
        error: 'Search failed: ${e.toString()}',
      ));
    }
  }

  /// Toggle like on post (optimistic update)
  Future<void> togglePostLike(String postId) async {
    try {
      // 1. Update main posts list
      final postIndex = state.posts.indexWhere((p) => p.id == postId);
      List<ForumPost>? updatedPosts;
      ForumPost? targetPost;

      if (postIndex != -1) {
        final post = state.posts[postIndex];
        targetPost = post.copyWith(
          isLiked: !post.isLiked,
          likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
        );
        updatedPosts = List<ForumPost>.from(state.posts)..[postIndex] = targetPost;
      }

      // 2. Update search results list if applicable
      final searchIndex = state.searchResults.indexWhere((p) => p.id == postId);
      List<ForumPost>? updatedSearchResults;
      if (searchIndex != -1) {
        targetPost ??= state.searchResults[searchIndex].copyWith(
          isLiked: !state.searchResults[searchIndex].isLiked,
          likeCount: state.searchResults[searchIndex].isLiked 
              ? state.searchResults[searchIndex].likeCount - 1 
              : state.searchResults[searchIndex].likeCount + 1,
        );
        updatedSearchResults = List<ForumPost>.from(state.searchResults)..[searchIndex] = targetPost;
      }

      if (targetPost == null) return;

      emit(state.copyWith(
        posts: updatedPosts ?? state.posts,
        searchResults: updatedSearchResults ?? state.searchResults,
        selectedPost: state.selectedPost?.id == postId ? targetPost : state.selectedPost,
      ));

      // 3. Call API and persist locally
      await _forumRepository.togglePostLike(
        postId,
        isLiked: targetPost.isLiked,
        likeCount: targetPost.likeCount,
      );
    } catch (e) {
      // Revert on failure (simple implementation: reload posts)
      loadPosts();
      emit(state.copyWith(error: 'Failed to update like: ${e.toString()}'));
    }
  }

  /// Toggle like on comment (optimistic update)
  Future<void> toggleCommentLike(String commentId) async {
    try {
      final commentIndex = state.comments.indexWhere((c) => c.id == commentId);
      if (commentIndex == -1) return;

      final comment = state.comments[commentIndex];
      final updatedComment = comment.copyWith(
        isLiked: !comment.isLiked,
        likeCount: comment.isLiked ? comment.likeCount - 1 : comment.likeCount + 1,
      );

      final updatedComments = List<ForumComment>.from(state.comments)..[commentIndex] = updatedComment;
      
      emit(state.copyWith(comments: updatedComments));

      // Call API
      await _forumRepository.toggleCommentLike(commentId);
    } catch (e) {
      // Revert (reload comments for current post)
      if (state.selectedPost != null) {
        selectPost(state.selectedPost!);
      }
      emit(state.copyWith(error: 'Failed to update comment like: ${e.toString()}'));
    }
  }

  /// Flag a post
  Future<void> flagPost(String postId) async {
    try {
      await _forumRepository.flagPost(postId);
      // Optional: show a confirmation message in the UI
    } catch (e) {
      emit(state.copyWith(error: 'Failed to report post: ${e.toString()}'));
    }
  }

  /// Start background sync timer (every 30 seconds when online)
  void _startBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (state.hasPendingSync) {
        syncWithBackend();
      }
    });
  }

  /// Sync comments for a specific post
  Future<void> _syncComments(String postId) async {
    try {
      // TODO: Implement comment sync
    } catch (e) {
      // Silent fail
    }
  }

  // ============================================================
  // LINE-LEVEL FORUM METHODS
  // ============================================================

  /// Load discussion lines for a specific answer
  Future<void> loadAnswerLines(String answerId) async {
    try {
      emit(state.copyWith(
        status: ForumStatus.loading,
        currentAnswerId: answerId,
      ));
      
      final lines = await _forumRepository.getLinesForAnswer(answerId);
      
      emit(state.copyWith(
        status: ForumStatus.success,
        answerLines: lines,
        selectedLineId: null, // Clear selection on new answer load
        lineComments: [],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ForumStatus.error,
        error: 'Failed to load discussion lines: ${e.toString()}',
      ));
    }
  }

  /// Toggle the forum view for a specific message/answer.
  /// If it's already the current one, we might want to "close" it, 
  /// but usually the UI handles the visibility.
  void toggleForumView(String answerId) {
    if (state.currentAnswerId == answerId) {
      emit(state.copyWith(currentAnswerId: null, answerLines: []));
    } else {
      loadAnswerLines(answerId);
    }
  }

  /// Toggle selection of a line. If same line selected, deselect.
  Future<void> toggleLineSelection(String lineId) async {
    if (state.selectedLineId == lineId) {
      // Deselect
      emit(state.copyWithNullableLineId(clearLineId: true));
    } else {
      // Select new line and load comments
      emit(state.copyWith(
        selectedLineId: lineId,
        status: ForumStatus.loading,
      ));
      
      await _loadLineComments(lineId);
    }
  }
  
  /// Helper: Load comments for the currently selected line
  Future<void> _loadLineComments(String lineId) async {
    try {
      final comments = await _forumRepository.getCommentsForLine(
        lineId, 
        filter: state.activeFilter,
      );
      
      emit(state.copyWith(
        status: ForumStatus.success,
        lineComments: comments,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ForumStatus.error,
        error: 'Failed to load comments: ${e.toString()}',
      ));
    }
  }

  /// Change filter for comments (e.g., 'all' -> 'clinician')
  Future<void> filterComments(String filter) async {
    if (filter == state.activeFilter) return;
    
    emit(state.copyWith(
      activeFilter: filter,
      status: ForumStatus.loading,
    ));
    
    if (state.selectedLineId != null) {
      await _loadLineComments(state.selectedLineId!);
    }
  }

  /// Post a comment to the currently selected line
  Future<void> postLineComment({
    required String text,
    required String commentType,
    String? lineId,
    String? postId,
  }) async {
    final effectiveLineId = lineId ?? state.selectedLineId;
    if (effectiveLineId == null) return;
    
    // Handle "general" comments by redirection to addComment if needed,
    // or keep using postLineComment if backend supports it.
    // For now, let's assume we want to support typed comments everywhere.
    
    try {
      // Optimistic update could happen here, but for simplicity we await response
      
      final newComment = await _forumRepository.postLineComment(
        lineId: effectiveLineId,
        text: text,
        commentType: commentType,
        postId: postId,
      );
      
      // Update local state by appending new comment (if matches filter or filter is all)
      // Actually, simplest is to just append it if it matches, assuming server sync handles it.
      // For now, let's just append it to UI list for instant feedback.
      
      final updatedComments = [...state.lineComments, newComment];
      
      // Also update line comment count locally
      final updatedLines = state.answerLines.map((line) {
        if (line.lineId == effectiveLineId) {
          return line.copyWith(commentCount: line.commentCount + 1);
        }
        return line;
      }).toList();
      
      emit(state.copyWith(
        lineComments: updatedComments,
        answerLines: updatedLines,
      ));
      
    } catch (e) {
      emit(state.copyWith(
        status: ForumStatus.error,
        error: 'Failed to post comment: ${e.toString()}',
      ));
    }
  }

  /// Clear error state
  void clearError() {
    emit(state.clearError());
  }

  /// Helper: Parse post content into selectable lines for discussion
  List<ForumAnswerLine> _parsePostContentToLines(ForumPost post) {
    final content = post.content;
    final postId = post.id.isEmpty ? post.localId : post.id;
    
    // Simple sentence splitter (can be improved with regex)
    final sentences = content
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
        
    return sentences.asMap().entries.map((entry) {
      final index = entry.key;
      final text = entry.value;
      return ForumAnswerLine(
        lineId: '${postId}_L$index',
        answerId: postId,
        lineNumber: index + 1,
        text: text,
        discussionTitle: text.length > 30 ? '${text.substring(0, 30)}...' : text,
        commentCount: 0, // In a real app, fetch these counts
      );
    }).toList();
  }

  @override
  Future<void> close() {
    _syncTimer?.cancel();
    return super.close();
  }
}
