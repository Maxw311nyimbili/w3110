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
  BoolColumn get isLiked => boolean().withDefault(const Constant(false))();

  // Sync status: 'synced', 'pending', 'syncing', 'error'
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  // Sync metadata
  DateTimeColumn get lastSyncAttempt => dateTime().nullable()();
  IntColumn get syncRetryCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {localId};

  @override
  List<Set<Column>> get uniqueKeys => [
    {serverId}, // Server ID should be unique when present
  ];
}