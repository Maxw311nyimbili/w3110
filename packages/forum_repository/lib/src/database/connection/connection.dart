// packages/forum_repository/lib/src/database/connection/connection.dart

import 'package:drift/drift.dart';

import 'connection_unsupported.dart'
    if (dart.library.js_interop) 'web.dart'
    if (dart.library.io) 'native.dart';

/// Opens the appropriate database connection for the current platform.
QueryExecutor openConnection() => openConnectionImpl();
