// packages/media_repository/lib/src/utils/barcode_scanner.dart
export 'barcode_scanner_stub.dart'
    if (dart.library.io) 'barcode_scanner_io.dart'
    if (dart.library.html) 'barcode_scanner_web.dart';
