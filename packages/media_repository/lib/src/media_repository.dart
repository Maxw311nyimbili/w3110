// packages/media_repository/lib/src/media_repository.dart

import 'package:api_client/api_client.dart';
import 'models/upload_request.dart';
import 'models/upload_response.dart';
import 'models/scan_result.dart';
import 'image_processor.dart';
import 'exceptions/media_exception.dart';

/// Media repository - handles camera, image upload, and medication scanning
class MediaRepository {
  MediaRepository({
    required ApiClient apiClient,
    required ImageProcessor imageProcessor,
  })  : _apiClient = apiClient,
        _imageProcessor = imageProcessor;

  final ApiClient _apiClient;
  final ImageProcessor _imageProcessor;

  /// Check camera permission
  ///
  /// TODO: Implement when permission_handler is added
  /// Required package: permission_handler
  Future<bool> checkCameraPermission() async {
    /*
    final status = await Permission.camera.status;
    return status.isGranted;
    */
    return true; // Temporary
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    /*
    final status = await Permission.camera.request();
    return status.isGranted;
    */
    return true; // Temporary
  }

  /// Initialize camera
  ///
  /// TODO: Implement when camera package is added
  /// Required package: camera
  Future<void> initializeCamera() async {
    /*
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw MediaException('No cameras available');
      }

      // Initialize first camera (usually back camera)
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
      );

      await controller.initialize();

      // Store controller reference for use in widgets
      _cameraController = controller;
    } catch (e) {
      throw MediaException('Camera initialization failed: ${e.toString()}');
    }
    */
  }

  /// Capture image from camera
  /// Returns local file path
  Future<String?> captureImage() async {
    /*
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        throw MediaException('Camera not initialized');
      }

      final XFile image = await _cameraController!.takePicture();
      return image.path;
    } catch (e) {
      throw MediaException('Image capture failed: ${e.toString()}');
    }
    */
    return null; // Temporary
  }

  /// Pick image from gallery
  ///
  /// TODO: Implement when image_picker is added
  /// Required package: image_picker
  Future<String?> pickImageFromGallery() async {
    /*
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      return image?.path;
    } catch (e) {
      throw MediaException('Image picker failed: ${e.toString()}');
    }
    */
    return null; // Temporary
  }

  /// Compress image before upload
  Future<String> compressImage(String imagePath) async {
    return await _imageProcessor.compressImage(imagePath);
  }

  /// Detect barcode in image
  Future<String?> detectBarcode(String imagePath) async {
    return await _imageProcessor.detectBarcode(imagePath);
  }

  /// Upload image to backend
  ///
  /// Backend endpoint: POST /media/upload
  /// Request: multipart/form-data with image file + optional barcode
  /// Response: { "url": "https://...", "scan_id": "uuid" }
  Future<UploadResponse> uploadImage(UploadRequest request) async {
    try {
      // TODO: Implement actual multipart upload when dio is configured
      /*
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          request.imagePath,
          filename: 'scan.jpg',
        ),
        if (request.barcode != null) 'barcode': request.barcode,
      });

      final response = await _apiClient.post(
        '/media/upload',
        data: formData,
      );

      return UploadResponse.fromJson(response.data);
      */

      // TEMPORARY: Return mock response
      return UploadResponse(
        url: 'https://example.com/mock-image.jpg',
        scanId: 'mock_scan_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      throw MediaException('Image upload failed: ${e.toString()}');
    }
  }

  /// Analyze medication from uploaded image
  ///
  /// Backend endpoint: POST /media/analyze
  /// Request: { "scan_id": "uuid", "barcode": "optional" }
  /// Response: { "medication_name": "...", "confidence": 0.9, ... }
  Future<ScanResult> analyzeMedication(String scanId) async {
    try {
      final response = await _apiClient.post(
        '/media/analyze',
        data: {'scan_id': scanId},
      );

      return ScanResult.fromJson(response.data as Map<String, dynamic>);

    } catch (e) {
      throw MediaException('Medication analysis failed: ${e.toString()}');
    }
  }

  /// Dispose camera resources
  Future<void> disposeCamera() async {
    /*
    try {
      await _cameraController?.dispose();
      _cameraController = null;
    } catch (e) {
      // Silent fail
    }
    */
  }
}