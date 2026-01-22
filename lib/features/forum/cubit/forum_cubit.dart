// lib/features/forum/cubit/forum_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forum_repository/forum_repository.dart'; // Unprefixed for ForumPost/ForumComment availability
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

      // Load posts from local database (always available offline)
      final posts = await _forumRepository.getLocalPosts();

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
      emit(state.copyWith(
        view: ForumView.detail,
        selectedPost: post,
        status: ForumStatus.loading,
      ));

      // Use localId if server ID is empty
      final postId = post.id.isEmpty ? post.localId : post.id;

      // Load comments from local DB
      final comments = await _forumRepository.getLocalComments(postId);

      emit(state.copyWith(
        status: ForumStatus.success,
        comments: comments,
        // Also parse content into lines for discussion view
        answerLines: _parsePostContentToLines(post),
        currentAnswerId: postId,
      ));

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

  /// Create a new post (saved locally immediately, synced in background)
  Future<void> createPost({
    required String title,
    required String content,
    required String authorId,
    required String authorName,
    List<ForumPostSource> sources = const [],
  }) async {
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
      );

      // Save to local database
      await _forumRepository.createLocalPost(
        localId: localId,
        title: title,
        content: content,
        authorId: authorId,
        authorName: authorName,
        sources: sources,
      );

      // Add to sync queue
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
      syncWithBackend();
    } catch (e) {
      emit(state.copyWith(
        status: ForumStatus.error,
        error: 'Failed to create post: ${e.toString()}',
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
      // Find the post and update it locally first
      final postIndex = state.posts.indexWhere((p) => p.id == postId);
      if (postIndex == -1) return;

      final post = state.posts[postIndex];
      final updatedPost = post.copyWith(
        isLiked: !post.isLiked,
        likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
      );

      final updatedPosts = List<ForumPost>.from(state.posts)..[postIndex] = updatedPost;
      
      emit(state.copyWith(
        posts: updatedPosts,
        selectedPost: state.selectedPost?.id == postId ? updatedPost : state.selectedPost,
      ));

      // Call API
      await _forumRepository.togglePostLike(postId);
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
  }) async {
    final lineId = state.selectedLineId;
    if (lineId == null) return;
    
    try {
      // Optimistic update could happen here, but for simplicity we await response
      
      final newComment = await _forumRepository.postLineComment(
        lineId: lineId,
        text: text,
        commentType: commentType,
      );
      
      // Update local state by appending new comment (if matches filter or filter is all)
      // Actually, simplest is to just append it if it matches, assuming server sync handles it.
      // For now, let's just append it to UI list for instant feedback.
      
      final updatedComments = [...state.lineComments, newComment];
      
      // Also update line comment count locally
      final updatedLines = state.answerLines.map((line) {
        if (line.lineId == lineId) {
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
