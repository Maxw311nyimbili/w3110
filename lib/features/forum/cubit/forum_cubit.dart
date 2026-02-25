// lib/features/forum/cubit/forum_cubit.dart

import 'dart:async';
import 'dart:convert';
import 'package:auth_repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:forum_repository/forum_repository.dart'; // Unprefixed for ForumPost/ForumComment availability
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'forum_state.dart';

/// Manages forum posts, comments, and offline sync
class ForumCubit extends Cubit<ForumState> {
  ForumCubit({
    required ForumRepository forumRepository,
    required AuthRepository authRepository,
  }) : _forumRepository = forumRepository,
       _authRepository = authRepository,
       _uuid = const Uuid(),
       super(const ForumState());

  final ForumRepository _forumRepository;
  final AuthRepository _authRepository;
  final Uuid _uuid;
  Timer? _syncTimer;

  /// Initialize forum - load posts from server
  Future<void> initialize() async {
    try {
      emit(state.copyWith(status: ForumStatus.loading));

      // Fetch all posts from server (community feed)
      final allPosts = await _forumRepository.fetchAllPostsFromServer();

      // Check if there are pending sync items
      final hasPendingSync = await _forumRepository.hasPendingSyncItems();

      emit(
        state.copyWith(
          status: ForumStatus.success,
          posts: allPosts,
          hasPendingSync: hasPendingSync,
        ),
      );

      // Start background sync (if online)
      _startBackgroundSync();

      // Try to sync immediately
      await syncWithBackend();
    } catch (e) {
      emit(
        state.copyWith(
          status: ForumStatus.error,
          error: 'Failed to load forum: ${e.toString()}',
        ),
      );
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
      emit(
        state.copyWith(
          status: ForumStatus.error,
          error: 'Failed to reset forum: ${e.toString()}',
        ),
      );
    }
  }

  /// Load posts (fetch all from server for community feed)
  Future<void> loadPosts() async {
    try {
      emit(state.copyWith(status: ForumStatus.loading));

      // Fetch all posts from server (community feed)
      final allPosts = await _forumRepository.fetchAllPostsFromServer();

      emit(
        state.copyWith(
          status: ForumStatus.success,
          posts: allPosts,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ForumStatus.error,
          error: 'Failed to load posts: ${e.toString()}',
        ),
      );
    }
  }

  /// Toggle post filter between all posts and user's posts
  void setPostFilter(PostFilter filter) {
    emit(state.copyWith(postFilter: filter));
  }

  /// Get filtered posts based on current filter
  List<ForumPost> getFilteredPosts(String currentUserId) {
    print('🔍 Filter: ${state.postFilter}, User ID: $currentUserId');
    if (state.postFilter == PostFilter.mine) {
      final myPosts = state.posts
          .where((post) => post.authorId == currentUserId)
          .toList();
      print('✅ My Posts: ${myPosts.length} out of ${state.posts.length} total');
      return myPosts;
    }
    print('✅ All Posts: ${state.posts.length}');
    return state.posts; // Show all posts
  }

  /// Get current user ID from auth repository
  Future<String> getCurrentUserId() async {
    final user = await _authRepository.getCurrentUser();
    return user?.id ?? '';
  }

  String? _cachedUserId;

  /// Cache user ID for filtering
  Future<void> _cacheUserId() async {
    try {
      const secureStorage = FlutterSecureStorage();
      final userDataJson = await secureStorage.read(key: 'thanzi_user_data');

      print(
        '📦 Read from secure storage: ${userDataJson?.substring(0, 50)}...',
      ); // First 50 chars

      if (userDataJson != null && userDataJson.isNotEmpty) {
        final userData = jsonDecode(userDataJson) as Map<String, dynamic>;
        _cachedUserId = userData['id'] as String?;
        print('✅ Cached user ID: $_cachedUserId');
      } else {
        print('❌ No user data in secure storage');
      }
    } catch (e, stack) {
      print('❌ Error caching user ID: $e');
      print('Stack: ${stack.toString().substring(0, 200)}');
      _cachedUserId = null;
    }
  }

