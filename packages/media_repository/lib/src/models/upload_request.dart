// packages/media_repository/lib/src/models/upload_request.dart

import 'package:equatable/equatable.dart';

/// Request for uploading image to backend
class UploadRequest extends Equatable {
  const UploadRequest({
    required this.imagePath,
    required this.scanType,
    this.barcode,
  });

  final String imagePath; // Local file path
  final String scanType; // "barcode", "text_ocr", "label_ocr"
  final String? barcode; // Detected barcode (if any)

  @override
  List<Object?> get props => [imagePath, scanType, barcode];
}
