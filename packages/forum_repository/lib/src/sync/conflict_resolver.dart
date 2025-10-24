// packages/forum_repository/lib/src/sync/conflict_resolver.dart

import 'package:drift/drift.dart';
import '../database/forum_database.dart';
import '../models/forum_post.dart';
import '../models/forum_comment.dart';

/// Conflict resolver - handles conflicts when merging server and local data
/// Strategy: Last-Write-Wins (server always wins)
class ConflictResolver {
  ConflictResolver({
    required ForumDatabase database,
  }) : _database = database;

  final ForumDatabase _database;

  /// Merge server posts with local posts
  /// Strategy: Last-Write-Wins - server data takes precedence
  Future<void> mergeServerPosts(List<ForumPost> serverPosts) async {
    for (final serverPost in serverPosts) {
      // Check if post exists locally
      final localPost = await _database.getPostByServerId(serverPost.id);

      if (localPost == null) {
        // New post from server - insert it
        await _database.insertPost(ForumPostsCompanion.insert(
          localId: serverPost.id, // Use server ID as local ID
          serverId: Value(serverPost.id),
          authorId: serverPost.authorId,
          authorName: serverPost.authorName,
          title: serverPost.title,
          content: serverPost.content,
          createdAt: serverPost.createdAt,
          updatedAt: Value(serverPost.updatedAt),
          commentCount: Value(serverPost.commentCount),
          likeCount: Value(serverPost.likeCount),
          syncStatus: const Value('synced'),
        ));
      } else {
        // Post exists - check for conflicts
        final localUpdatedAt = localPost.updatedAt ?? localPost.createdAt;
        final serverUpdatedAt = serverPost.updatedAt ?? serverPost.createdAt;

        // Server is newer - update local
        if (serverUpdatedAt.isAfter(localUpdatedAt)) {
          await _database.updatePost(ForumPostsCompanion(
            localId: Value(localPost.localId),
            serverId: Value(serverPost.id),
            authorId: Value(serverPost.authorId),
            authorName: Value(serverPost.authorName),
            title: Value(serverPost.title),
            content: Value(serverPost.content),
            createdAt: Value(serverPost.createdAt),
            updatedAt: Value(serverPost.updatedAt),
            commentCount: Value(serverPost.commentCount),
            likeCount: Value(serverPost.likeCount),
            syncStatus: const Value('synced'),
          ));
        }
        // If local is newer and pending sync, keep local version
        // (it will be synced to server later)
      }
    }
  }

  /// Merge server comments with local comments
  Future<void> mergeServerComments(List<ForumComment> serverComments) async {
    for (final serverComment in serverComments) {
      // Similar logic to posts - last-write-wins
      // Check if exists locally by server ID
      final localComments = await _database.getCommentsForPost(serverComment.postId);
      final localComment = localComments.cast<ForumCommentData?>().firstWhere(
            (c) => c?.serverId == serverComment.id,
        orElse: () => null,
      );

      if (localComment == null) {
        // New comment from server - insert it
        await _database.insertComment(ForumCommentsCompanion.insert(
          localId: serverComment.id, // Use server ID as local ID
          serverId: Value(serverComment.id),
          postId: serverComment.postId,
          authorId: serverComment.authorId,
          authorName: serverComment.authorName,
          content: serverComment.content,
          createdAt: serverComment.createdAt,
          updatedAt: Value(serverComment.updatedAt),
          syncStatus: const Value('synced'),
        ));
      } else {
        // Comment exists - apply last-write-wins
        final localUpdatedAt = localComment.updatedAt ?? localComment.createdAt;
        final serverUpdatedAt = serverComment.updatedAt ?? serverComment.createdAt;

        if (serverUpdatedAt.isAfter(localUpdatedAt)) {
          await _database.updateCommentSyncStatus(
            localId: localComment.localId,
            syncStatus: 'synced',
            serverId: serverComment.id,
          );
        }
      }
    }
  }

  /// Resolve conflict between local and server data
  /// This is called when both have been modified
  /// Strategy: Server always wins (last-write-wins)
  ConflictResolution resolveConflict({
    required DateTime localTimestamp,
    required DateTime serverTimestamp,
    bool localIsPending = false,
  }) {
    // If local is pending sync, keep local (it will be synced soon)
    if (localIsPending) {
      return ConflictResolution.keepLocal;
    }

    // Otherwise, server wins
    return serverTimestamp.isAfter(localTimestamp)
        ? ConflictResolution.keepServer
        : ConflictResolution.keepLocal;
  }
}

/// Conflict resolution strategy
enum ConflictResolution {
  keepLocal,
  keepServer,
  merge, // Not implemented in v1
}