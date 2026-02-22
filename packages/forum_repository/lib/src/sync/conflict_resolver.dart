// packages/forum_repository/lib/src/sync/conflict_resolver.dart

import 'package:drift/drift.dart';
import '../database/forum_database.dart';
import '../models/forum_comment.dart';
import '../models/forum_post.dart';

/// Conflict resolver - merges server and local data
class ConflictResolver {
  ConflictResolver({
    required ForumDatabase database,
  }) : _database = database;

  final ForumDatabase _database;

  /// Merge server posts into local database
  /// strategy: Last-Write-Wins (Server always wins for now)
  Future<void> mergeServerPosts(List<ForumPost> serverPosts) async {
    for (final serverPost in serverPosts) {
      // 1. Precise match by Server ID
      final localByServerId = await _database.getPostByServerId(serverPost.id);

      if (localByServerId != null) {
        // MATCH BY SERVER ID
        if (localByServerId.localId != serverPost.localId) {
          // HEAL: UUID MISMATH - The local UUID has drifted from the server's authoritative one.
          print(
            'DEBUG: Healing Post ID Drift: ${localByServerId.localId} -> ${serverPost.localId}',
          );
          await _database.deletePost(localByServerId.localId);
          await _insertServerPost(serverPost);
        } else {
          // UPDATE: Identical UUIDs, just update content/metadata
          await _updateServerPost(serverPost, localByServerId.localId);
        }
      } else {
        // 2. Fallback: Check if we have a pending local post that matches by UUID
        final localByUuid = await _database.getPostByLocalId(
          serverPost.localId,
        );
        if (localByUuid != null) {
          // Sync success! Local UUID now has a server ID.
          await _updateServerPost(serverPost, serverPost.localId);
        } else {
          // NEW Post from server
          await _insertServerPost(serverPost);
        }
      }
    }
  }

  Future<void> _insertServerPost(ForumPost post) async {
    await _database.insertPost(
      ForumPostsCompanion.insert(
        serverId: Value(post.id),
        localId: post.localId,
        authorId: post.authorId,
        authorName: post.authorName,
        title: post.title,
        content: post.content,
        createdAt: post.createdAt,
        updatedAt: Value(post.updatedAt),
        commentCount: Value(post.commentCount),
        likeCount: Value(post.likeCount),
        isLiked: Value(post.isLiked),
        isDeleted: Value(post.isDeleted),
        version: Value(post.version),
        syncStatus: const Value('synced'),
      ),
    );
  }

  Future<void> _updateServerPost(ForumPost post, String localId) async {
    await _database.updatePost(
      ForumPostsCompanion(
        serverId: Value(post.id),
        localId: Value(localId),
        authorId: Value(post.authorId),
        authorName: Value(post.authorName),
        title: Value(post.title),
        content: Value(post.content),
        createdAt: Value(post.createdAt),
        updatedAt: Value(post.updatedAt),
        commentCount: Value(post.commentCount),
        likeCount: Value(post.likeCount),
        isLiked: Value(post.isLiked),
        isDeleted: Value(post.isDeleted),
        version: Value(post.version),
        syncStatus: const Value('synced'),
      ),
    );
  }

  /// Merge server comments for a post
  Future<void> mergeServerComments(List<ForumComment> serverComments) async {
    for (final serverComment in serverComments) {
      // 1. Precise match by Server ID
      final localByServerId = await _database.getCommentByServerId(
        serverComment.id,
      );

      if (localByServerId != null) {
        // MATCH BY SERVER ID
        if (localByServerId.localId != serverComment.localId) {
          // HEAL: UUID MISMATCH - The server updated its client_id (likely via backfill)
          print(
            'DEBUG: Healing Comment ID Drift: ${localByServerId.localId} -> ${serverComment.localId}',
          );

          // 1. Update all children to point to the new authoritative parent UUID
          await _database.updateChildParentIds(
            oldParentLocalId: localByServerId.localId,
            newParentLocalId: serverComment.localId,
          );

          // 2. Clear out the old parent record
          await _database.deleteComment(localByServerId.localId);

          // 3. Insert the "fixed" parent record
          await _insertServerComment(serverComment);
        } else {
          // UPDATE: Authoritative match
          await _updateServerComment(serverComment, localByServerId.localId);
        }
      } else {
        // 2. Fallback: Check if we have a pending local comment that matches by UUID
        final localByUuid = await _database.getCommentByLocalId(
          serverComment.localId,
        );
        if (localByUuid != null) {
          // Sync success
          await _updateServerComment(serverComment, serverComment.localId);
        } else {
          // NEW Comment from server
          await _insertServerComment(serverComment);
        }
      }
    }
  }

  Future<void> _insertServerComment(ForumComment comment) async {
    await _database.insertComment(
      ForumCommentsCompanion.insert(
        serverId: Value(comment.id),
        localId: comment.localId,
        postId: comment.postId,
        authorId: comment.authorId,
        authorName: comment.authorName,
        content: comment.content,
        parentCommentId: Value(comment.parentCommentId),
        isDeleted: Value(comment.isDeleted),
        createdAt: comment.createdAt,
        updatedAt: Value(comment.updatedAt),
        syncStatus: const Value('synced'),
      ),
    );
  }

  Future<void> _updateServerComment(
    ForumComment comment,
    String localId,
  ) async {
    // Note: Drift update requires identifying by primary key (localId)
    // We are using insert(OnConflictUpdate) style via raw updates if needed,
    // but here we know the localId exists and is correct.

    // We update the row to match the server state.
    // We don't use 'insertComment' for updates because it lacks the 'update' logic.
    // Instead we use updateCommentSyncStatus or similar if available, or just a direct update.

    // For now, let's use the update method on the database
    await _database.updateCommentSyncStatus(
      localId: localId,
      syncStatus: 'synced',
      serverId: comment.id,
    );

    await _database.updateCommentContent(
      localId: localId,
      content: comment.content,
    );
  }

  /// Helper to resolve a single conflict (post or comment)
  /// Can be expanded for more complex strategies (merge, prompt user)
  T resolveConflict<T>(T local, T server) {
    return server; // Server wins strategy
  }
}
