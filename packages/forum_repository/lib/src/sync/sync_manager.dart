// packages/forum_repository/lib/src/sync/sync_manager.dart

import 'package:api_client/api_client.dart';
import 'package:drift/drift.dart';
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
    // Get pending items AND failed items that are ready for retry
    final pendingItems = await _database.getPendingSyncItems();
    final failedItems = await _database.getFailedSyncItems();
    
    // Filter failed items where nextRetryAt is in the past or null
    final now = DateTime.now();
    final retryableFailedItems = failedItems.where((item) => 
      item.nextRetryAt == null || item.nextRetryAt!.isBefore(now)
    ).toList();

    final allItems = [...pendingItems, ...retryableFailedItems];
    
    if (allItems.isEmpty) {
      print('DEBUG: SyncManager.processSyncQueue - nothing to sync');
      return;
    }

    print('DEBUG: SyncManager.processSyncQueue - found ${allItems.length} total items to process');

    for (final item in allItems) {
      try {
        print('DEBUG: SyncManager.processSyncQueue - processing item: ${item.entityType} ${item.action} for ${item.entityId}');
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
          case 'line_comment':
            await _syncLineComment(item);
            break;
          default:
            throw SyncException('Unknown entity type: ${item.entityType}');
        }

        // Remove from queue on success
        await _database.removeSyncQueueItem(item.id);
        print('DEBUG: SyncManager.processSyncQueue - successfully synced item: ${item.id}');
      } catch (e) {
        print('DEBUG: SyncManager.processSyncQueue - ERROR syncing item: ${item.id} - $e');
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
        final postModel = ForumPost.fromDatabase(post);
        final response = await _apiClient.post(
          '/api/v1/forum/posts',
          data: {
            'title': postModel.title,
            'content': postModel.content,
            'client_id': postModel.localId,
            'sources': postModel.sources.map((e) => e.toJson()).toList(),
            'original_answer_id': postModel.originalAnswerId,
          },
        );

        // Update local post with server ID
        final serverId = response.data['id'].toString();
        await _database.updatePostSyncStatus(
          localId: post.localId,
          syncStatus: 'synced',
          serverId: serverId,
        );
        break;

      case 'update':
      // Backend endpoint: PUT /forum/posts/{id}
        await _apiClient.put(
          '/api/v1/forum/posts/${post.serverId}',
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
        await _apiClient.delete('/api/v1/forum/posts/${post.serverId}');
        await _database.deletePost(post.localId);
        break;

      default:
        throw SyncException('Unknown action: ${item.action}');
    }
  }

  /// Sync a comment to backend
  Future<void> _syncComment(SyncQueueData item) async {
    final comment = await _database.getCommentByLocalId(item.entityId);
    if (comment == null) {
      throw SyncException('Comment not found: ${item.entityId}');
    }

    switch (item.action) {
      case 'create':
      // Backend endpoint: POST /forum/posts/{post_id}/comments
      // Request: { "content": "...", "author_id": "..." }
      // Response: { "id": "server-uuid", ... }

      // Get parent post to find server ID
        // The postId in the comment might be a localId or a serverId
        final post = await _database.getPostByLocalId(comment.postId) ?? 
                    await _database.getPostByServerId(comment.postId);
                    
        if (post == null || post.serverId.isEmpty) {
          throw SyncException('Parent post not synced yet or not found: ${comment.postId}');
        }

        final response = await _apiClient.post(
          '/api/v1/forum/posts/${post.serverId}/comments',
          data: {
            'content': comment.content,
            'author_id': comment.authorId,
          },
        );

        // Update local comment with server ID
        final serverId = response.data['id'].toString();
        await _database.updateCommentSyncStatus(
          localId: comment.localId,
          syncStatus: 'synced',
          serverId: serverId,
        );
        break;

      case 'update':
      // Backend endpoint: PUT /forum/comments/{id}
        await _apiClient.put(
          '/api/v1/forum/comments/${comment.serverId}',
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
        await _apiClient.delete('/api/v1/forum/comments/${comment.serverId}');
        // TODO: Implement delete in database
        break;

      default:
        throw SyncException('Unknown action: ${item.action}');
    }
  }

  /// Sync a line-level comment to backend
  Future<void> _syncLineComment(SyncQueueData item) async {
    final comment = await _database.getLineCommentByLocalId(item.entityId);
    if (comment == null) {
      throw SyncException('Line comment not found: ${item.entityId}');
    }

    if (item.action == 'create') {
      final response = await _apiClient.post(
        '/api/v1/forum/lines/${comment.lineId}/comments',
        data: {
          'text': comment.content,
          'comment_type': comment.commentType,
        },
      );

      final serverId = response.data['comment_id'].toString();
      await _database.updateLineCommentSyncStatus(
        localId: comment.localId,
        syncStatus: 'synced',
        serverId: serverId,
      );
    } else {
      throw SyncException('Action ${item.action} not supported for line comments');
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
        '/api/v1/forum/posts',
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
      final response = await _apiClient.get('/api/v1/forum/posts/$postId/comments');

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