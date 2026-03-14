// packages/media_repository/lib/src/utils/barcode_scanner_stub.dart

/// Cross-platform interface for barcode scanning
abstract class BarcodeScannerInterface {
  Future<String?> processImage(String imagePath);
  Future<void> close();
}

/// Factory to get the platform-specific implementation
BarcodeScannerInterface getBarcodeScanner() => throw UnsupportedError('Cannot create a barcode scanner');
