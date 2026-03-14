// packages/media_repository/lib/src/utils/file_utils.dart
export 'file_utils_stub.dart'
    if (dart.library.io) 'file_utils_io.dart'
    if (dart.library.html) 'file_utils_web.dart';
