// packages/media_repository/lib/src/image_processor.dart
// PRODUCTION IMPLEMENTATION - Real compression and barcode detection

import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'exceptions/media_exception.dart';

/// Production image processor - compression, barcode detection
class ImageProcessor {
  ImageProcessor();

  static const int maxWidth = 1920;
  static const int maxHeight = 1920;
  static const int jpegQuality = 85;
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

  /// Compress image before upload
  /// Target: < 5MB, quality 85%, max 1920x1920
  Future<String> compressImage(String imagePath) async {
    try {
      final imageFile = File(imagePath);

      // Check if file exists
      if (!await imageFile.exists()) {
        throw MediaException('Image file not found: $imagePath');
      }

      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();

      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw MediaException('Failed to decode image - unsupported format');
      }

      // Resize if too large
      img.Image resized = image;
      if (image.width > maxWidth || image.height > maxHeight) {
        resized = img.copyResize(
          image,
          width: image.width > maxWidth ? maxWidth : null,
          height: image.height > maxHeight ? maxHeight : null,
          interpolation: img.Interpolation.average,
        );
      }

      // Encode as JPEG with quality 85
      final compressed = img.encodeJpg(resized, quality: jpegQuality);

      // Check compressed size
      if (compressed.length > maxFileSizeBytes) {
        throw MediaException(
          'Compressed image still too large (${(compressed.length / 1024 / 1024).toStringAsFixed(2)}MB)',
        );
      }

      // Save compressed image with timestamp
      final compressedFileName = _generateCompressedFileName(imagePath);
      final compressedFile = File(compressedFileName);
      await compressedFile.writeAsBytes(compressed);

      print('✅ Image compressed: ${(compressed.length / 1024).toStringAsFixed(2)}KB');
      return compressedFileName;
    } catch (e) {
      if (e is MediaException) rethrow;
      throw MediaException('Image compression failed: ${e.toString()}');
    }
  }

  /// Detect barcode in image
  /// Supports: EAN, UPC, Code128, Code39, QR, etc.
  Future<String?> detectBarcode(String imagePath) async {
    BarcodeScanner? barcodeScanner;
    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return null; // File not found, return null (optional)
      }

      // Initialize barcode scanner
      barcodeScanner = BarcodeScanner();

      // Create input image
      final inputImage = InputImage.fromFilePath(imagePath);

      // Process image
      final barcodes = await barcodeScanner.processImage(inputImage);

      if (barcodes.isEmpty) {
        return null; // No barcode detected
      }

      // Return first barcode found
      final barcode = barcodes.first.rawValue;
      if (barcode != null && barcode.isNotEmpty) {
        print('✅ Barcode detected: $barcode');
        return barcode;
      }

      return null;
    } catch (e) {
      // Barcode detection is optional - don't fail
      print('⚠️ Barcode detection failed: ${e.toString()}');
      return null;
    } finally {
      // Clean up
      await barcodeScanner?.close();
    }
  }

  /// Validate image before upload
  /// Checks: file exists, format is jpg/png, size < 10MB
  Future<bool> validateImage(String imagePath) async {
    try {
      final imageFile = File(imagePath);

      // Check file exists
      if (!await imageFile.exists()) {
        return false;
      }

      // Check file size (max 10MB)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        return false;
      }

      // Check file extension
      final extension = imageFile.path.toLowerCase().split('.').last;
      if (!['jpg', 'jpeg', 'png'].contains(extension)) {
        return false;
      }

      // Try to decode to verify it's a valid image
      try {
        final bytes = await imageFile.readAsBytes();
        final image = img.decodeImage(bytes);
        return image != null;
      } catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Generate filename for compressed image
  String _generateCompressedFileName(String originalPath) {
    final file = File(originalPath);
    final dir = file.parent.path;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$dir/compressed_$timestamp.jpg';
  }

  /// Get image dimensions
  Future<({int width, int height})> getImageDimensions(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw MediaException('Failed to decode image');
      }

      return (width: image.width, height: image.height);
    } catch (e) {
      throw MediaException('Failed to get image dimensions: ${e.toString()}');
    }
  }

  /// Get file size in MB
  static Future<double> getFileSizeInMB(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.length();
      return bytes / (1024 * 1024);
    } catch (e) {
      return 0;
    }
  }
}