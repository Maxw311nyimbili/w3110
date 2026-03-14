// packages/media_repository/lib/src/utils/barcode_scanner_io.dart

import 'dart:io';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'barcode_scanner_stub.dart';

class BarcodeScannerIO implements BarcodeScannerInterface {
  final BarcodeScanner _scanner = BarcodeScanner();

  @override
  Future<String?> processImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final barcodes = await _scanner.processImage(inputImage);
    
    if (barcodes.isEmpty) return null;
    return barcodes.first.rawValue;
  }

  @override
  Future<void> close() async {
    await _scanner.close();
  }
}

BarcodeScannerInterface getBarcodeScanner() => BarcodeScannerIO();
