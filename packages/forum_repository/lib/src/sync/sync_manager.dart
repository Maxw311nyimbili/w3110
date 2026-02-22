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
      return;
    }

    for (final item in allItems) {
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
          case 'line_comment':
            await _syncLineComment(item);
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
        // Get parent post to find server ID
        final post = await _database.getPostByLocalId(comment.postId) ?? 
                    await _database.getPostByServerId(comment.postId);
                    
        if (post == null || post.serverId.isEmpty) {
          throw SyncException('Parent post not synced yet: ${comment.postId}');
        }

        final response = await _apiClient.post(
          '/api/v1/forum/posts/${post.serverId}/comments',
          data: {
            'content': comment.content,
            'author_id': comment.authorId,
            'parent_comment_id': comment.parentCommentId,
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
        await _apiClient.delete('/api/v1/forum/comments/${comment.serverId}');
        await _database.deleteComment(comment.localId);
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
          'parent_comment_id': comment.parentCommentId,
        },
      );

      final serverId = response.data['comment_id'].toString();
      await _database.updateLineCommentSyncStatus(
        localId: comment.localId,
        syncStatus: 'synced',
        serverId: serverId,
      );
    } else if (item.action == 'delete') {
      await _apiClient.delete('/api/v1/forum/comments/${comment.serverId}');
      await _database.deleteLineComment(comment.localId);
    } else {
      throw SyncException('Action ${item.action} not supported for line comments');
    }
  }

  /// Fetch new/updated posts from server
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