  /// Select a post and load its comments
  Future<void> selectPost(ForumPost post) async {
    try {
      // Find the most up-to-date version of this post from current state
      final currentPost = state.posts.firstWhere(
        (p) =>
            p.localId == post.localId || (p.id.isNotEmpty && p.id == post.id),
        orElse: () => post,
      );

      emit(
        state.copyWith(
          view: ForumView.detail,
          selectedPost: currentPost,
          status: ForumStatus.loading,
        ),
      );

      // Use localId if server ID is empty
      final postId = post.id.isEmpty ? post.localId : post.id;

      // Load comments from local DB
      final comments = await _forumRepository.getLocalComments(postId);

      emit(
        state.copyWith(
          status: ForumStatus.success,
          comments: comments,
          currentAnswerId: postId,
        ),
      );

      // Trigger background sync to "heal" any ID drifts or fetch new comments
      unawaited(_forumRepository.fetchCommentsFromServer(postId));

      // Load authoritative lines from repository (server or cache)
      List<ForumAnswerLine> lines = [];
      try {
        // Use either server ID or local UUID - backend now resolves both
        final idToUse = post.id.isNotEmpty ? post.id : post.localId;
        lines = await _forumRepository.getLinesForPost(idToUse);
      } catch (e) {
        print('DEBUG: Error matching lines: $e');
        // Fallback to local parsing
        lines = _parsePostContentToLines(post);
      }

      if (lines.isEmpty) {
        lines = _parsePostContentToLines(post);
      }

      print('DEBUG: Loaded ${lines.length} lines from backend');
      for (final line in lines) {
        print(
          'DEBUG: Line ${line.lineId} has commentCount: ${line.commentCount}',
        );
      }

      emit(
        state.copyWith(
          status: ForumStatus.success,
          comments: comments,
          currentAnswerId: postId,
          answerLines: lines,
          lineComments: const [], // Clear line comments when selecting new post
        ),
      );

      // Background sync comments
      _syncComments(postId);
    } catch (e) {
      emit(
        state.copyWith(
          status: ForumStatus.error,
          error: 'Failed to load comments: ${e.toString()}',
        ),
      );
    }
  }

