// packages/forum_repository/lib/src/database/connection/connection_unsupported.dart

import 'package:drift/drift.dart';

QueryExecutor openConnectionImpl() {
  throw UnsupportedError('Opening a database on this platform is not supported.');
}
