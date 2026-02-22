// packages/forum_repository/lib/src/database/tables/forum_posts_table.dart

import 'package:drift/drift.dart';

/// Forum posts table - stores all posts locally
@DataClassName('ForumPostData')
class ForumPosts extends Table {
  // Primary key - local unique ID (UUID)
  TextColumn get localId => text()();

  // Server ID (empty string if not synced yet)
  TextColumn get serverId => text().withDefault(const Constant(''))();

  // Post content
  TextColumn get authorId => text()();
  TextColumn get authorName => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();

  // Timestamps
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  // Engagement metrics
  IntColumn get commentCount => integer().withDefault(const Constant(0))();
  IntColumn get likeCount => integer().withDefault(const Constant(0))();
  IntColumn get viewCount => integer().nullable().withDefault(const Constant(0))();
  BoolColumn get isLiked => boolean().withDefault(const Constant(false))();

  // Sync status: 'synced', 'pending', 'syncing', 'error'
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  // Sources from Chat (serialized JSON)
  TextColumn get sources => text().nullable()();

  // Tags (serialized JSON)
  TextColumn get tags => text().nullable()();

  // Link to original chat answer (if created from chat)
  TextColumn get originalAnswerId => text().nullable()();

  // Sync metadata
  DateTimeColumn get lastSyncAttempt => dateTime().nullable()();
  IntColumn get syncRetryCount => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {localId};
}