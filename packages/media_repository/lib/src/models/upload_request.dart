// packages/media_repository/lib/src/models/upload_request.dart

import 'package:equatable/equatable.dart';

/// Request for uploading image to backend
class UploadRequest extends Equatable {
  const UploadRequest({
    required this.imagePath,
    this.barcode,
  });

  final String imagePath; // Local file path
  final String? barcode; // Detected barcode (if any)

  @override
  List<Object?> get props => [imagePath, barcode];
}
