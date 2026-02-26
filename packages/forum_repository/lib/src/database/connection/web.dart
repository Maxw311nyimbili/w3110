// packages/forum_repository/lib/src/database/connection/web.dart

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

QueryExecutor openConnectionImpl() {
  return LazyDatabase(() async {
    try {
      final result = await WasmDatabase.open(
        databaseName: 'forum_db',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );
      return result.resolvedExecutor;
    } catch (e) {
      print('❌ DRIFT WEB ERROR: Failed to open WasmDatabase. '
          'This is expected if sqlite3.wasm and drift_worker.js are missing from the web/ directory. '
          'The forum will operate in online-only mode for now. Error: $e');
      
      // We rethrow so that the first query fails, but ForumCubit 
      // is now updated to catch these and show the UI anyway.
      rethrow;
    }
  });
}
