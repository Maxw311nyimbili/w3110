// packages/media_repository/lib/src/models/upload_response.dart

import 'package:equatable/equatable.dart';

/// Response from image upload endpoint
class UploadResponse extends Equatable {
  const UploadResponse({
    required this.url,
    required this.scanId,
  });

  final String url;    // Uploaded image file path / URL
  final String scanId; // ID for referencing the scan (backend `id` field)

  /// Parse from backend JSON.
  ///
  /// Actual backend response shape (POST /media/upload):
  /// {
  ///   "id": 1,
  ///   "file_name": "scan_xxx.jpg",
  ///   "file_path": "./uploads/xxx.jpg",
  ///   "scan_type": "text_ocr",
  ///   "processing_status": "completed",
  ///   "extracted_data": {
  ///     "source": "ai_classifier",
  ///     "status": "rejected" | "accepted",
  ///     "reason": "...",    // present when rejected
  ///     "data": { ... }     // null when rejected
  ///   }
  /// }
  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    // Check if the image was rejected by the AI classifier before continuing.
    final extractedData = json['extracted_data'] as Map<String, dynamic>?;
    if (extractedData != null) {
      final status = extractedData['status'] as String? ?? '';
      if (status == 'rejected') {
        final reason = extractedData['reason'] as String? ??
            'Image could not be processed. Please try again with a clearer photo.';
        throw MediaUploadRejectedException(reason);
      }
    }

    return UploadResponse(
      // Backend returns `id` (int) — convert to String for downstream use.
      scanId: json['id']?.toString() ?? '',
      // Backend returns `file_path`; fall back to `url` if ever changed.
      url: (json['file_path'] ?? json['url'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [url, scanId];
}

/// Thrown when the backend AI classifier rejects the uploaded image.
class MediaUploadRejectedException implements Exception {
  const MediaUploadRejectedException(this.reason);
  final String reason;

  @override
  String toString() => reason;
}
