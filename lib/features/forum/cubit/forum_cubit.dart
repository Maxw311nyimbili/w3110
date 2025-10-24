// lib/features/forum/cubit/forum_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forum_repository/forum_repository.dart' as repo;
import 'package:uuid/uuid.dart';
import 'forum_state.dart';

/// Manages forum posts, comments, and offline sync
class ForumCubit extends Cubit<ForumState> {
  ForumCubit({
    required repo.ForumRepository forumRepository,
  })  : _forumRepository = forumRepository,
        _uuid = const Uuid(),
        super(const ForumState());

  final repo.ForumRepository _forumRepository;
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
        posts: posts.map(_mapToStatePost).toList(),
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
        posts: posts.map(_mapToStatePost).toList(),
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
        comments: comments.map(_mapToStateComment).toList(),
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
    ));
  }

  /// Create a new post (saved locally immediately, synced in background)
  Future<void> createPost({
    required String title,
    required String content,
    required String authorId,
    required String authorName,
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
      );

      // Save to local database
      await _forumRepository.createLocalPost(
        localId: localId,
        title: title,
        content: content,
        authorId: authorId,
        authorName: authorName,
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
  /// Uses exponential backoff for failed syncs
  Future<void> syncWithBackend() async {
    if (state.isSyncing) return; // Prevent concurrent syncs

    try {
      emit(state.copyWith(isSyncing: true));

      // TODO: Uncomment when backend ready
      /*
      // Step 1: Check connectivity
      final isOnline = await _forumRepository.checkConnectivity();
      if (!isOnline) {
        emit(state.copyWith(isSyncing: false));
        return;
      }

      // Step 2: Upload pending changes from sync queue
      await _forumRepository.processSyncQueue();

      // Step 3: Download new/updated posts from server
      final serverPosts = await _forumRepository.fetchPostsFromServer(
        since: state.lastSyncTime,
      );

      // Step 4: Merge server data with local data (conflict resolution)
      await _forumRepository.mergeServerData(serverPosts);

      // Step 5: Reload from local DB (now contains merged data)
      final updatedPosts = await _forumRepository.getLocalPosts();
      final hasPendingSync = await _forumRepository.hasPendingSyncItems();

      emit(state.copyWith(
        posts: updatedPosts.map(_mapToStatePost).toList(),
        isSyncing: false,
        hasPendingSync: hasPendingSync,
        lastSyncTime: DateTime.now(),
      ));
      */

      // TEMPORARY: Mock sync for development
      await Future.delayed(const Duration(seconds: 2));

      // Simulate syncing pending posts
      final updatedPosts = state.posts.map((post) {
        if (post.isPendingSync) {
          return post.copyWith(
            id: _uuid.v4(), // Mock server ID
            syncStatus: SyncStatus.synced,
          );
        }
        return post;
      }).toList();

      emit(state.copyWith(
        posts: updatedPosts,
        isSyncing: false,
        hasPendingSync: false,
        lastSyncTime: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(
        isSyncing: false,
        error: 'Sync failed: ${e.toString()}',
      ));

      // Retry with exponential backoff (handled by sync manager in repository)
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
      // TODO: Implement comment sync with backend
      // Similar to post sync but for comments of a specific post
    } catch (e) {
      // Silent fail - comments will sync on next attempt
    }
  }

  /// Clear error state
  void clearError() {
    emit(state.clearError());
  }

  /// Helper to map repository post to state post
  ForumPost _mapToStatePost(repo.ForumPost repoPost) {
    return ForumPost(
      id: repoPost.id,
      localId: repoPost.localId,
      authorId: repoPost.authorId,
      authorName: repoPost.authorName,
      title: repoPost.title,
      content: repoPost.content,
      createdAt: repoPost.createdAt,
      updatedAt: repoPost.updatedAt,
      commentCount: repoPost.commentCount,
      likeCount: repoPost.likeCount,
      syncStatus: _mapSyncStatus(repoPost.syncStatus),
    );
  }

  /// Helper to map repository comment to state comment
  ForumComment _mapToStateComment(repo.ForumComment repoComment) {
    return ForumComment(
      id: repoComment.id,
      localId: repoComment.localId,
      postId: repoComment.postId,
      authorId: repoComment.authorId,
      authorName: repoComment.authorName,
      content: repoComment.content,
      createdAt: repoComment.createdAt,
      updatedAt: repoComment.updatedAt,
      syncStatus: _mapSyncStatus(repoComment.syncStatus),
    );
  }

  SyncStatus _mapSyncStatus(String syncStatus) {
    switch (syncStatus) {
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
  Future<void> close() {
    _syncTimer?.cancel();
    return super.close();
  }
}