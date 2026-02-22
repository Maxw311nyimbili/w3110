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
      final localPost = await _database.getPostByServerId(serverPost.id) ??
                        await _database.getPostByLocalId(serverPost.id); // Check if ID matches localId

      if (localPost == null) {
        // New post from server
        await _database.insertPost(ForumPostsCompanion.insert(
          serverId: Value(serverPost.id),
          localId: serverPost.localId,
          authorId: serverPost.authorId,
          authorName: serverPost.authorName,
          title: serverPost.title,
          content: serverPost.content,
          createdAt: serverPost.createdAt,
          updatedAt: Value(serverPost.updatedAt),
          commentCount: Value(serverPost.commentCount),
          likeCount: Value(serverPost.likeCount),
          isLiked: Value(serverPost.isLiked),
          isDeleted: Value(serverPost.isDeleted),
          version: Value(serverPost.version),
          syncStatus: const Value('synced'),
        ));
      } else {
        // Conflict resolution: Server wins
        await _database.updatePost(ForumPostsCompanion(
          serverId: Value(serverPost.id),
          localId: Value(localPost.localId),
          authorId: Value(serverPost.authorId),
          authorName: Value(serverPost.authorName),
          title: Value(serverPost.title),
          content: Value(serverPost.content),
          createdAt: Value(serverPost.createdAt),
          updatedAt: Value(serverPost.updatedAt),
          commentCount: Value(serverPost.commentCount),
          likeCount: Value(serverPost.likeCount),
          isLiked: Value(serverPost.isLiked),
          isDeleted: Value(serverPost.isDeleted),
          version: Value(serverPost.version),
          syncStatus: const Value('synced'),
        ));
      }
    }
  }

  /// Merge server comments for a post
  Future<void> mergeServerComments(List<ForumComment> serverComments) async {
    for (final serverComment in serverComments) {
      final localComment = await _database.getCommentByServerId(serverComment.id);

      if (localComment == null) {
        await _database.insertComment(ForumCommentsCompanion.insert(
          serverId: Value(serverComment.id),
          localId: serverComment.localId,
          postId: serverComment.postId,
          authorId: serverComment.authorId,
          authorName: serverComment.authorName,
          content: serverComment.content,
          parentCommentId: Value(serverComment.parentCommentId),
          isDeleted: Value(serverComment.isDeleted),
          createdAt: serverComment.createdAt,
          updatedAt: Value(serverComment.updatedAt),
          syncStatus: const Value('synced'),
        ));
      } else {
        // Conflict resolution: Server wins
        await _database.insertComment(ForumCommentsCompanion(
          serverId: Value(serverComment.id),
          localId: Value(localComment.localId),
          postId: Value(serverComment.postId),
          authorId: Value(serverComment.authorId),
          authorName: Value(serverComment.authorName),
          content: Value(serverComment.content),
          parentCommentId: Value(serverComment.parentCommentId),
          isDeleted: Value(serverComment.isDeleted),
          createdAt: Value(serverComment.createdAt),
          updatedAt: Value(serverComment.updatedAt),
          syncStatus: const Value('synced'),
        ));
      }
    }
  }

  /// Helper to resolve a single conflict (post or comment)
  /// Can be expanded for more complex strategies (merge, prompt user)
  T resolveConflict<T>(T local, T server) {
    return server; // Server wins strategy
  }
}