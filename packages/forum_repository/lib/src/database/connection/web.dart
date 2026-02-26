// packages/forum_repository/lib/src/database/connection/web.dart

import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor openConnectionImpl() {
  // Use IndexedDb for web to avoid requiring sqlite3.wasm and drift_worker.js
  // This is more resilient for web hosting environments.
  return WebDatabase('forum_db', logStatements: true);
}
