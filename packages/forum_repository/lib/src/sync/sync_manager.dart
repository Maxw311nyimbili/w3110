// packages/forum_repository/lib/src/sync/sync_manager.dart

import 'package:api_client/api_client.dart';
import '../database/forum_database.dart';
import '../models/forum_post.dart';
import '../models/forum_comment.dart';

/// Sync manager - handles background sync with backend
class SyncManager {
  SyncManager({
    required ApiClient apiClient,
    required ForumDatabase database,
  })  : _apiClient = apiClient,
        _database = database;

  final ApiClient _apiClient;
  final ForumDatabase _database;

  /// Process sync queue - upload pending changes to backend
  /// Uses exponential backoff for failed items
  Future<void> processSyncQueue() async {
    final pendingItems = await _database.getPendingSyncItems();

    for (final item in pendingItems) {
      try {
        // Mark as syncing
        await _database.updateSyncQueueStatus(
          id: item.id,
          status: 'syncing',
        );

        // Process based on entity type and action
        switch (item.entityType) {
          case 'post':
            await _syncPost(item);
            break;
          case 'comment':
            await _syncComment(item);
            break;
          default:
            throw SyncException('Unknown entity type: ${item.entityType}');
        }

        // Remove from queue on success
        await _database.removeSyncQueueItem(item.id);
      } catch (e) {
        // Calculate next retry time with exponential backoff
        final backoffSeconds = _calculateBackoff(item.retryCount);
        final nextRetryAt = DateTime.now().add(Duration(seconds: backoffSeconds));

        // Update sync queue with error
        await _database.updateSyncQueueStatus(
          id: item.id,
          status: 'failed',
          error: e.toString(),
          nextRetryAt: nextRetryAt,
        );
      }
    }
  }

  /// Sync a post to backend
  Future<void> _syncPost(SyncQueueData item) async {
    final post = await _database.getPostByLocalId(item.entityId);
    if (post == null) {
      throw SyncException('Post not found: ${item.entityId}');
    }

    switch (item.action) {
      case 'create':
      // Backend endpoint: POST /forum/posts
      // Request: { "title": "...", "content": "...", "author_id": "..." }
      // Response: { "id": "server-uuid", ... }
        final response = await _apiClient.post(
          '/forum/posts',
          data: {
            'title': post.title,
            'content': post.content,
            'author_id': post.authorId,
          },
        );

        // Update local post with server ID
        final serverId = response.data['id'] as String;
        await _database.updatePostSyncStatus(
          localId: post.localId,
          syncStatus: 'synced',
          serverId: serverId,
        );
        break;

      case 'update':
      // Backend endpoint: PUT /forum/posts/{id}
        await _apiClient.put(
          '/forum/posts/${post.serverId}',
          data: {
            'title': post.title,
            'content': post.content,
          },
        );

        await _database.updatePostSyncStatus(
          localId: post.localId,
          syncStatus: 'synced',
        );
        break;

      case 'delete':
      // Backend endpoint: DELETE /forum/posts/{id}
        await _apiClient.delete('/forum/posts/${post.serverId}');
        await _database.deletePost(post.localId);
        break;

      default:
        throw SyncException('Unknown action: ${item.action}');
    }
  }

  /// Sync a comment to backend
  Future<void> _syncComment(SyncQueueData item) async {
    final comments = await _database.getCommentsForPost(''); // TODO: Get by localId
    final comment = comments.firstWhere(
          (c) => c.localId == item.entityId,
      orElse: () => throw SyncException('Comment not found: ${item.entityId}'),
    );

    switch (item.action) {
      case 'create':
      // Backend endpoint: POST /forum/posts/{post_id}/comments
      // Request: { "content": "...", "author_id": "..." }
      // Response: { "id": "server-uuid", ... }

      // Get parent post to find server ID
        final post = await _database.getPostByLocalId(comment.postId);
        if (post == null || post.serverId.isEmpty) {
          throw SyncException('Parent post not synced yet');
        }

        final response = await _apiClient.post(
          '/forum/posts/${post.serverId}/comments',
          data: {
            'content': comment.content,
            'author_id': comment.authorId,
          },
        );

        // Update local comment with server ID
        final serverId = response.data['id'] as String;
        await _database.updateCommentSyncStatus(
          localId: comment.localId,
          syncStatus: 'synced',
          serverId: serverId,
        );
        break;

      case 'update':
      // Backend endpoint: PUT /forum/comments/{id}
        await _apiClient.put(
          '/forum/comments/${comment.serverId}',
          data: {
            'content': comment.content,
          },
        );

        await _database.updateCommentSyncStatus(
          localId: comment.localId,
          syncStatus: 'synced',
        );
        break;

      case 'delete':
      // Backend endpoint: DELETE /forum/comments/{id}
        await _apiClient.delete('/forum/comments/${comment.serverId}');
        // TODO: Implement delete in database
        break;

      default:
        throw SyncException('Unknown action: ${item.action}');
    }
  }

  /// Fetch new/updated posts from server
  /// Backend endpoint: GET /forum/posts?since={timestamp}
  /// Response: { "posts": [...] }
  Future<List<ForumPost>> fetchPostsFromServer({DateTime? since}) async {
    try {
      final queryParams = since != null
          ? {'since': since.toIso8601String()}
          : <String, dynamic>{};

      final response = await _apiClient.get(
        '/forum/posts',
        queryParameters: queryParams,
      );

      final List<dynamic> postsJson = response.data['posts'] as List<dynamic>;

      return postsJson
          .map((json) => ForumPost.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw SyncException('Failed to fetch posts: ${e.toString()}');
    }
  }


  /// Fetch comments for a specific post from server
  /// Backend endpoint: GET /forum/posts/{id}/comments
  /// Response: { "comments": [...] }
  Future<List<ForumComment>> fetchCommentsFromServer(String postId) async {
    try {
      final response = await _apiClient.get('/forum/posts/$postId/comments');

      final List<dynamic> commentsJson =
      response.data['comments'] as List<dynamic>;

      return commentsJson
          .map((json) => ForumComment.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw SyncException('Failed to fetch comments: ${e.toString()}');
    }
  }


  /// Calculate exponential backoff delay
  /// Returns delay in seconds: 30s, 60s, 120s, 240s, ... up to 1 hour
  int _calculateBackoff(int retryCount) {
    const baseDelay = 30; // 30 seconds
    const maxDelay = 3600; // 1 hour

    final delay = baseDelay * (1 << retryCount); // 2^retryCount
    return delay > maxDelay ? maxDelay : delay;
  }
}

/// Custom exception for sync errors
class SyncException implements Exception {
  SyncException(this.message);
  final String message;

  @override
  String toString() => 'SyncException: $message';
}