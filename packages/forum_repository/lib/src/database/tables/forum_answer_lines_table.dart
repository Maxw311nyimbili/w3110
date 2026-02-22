// packages/forum_repository/lib/src/database/tables/forum_answer_lines_table.dart

import 'package:drift/drift.dart';

/// Individual sentences from a post/answer for line-level discussion
@DataClassName('ForumAnswerLineData')
class ForumAnswerLines extends Table {
  TextColumn get lineId => text()();

  // Link to parent answer (seed) OR post
  TextColumn get answerId => text().nullable()();
  IntColumn get postId => integer().nullable()();

  IntColumn get lineNumber => integer()();
  TextColumn get textContent => text()();
  TextColumn get discussionTitle => text().nullable()();

  // Engagement
  IntColumn get commentCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {lineId};
}
