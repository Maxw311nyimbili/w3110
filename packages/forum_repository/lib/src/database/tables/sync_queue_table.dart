// packages/forum_repository/lib/src/database/tables/sync_queue_table.dart

import 'package:drift/drift.dart';

/// Sync queue table - tracks items that need to be synced to backend
@DataClassName('SyncQueueData')
class SyncQueue extends Table {
  // Primary key - auto-increment
  IntColumn get id => integer().autoIncrement()();

  // What needs to be synced
  TextColumn get entityType => text()(); // 'post', 'comment', 'like'
  TextColumn get entityId => text()(); // Local ID of the entity
  TextColumn get action => text()(); // 'create', 'update', 'delete'

  // Sync metadata
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAttempt => dateTime().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(
    const Constant('pending'),
  )(); // 'pending', 'syncing', 'failed'

  // Exponential backoff
  DateTimeColumn get nextRetryAt => dateTime().nullable()();

  // Error tracking
  TextColumn get lastError => text().nullable()();
}