  /// Go back to forum list
  void backToList() {
    emit(
      state.copyWith(
        view: ForumView.list,
        selectedPost: null,
        comments: const [],
        answerLines: [],
        currentAnswerId: null,
        selectedLineId: null,
      ),
    );
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
      emit(
        state.copyWith(
          posts: [newPost, ...state.posts],
          hasPendingSync: true,
        ),
      );

      // Trigger background sync
      print('DEBUG: ForumCubit.createPost - triggering sync');
      syncWithBackend();
    } catch (e) {
      print('DEBUG: ForumCubit.createPost - ERROR: $e');
      emit(
        state.copyWith(
          status: ForumStatus.error,
          error: 'Failed to create post: ${e.toString()}',
        ),
      );
    }
  }

  /// Delete a post (local and from server if synced)
  Future<void> deletePost(String localId) async {
    try {
      // Remove from local database
      await _forumRepository.deletePost(localId);

      // Update UI immediately
      emit(
        state.copyWith(
          posts: state.posts.where((p) => p.localId != localId).toList(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ForumStatus.error,
          error: 'Failed to delete post: ${e.toString()}',
        ),
      );
    }
  }

  /// Update a post
  Future<void> updatePost({
    required String localId,
    required String title,
    required String content,
  }) async {
    try {
      emit(state.copyWith(status: ForumStatus.loading));

      await _forumRepository.updatePost(
        localId: localId,
        title: title,
        content: content,
      );

      // Update UI
      final updatedPosts = state.posts.map((p) {
        if (p.localId == localId) {
          return p.copyWith(title: title, content: content);
        }
        return p;
      }).toList();

      emit(
        state.copyWith(
          status: ForumStatus.success,
          posts: updatedPosts,
          selectedPost: state.selectedPost?.localId == localId
              ? state.selectedPost!.copyWith(title: title, content: content)
              : state.selectedPost,
        ),
      );

      syncWithBackend();
    } catch (e) {
      emit(
        state.copyWith(
          status: ForumStatus.error,
          error: 'Failed to update post: ${e.toString()}',
        ),
      );
    }
  }

  /// Add a comment to a post (offline-first)
  Future<void> addComment({
    required String postId,
    required String content,
    required String authorId,
    required String authorName,
    String? parentCommentId,
  }) async {
    try {
      final localId = _uuid.v4();
      final effectiveParentId =
          parentCommentId ??
          (state.replyingToComment?.isLineComment == false
              ? state.replyingToComment?.localId
              : null);

      // 1. Create locally for instant feedback
      await _forumRepository.createLocalComment(
        localId: localId,
        postId: postId,
        content: content,
        authorId: authorId,
        authorName: authorName,
        parentCommentId: effectiveParentId,
      );

      final newComment = ForumComment(
        id: '',
        localId: localId,
        postId: postId,
        authorId: authorId,
        authorName: authorName,
        content: content,
        createdAt: DateTime.now(),
        parentCommentId: effectiveParentId,
        syncStatus: SyncStatus.pending,
      );

      // 2. Update UI
      emit(
        state.copyWith(
          comments: [...state.comments, newComment],
          hasPendingSync: true,
        ),
      );

      // Update comment count on post
      if (state.selectedPost != null) {
        final updatedPost = state.selectedPost!.copyWith(
          commentCount: state.selectedPost!.commentCount + 1,
        );
        emit(
          state.copyWith(
            selectedPost: updatedPost,
            replyingToComment: null, // Clear replying indicator
          ),
        );
      }

      // 3. Add to sync queue
      await _forumRepository.addToSyncQueue(
        entityType: 'comment',
        entityId: localId,
        action: 'create',
      );

      // Trigger sync
      syncWithBackend();
    } catch (e) {
      emit(
        state.copyWith(
          status: ForumStatus.error,
          error: 'Failed to add comment: ${e.toString()}',
        ),
      );
    }
  }

  /// Update an existing comment
  Future<void> updateComment({
    required String localId,
    required String serverId,
    required String content,
  }) async {
    try {
      await _forumRepository.updateComment(
        localId: localId,
        serverId: serverId,
        content: content,
      );

      final updatedComments = state.comments.map((c) {
        if (c.localId == localId) {
          return c.copyWith(content: content);
        }
        return c;
      }).toList();

      emit(state.copyWith(comments: updatedComments));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update comment: ${e.toString()}'));
    }
  }

  /// Delete a comment
  Future<void> deleteComment(String localId) async {
    try {
      await _forumRepository.deleteComment(localId);

      final updatedComments = state.comments
          .where((c) => c.localId != localId)
          .toList();

      emit(
        state.copyWith(
          comments: updatedComments,
          selectedPost: state.selectedPost != null
              ? state.selectedPost!.copyWith(
                  commentCount: state.selectedPost!.commentCount - 1,
                )
              : null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: 'Failed to delete comment: ${e.toString()}'));
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

      emit(
        state.copyWith(
          posts: posts,
          isSyncing: false,
          hasPendingSync: false,
          lastSyncTime: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSyncing: false,
          error: 'Sync failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Search posts locally
  void searchPosts(String query) {
    if (query.isEmpty) {
      emit(
        state.copyWith(
          isSearching: false,
          searchQuery: '',
          searchResults: [],
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isSearching: true,
        searchQuery: query,
      ),
    );

    // Simple local search for instant feedback
    final results = state.posts
        .where(
          (post) =>
              post.title.toLowerCase().contains(query.toLowerCase()) ||
              post.content.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    emit(
      state.copyWith(
        searchResults: results,
      ),
    );

    // Also trigger similarity search if query is long enough
    if (query.length > 3) {
      searchSimilarPosts(query);
    }
  }

  /// Search for similar posts (Vector Search)
  Future<void> searchSimilarPosts(String text) async {
    try {
      emit(state.copyWith(status: ForumStatus.loading));
      final results = await _forumRepository.searchSimilarPosts(text);
      emit(
        state.copyWith(
          status: ForumStatus.success,
          searchResults: results,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ForumStatus.error,
          error: 'Similarity search failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Toggle like on post (optimistic update)
  Future<void> togglePostLike(String postId) async {
    try {
      // 1. Update main posts list
      final postIndex = state.posts.indexWhere(
        (p) => p.localId == postId || p.id == postId,
      );
      List<ForumPost>? updatedPosts;
      ForumPost? targetPost;

      if (postIndex != -1) {
        final post = state.posts[postIndex];
        targetPost = post.copyWith(
          isLiked: !post.isLiked,
          likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
        );
        updatedPosts = List<ForumPost>.from(state.posts)
          ..[postIndex] = targetPost;
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
        updatedSearchResults = List<ForumPost>.from(state.searchResults)
          ..[searchIndex] = targetPost;
      }

      if (targetPost == null) return;

      emit(
        state.copyWith(
          posts: updatedPosts ?? state.posts,
          searchResults: updatedSearchResults ?? state.searchResults,
          selectedPost: state.selectedPost?.localId == postId
              ? targetPost
              : state.selectedPost,
        ),
      );

      // 3. Call API and persist locally
      await _forumRepository.togglePostLike(
        postId, // Note: Repository should accept both, and Backend now resolves.
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
  Future<void> toggleCommentLike(
    String commentId, {
    required bool isLineComment,
  }) async {
    try {
      if (isLineComment) {
        final commentIndex = state.lineComments.indexWhere(
          (c) => c.localId == commentId || c.id == commentId,
        );
        if (commentIndex == -1) return;

        final comment = state.lineComments[commentIndex];
        final updatedComment = comment.copyWith(
          isLiked: !comment.isLiked,
          likeCount: comment.isLiked
              ? comment.likeCount - 1
              : comment.likeCount + 1,
        );

        final updatedLineComments = List<ForumLineComment>.from(
          state.lineComments,
        )..[commentIndex] = updatedComment;
        emit(state.copyWith(lineComments: updatedLineComments));
      } else {
        final commentIndex = state.comments.indexWhere(
          (c) => c.localId == commentId || c.id == commentId,
        );
        if (commentIndex == -1) return;

        final comment = state.comments[commentIndex];
        final updatedComment = comment.copyWith(
          isLiked: !comment.isLiked,
          likeCount: comment.isLiked
              ? comment.likeCount - 1
              : comment.likeCount + 1,
        );

        final updatedComments = List<ForumComment>.from(state.comments)
          ..[commentIndex] = updatedComment;
        emit(state.copyWith(comments: updatedComments));
      }

      // Call API
      await _forumRepository.toggleCommentLike(
        commentId,
        isLineComment: isLineComment,
      );
    } catch (e) {
      // Revert (reload comments for current post)
      if (state.selectedPost != null && !isLineComment) {
        // Only reload post comments if it's a regular comment
        selectPost(state.selectedPost!);
      }
      emit(
        state.copyWith(error: 'Failed to update comment like: ${e.toString()}'),
      );
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
      emit(
        state.copyWith(
          status: ForumStatus.loading,
          currentAnswerId: answerId,
        ),
      );

      final lines = await _forumRepository.getLinesForAnswer(answerId);

      emit(
        state.copyWith(
          status: ForumStatus.success,
          answerLines: lines,
          selectedLineId: null, // Clear selection on new answer load
          lineComments: [],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ForumStatus.error,
          error: 'Failed to load discussion lines: ${e.toString()}',
        ),
      );
    }
  }

  /// Toggle the forum view for a specific message/answer.
  /// If it's already the current one, we might want to "close" it,
  /// but usually the UI handles the visibility.
  void toggleForumView(String answerId) {
    if (state.currentAnswerId == answerId) {
      emit(state.copyWithNullableLineId(clearAnswerId: true));
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
      emit(
        state.copyWith(
          selectedLineId: lineId,
          status: ForumStatus.loading,
        ),
      );

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

      emit(
        state.copyWith(
          status: ForumStatus.success,
          lineComments: comments,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ForumStatus.error,
          error: 'Failed to load comments: ${e.toString()}',
        ),
      );
    }
  }

  /// Change filter for comments (e.g., 'all' -> 'clinician')
  Future<void> filterComments(String filter) async {
    if (filter == state.activeFilter) return;

    emit(
      state.copyWith(
        activeFilter: filter,
        status: ForumStatus.loading,
      ),
    );

    if (state.selectedLineId != null) {
      await _loadLineComments(state.selectedLineId!);
    }
  }

  /// Post a comment to the currently selected line
  Future<void> postLineComment({
    required String text,
    required String commentType,
    String? lineId,
    String? parentCommentId,
  }) async {
    final effectiveLineId = lineId ?? state.selectedLineId;
    final effectiveParentId =
        parentCommentId ??
        (state.replyingToComment?.isLineComment == true
            ? state.replyingToComment?.localId
            : null);
    if (effectiveLineId == null) return;

    try {
      final newComment = await _forumRepository.postLineComment(
        lineId: effectiveLineId,
        text: text,
        commentType: commentType,
        parentCommentId: effectiveParentId,
      );

      final updatedLineComments = List<ForumLineComment>.from(
        state.lineComments,
      )..add(newComment);

      // Also update line comment count locally in the answerLines list
      final updatedLines = state.answerLines.map((line) {
        if (line.lineId == effectiveLineId) {
          return line.copyWith(commentCount: line.commentCount + 1);
        }
        return line;
      }).toList();

      emit(
        state.copyWithNullableLineId(
          lineComments: updatedLineComments,
          answerLines: updatedLines,
          clearReplyingTo: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: 'Failed to post comment: ${e.toString()}'));
    }
  }

  /// Update a line comment
  Future<void> updateLineComment({
    required String localId,
    required String serverId,
    required String text,
    String? commentType,
  }) async {
    try {
      await _forumRepository.updateLineComment(
        localId: localId,
        serverId: serverId,
        text: text,
        commentType: commentType,
      );

      final updatedLineComments = state.lineComments.map((c) {
        if (c.localId == localId) {
          return c.copyWith(
            text: text,
            commentType: commentType != null
                ? _parseCommentType(commentType)
                : c.commentType,
          );
        }
        return c;
      }).toList();

      emit(state.copyWith(lineComments: updatedLineComments));
    } catch (e) {
      emit(
        state.copyWith(error: 'Failed to update line comment: ${e.toString()}'),
      );
    }
  }

  /// Delete a line comment
  Future<void> deleteLineComment(String localId) async {
    try {
      await _forumRepository.deleteLineComment(localId);

      final updatedLineComments = state.lineComments
          .where((c) => c.localId != localId)
          .toList();

      // Also update line comment count locally in the answerLines list
      final selectedLineId = state.selectedLineId;
      final updatedLines = state.answerLines.map((line) {
        if (line.lineId == selectedLineId) {
          return line.copyWith(commentCount: line.commentCount - 1);
        }
        return line;
      }).toList();

      emit(
        state.copyWith(
          lineComments: updatedLineComments,
          answerLines: updatedLines,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(error: 'Failed to delete line comment: ${e.toString()}'),
      );
    }
  }

  CommentType _parseCommentType(String type) {
    switch (type.toLowerCase()) {
      case 'clinical':
        return CommentType.clinical;
      case 'evidence':
        return CommentType.evidence;
      case 'experience':
        return CommentType.experience;
      case 'concern':
        return CommentType.concern;
      default:
        return CommentType.general;
    }
  }
  // End of comments section

  /// Set the comment we are currently replying to
  void setReplyingTo(ForumReplyTarget target) {
    emit(state.copyWith(replyingToComment: target));
  }

  /// Clear the reply state
  void clearReplyingTo() {
    emit(state.copyWithNullableLineId(clearReplyingTo: true));
  }

  /// Clear error state
  void clearError() {
    emit(state.clearError());
  }

  /// Helper: Parse post content into selectable lines for discussion
  List<ForumAnswerLine> _parsePostContentToLines(ForumPost post) {
    final content = post.content;
    final postId = post.id.isEmpty ? post.localId : post.id;

    // Relaxed split: lookbehind for .!? + space
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
        lineNumber: index, // 0-indexed as per backend change
        text: text,
        discussionTitle: text.length > 30
            ? '${text.substring(0, 30)}...'
            : text,
        commentCount: 0,
      );
    }).toList();
  }

  @override
  Future<void> close() {
    _syncTimer?.cancel();
    return super.close();
  }
}
