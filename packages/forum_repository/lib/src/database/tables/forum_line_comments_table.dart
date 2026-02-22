// packages/forum_repository/lib/src/database/tables/forum_line_comments_table.dart

import 'package:drift/drift.dart';

/// Comments tied to a specific line/sentence
@DataClassName('ForumLineCommentData')
class ForumLineComments extends Table {
  TextColumn get localId => text()();
  TextColumn get serverId => text().withDefault(const Constant(''))();

  TextColumn get lineId => text()();
  TextColumn get authorId => text()();
  TextColumn get authorName => text()();
  TextColumn get authorRole => text()(); // 'clinician', 'mother', 'community'
  TextColumn get commentType =>
      text()(); // 'clinical', 'evidence', 'experience', 'concern'
  TextColumn get content => text()();
  TextColumn get parentCommentId => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  DateTimeColumn get createdAt => dateTime()();

  // Sync status
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {localId};
}
