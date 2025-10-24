// packages/forum_repository/lib/src/forum_repository.dart

import 'package:api_client/api_client.dart';
import 'database/forum_database.dart';
import 'models/forum_post.dart';
import 'models/forum_comment.dart';
import 'sync/sync_manager.dart';
import 'sync/conflict_resolver.dart';
import 'package:drift/drift.dart';

/// Forum repository - handles forum posts, comments, and offline sync
class ForumRepository {
  ForumRepository({
    required ApiClient apiClient,
    required ForumDatabase database,
  })  : _apiClient = apiClient,
        _database = database,
        _syncManager = SyncManager(apiClient: apiClient, database: database),
        _conflictResolver = ConflictResolver(database: database);

  final ApiClient _apiClient;
  final ForumDatabase _database;
  final SyncManager _syncManager;
  final ConflictResolver _conflictResolver;

  // ============================================================
  // LOCAL OPERATIONS (always available offline)
  // ============================================================

  /// Get all posts from local database
  Future<List<ForumPost>> getLocalPosts() async {
    final posts = await _database.getAllPosts();
    return posts.map((data) => ForumPost.fromDatabase(data)).toList();
  }

  /// Get comments for a post from local database
  Future<List<ForumComment>> getLocalComments(String postId) async {
    final comments = await _database.getCommentsForPost(postId);
    return comments.map((data) => ForumComment.fromDatabase(data)).toList();
  }

  /// Create post locally (instant feedback)
  Future<void> createLocalPost({
    required String localId,
    required String title,
    required String content,
    required String authorId,
    required String authorName,
  }) async {
    await _database.insertPost(ForumPostsCompanion.insert(
      localId: localId,
      authorId: authorId,
      authorName: authorName,
      title: title,
      content: content,
      createdAt: DateTime.now(),
      syncStatus: const Value('pending'),
    ));
  }

  /// Create comment locally (instant feedback)
  Future<void> createLocalComment({
    required String localId,
    required String postId,
    required String content,
    required String authorId,
    required String authorName,
  }) async {
    await _database.insertComment(ForumCommentsCompanion.insert(
      localId: localId,
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      content: content,
      createdAt: DateTime.now(),
      syncStatus: const Value('pending'),
    ));
  }

  // ============================================================
  // SYNC OPERATIONS (requires network)
  // ============================================================

  /// Add item to sync queue
  Future<void> addToSyncQueue({
    required String entityType,
    required String entityId,
    required String action,
  }) async {
    await _database.addToSyncQueue(
      entityType: entityType,
      entityId: entityId,
      action: action,
    );
  }

  /// Process sync queue (upload pending changes)
  Future<void> processSyncQueue() async {
    await _syncManager.processSyncQueue();
  }

  /// Fetch posts from server and merge with local
  Future<void> fetchPostsFromServer({DateTime? since}) async {
    final serverPosts = await _syncManager.fetchPostsFromServer(since: since);
    await _conflictResolver.mergeServerPosts(serverPosts);
  }

  /// Check if there are pending sync items
  Future<bool> hasPendingSyncItems() async {
    return await _database.hasPendingSyncItems();
  }

  /// Merge server data with local data
  Future<void> mergeServerData(List<ForumPost> serverPosts) async {
    await _conflictResolver.mergeServerPosts(serverPosts);
  }

  /// Check connectivity (placeholder - implement with connectivity_plus)
  Future<bool> checkConnectivity() async {
    // TODO: Implement with connectivity_plus package
    /*
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
    */
    return true; // Temporary - assume always online
  }
}

/// Custom exception for forum repository errors
class ForumException implements Exception {
  ForumException(this.message);
  final String message;

  @override
  String toString() => 'ForumException: $message';
}