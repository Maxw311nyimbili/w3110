// packages/media_repository/lib/src/utils/barcode_scanner_web.dart

import 'barcode_scanner_stub.dart';

class BarcodeScannerWeb implements BarcodeScannerInterface {
  @override
  Future<String?> processImage(String imagePath) async {
    // Barcode scanning is not supported on web currently
    return null;
  }

  @override
  Future<void> close() async {
    // Nothing to close
  }
}

BarcodeScannerInterface getBarcodeScanner() => BarcodeScannerWeb();
