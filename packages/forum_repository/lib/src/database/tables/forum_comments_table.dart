// packages/forum_repository/lib/src/database/tables/forum_comments_table.dart

import 'package:drift/drift.dart';

/// Forum comments table - stores all comments locally
@DataClassName('ForumCommentData')
class ForumComments extends Table {
  // Primary key - local unique ID (UUID)
  TextColumn get localId => text()();

  // Server ID (empty string if not synced yet)
  TextColumn get serverId => text().withDefault(const Constant(''))();

  // Foreign key - references post
  TextColumn get postId => text()();

  // Comment content
  TextColumn get authorId => text()();
  TextColumn get authorName => text()();
  TextColumn get content => text()();

  // Timestamps
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

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