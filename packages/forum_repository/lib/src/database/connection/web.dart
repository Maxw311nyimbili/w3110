// packages/forum_repository/lib/src/database/connection/web.dart

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

QueryExecutor openConnectionImpl() {
  // For now, we use a simple web database. 
  // In a full implementation, we might use WasmDatabase.
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'forum_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}
