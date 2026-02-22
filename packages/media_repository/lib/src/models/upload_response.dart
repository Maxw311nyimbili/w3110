// packages/media_repository/lib/src/models/upload_response.dart

import 'package:equatable/equatable.dart';

/// Response from image upload endpoint
class UploadResponse extends Equatable {
  const UploadResponse({
    required this.url,
    required this.scanId,
  });

  final String url; // Uploaded image URL
  final String scanId; // ID for analyzing the image

  /// Parse from backend JSON
  /// Expected response from POST /media/upload:
  /// {
  ///   "url": "https://storage.example.com/scans/uuid.jpg",
  ///   "scan_id": "uuid-here"
  /// }
  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      url: json['url'] as String,
      scanId: json['scan_id'] as String,
    );
  }

  @override
  List<Object?> get props => [url, scanId];
}
