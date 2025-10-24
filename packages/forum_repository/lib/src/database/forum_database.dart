// packages/forum_repository/lib/src/database/forum_database.dart

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/forum_posts_table.dart';
import 'tables/forum_comments_table.dart';
import 'tables/sync_queue_table.dart';

part 'forum_database.g.dart';

/// Forum database - offline-first local storage with Drift
@DriftDatabase(tables: [ForumPosts, ForumComments, SyncQueue])
class ForumDatabase extends _$ForumDatabase {
  ForumDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ============================================================
  // POSTS QUERIES
  // ============================================================

  /// Get all posts ordered by creation date (newest first)
  Future<List<ForumPostData>> getAllPosts() async {
    return (select(forumPosts)
      ..orderBy([
            (post) => OrderingTerm(
          expression: post.createdAt,
          mode: OrderingMode.desc,
        ),
      ]))
        .get();
  }

  /// Get a single post by local ID
  Future<ForumPostData?> getPostByLocalId(String localId) async {
    return (select(forumPosts)..where((post) => post.localId.equals(localId)))
        .getSingleOrNull();
  }

  /// Get a single post by server ID
  Future<ForumPostData?> getPostByServerId(String serverId) async {
    return (select(forumPosts)..where((post) => post.serverId.equals(serverId)))
        .getSingleOrNull();
  }

  /// Insert a new post
  Future<int> insertPost(ForumPostsCompanion post) async {
    return into(forumPosts).insert(post);
  }

  /// Update a post
  Future<bool> updatePost(ForumPostsCompanion post) async {
    return update(forumPosts).replace(post);
  }

  /// Delete a post
  Future<int> deletePost(String localId) async {
    return (delete(forumPosts)..where((post) => post.localId.equals(localId)))
        .go();
  }

  /// Update post sync status
  Future<int> updatePostSyncStatus({
    required String localId,
    required String syncStatus,
    String? serverId,
  }) async {
    return (update(forumPosts)..where((post) => post.localId.equals(localId)))
        .write(ForumPostsCompanion(
      syncStatus: Value(syncStatus),
      serverId: serverId != null ? Value(serverId) : const Value.absent(),
      lastSyncAttempt: Value(DateTime.now()),
    ));
  }

  // ============================================================
  // COMMENTS QUERIES
  // ============================================================

  /// Get all comments for a post
  Future<List<ForumCommentData>> getCommentsForPost(String postId) async {
    return (select(forumComments)
      ..where((comment) => comment.postId.equals(postId))
      ..orderBy([
            (comment) => OrderingTerm(
          expression: comment.createdAt,
          mode: OrderingMode.asc,
        ),
      ]))
        .get();
  }

  /// Insert a new comment
  Future<int> insertComment(ForumCommentsCompanion comment) async {
    return into(forumComments).insert(comment);
  }

  /// Update comment sync status
  Future<int> updateCommentSyncStatus({
    required String localId,
    required String syncStatus,
    String? serverId,
  }) async {
    return (update(forumComments)
      ..where((comment) => comment.localId.equals(localId)))
        .write(ForumCommentsCompanion(
      syncStatus: Value(syncStatus),
      serverId: serverId != null ? Value(serverId) : const Value.absent(),
      lastSyncAttempt: Value(DateTime.now()),
    ));
  }

  // ============================================================
  // SYNC QUEUE QUERIES
  // ============================================================

  /// Add item to sync queue
  Future<int> addToSyncQueue({
    required String entityType,
    required String entityId,
    required String action,
  }) async {
    return into(syncQueue).insert(SyncQueueCompanion.insert(
      entityType: entityType,
      entityId: entityId,
      action: action,
      createdAt: DateTime.now(),
    ));
  }

  /// Get all pending sync items
  Future<List<SyncQueueData>> getPendingSyncItems() async {
    return (select(syncQueue)
      ..where((item) => item.status.equals('pending'))
      ..orderBy([
            (item) => OrderingTerm(
          expression: item.createdAt,
          mode: OrderingMode.asc,
        ),
      ]))
        .get();
  }

  /// Update sync queue item status
  Future<int> updateSyncQueueStatus({
    required int id,
    required String status,
    String? error,
    DateTime? nextRetryAt,
  }) async {
    return (update(syncQueue)..where((item) => item.id.equals(id)))
        .write(SyncQueueCompanion(
      status: Value(status),
      lastAttempt: Value(DateTime.now()),
      retryCount: Value(
        (await (select(syncQueue)..where((item) => item.id.equals(id)))
            .getSingle())
            .retryCount +
            1,
      ),
      lastError: error != null ? Value(error) : const Value.absent(),
      nextRetryAt:
      nextRetryAt != null ? Value(nextRetryAt) : const Value.absent(),
    ));
  }

  /// Remove item from sync queue after successful sync
  Future<int> removeSyncQueueItem(int id) async {
    return (delete(syncQueue)..where((item) => item.id.equals(id))).go();
  }

  /// Check if there are pending sync items
  Future<bool> hasPendingSyncItems() async {
    final count = countAll();
    final query = selectOnly(syncQueue)
      ..addColumns([count])
      ..where(syncQueue.status.equals('pending'));

    final result = await query.getSingle();
    final countValue = result.read(count) ?? 0;
    return countValue > 0;
  }

  // ============================================================
  // BATCH OPERATIONS (for server sync)
  // ============================================================

  /// Batch insert posts from server
  Future<void> batchInsertPosts(List<ForumPostsCompanion> posts) async {
    await batch((batch) {
      batch.insertAll(forumPosts, posts, mode: InsertMode.insertOrReplace);
    });
  }

  /// Batch insert comments from server
  Future<void> batchInsertComments(
      List<ForumCommentsCompanion> comments) async {
    await batch((batch) {
      batch.insertAll(forumComments, comments,
          mode: InsertMode.insertOrReplace);
    });
  }
}

/// Open database connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Get app documents directory
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'forum_db.sqlite'));

    return NativeDatabase(file);
  });
}