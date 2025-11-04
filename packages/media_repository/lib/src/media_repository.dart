// packages/media_repository/lib/src/media_repository.dart
// PRODUCTION IMPLEMENTATION - Real camera, image processing, upload

import 'dart:io';
import 'package:api_client/api_client.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'models/upload_request.dart';
import 'models/upload_response.dart';
import 'models/scan_result.dart';
import 'image_processor.dart';
import 'exceptions/media_exception.dart';

/// Production media repository - handles real camera, image upload, and medication scanning
class MediaRepository {
  MediaRepository({
    required ApiClient apiClient,
    required ImageProcessor imageProcessor,
  })  : _apiClient = apiClient,
        _imageProcessor = imageProcessor,
        _imagePicker = ImagePicker();

  final ApiClient _apiClient;
  final ImageProcessor _imageProcessor;
  final ImagePicker _imagePicker;

  CameraController? _cameraController;
  late List<CameraDescription> _cameras;

  // Getters
  CameraController? get cameraController => _cameraController;
  bool get isCameraInitialized => _cameraController?.value.isInitialized ?? false;

  /// Check camera permission
  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Initialize available cameras and select back camera
  Future<void> initializeCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw MediaException('No cameras available on this device');
      }
    } catch (e) {
      throw MediaException('Failed to initialize cameras: ${e.toString()}');
    }
  }

  /// Initialize camera controller (call after user selects camera)
  Future<void> initializeCamera() async {
    try {
      // Check permission first
      final hasPermission = await checkCameraPermission();
      if (!hasPermission) {
        final granted = await requestCameraPermission();
        if (!granted) {
          throw MediaException('Camera permission denied');
        }
      }

      // Initialize cameras list if not already done
      if (_cameras.isEmpty) {
        await initializeCameras();
      }

      // Get back camera (index 0 is usually back camera)
      final backCamera = _cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
    } catch (e) {
      throw MediaException('Camera initialization failed: ${e.toString()}');
    }
  }

  /// Capture image from camera
  /// Returns local file path
  Future<String?> captureImage() async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        throw MediaException('Camera not initialized');
      }

      if (_cameraController!.value.isTakingPicture) {
        throw MediaException('Camera is already taking a picture');
      }

      final XFile image = await _cameraController!.takePicture();
      return image.path;
    } catch (e) {
      throw MediaException('Image capture failed: ${e.toString()}');
    }
  }

  /// Pick image from gallery
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) {
        return null; // User cancelled
      }

      return image.path;
    } catch (e) {
      throw MediaException('Image picker failed: ${e.toString()}');
    }
  }

  /// Compress image before upload
  Future<String> compressImage(String imagePath) async {
    try {
      final compressed = await _imageProcessor.compressImage(imagePath);
      return compressed;
    } catch (e) {
      throw MediaException('Image compression failed: ${e.toString()}');
    }
  }

  /// Detect barcode in image
  Future<String?> detectBarcode(String imagePath) async {
    try {
      final barcode = await _imageProcessor.detectBarcode(imagePath);
      return barcode;
    } catch (e) {
      // Barcode detection is optional - don't fail
      return null;
    }
  }

  /// Upload image to backend
  /// Backend endpoint: POST /media/upload
  /// Request: multipart/form-data with image file + optional barcode
  /// Response: { "url": "https://...", "scan_id": "uuid" }
  Future<UploadResponse> uploadImage(UploadRequest request) async {
    try {
      // Validate image exists
      final imageFile = File(request.imagePath);
      if (!await imageFile.exists()) {
        throw MediaException('Image file not found: ${request.imagePath}');
      }

      // Check file size (max 10MB)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw MediaException('Image file too large (max 10MB)');
      }

      // Create multipart form data
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          request.imagePath,
          filename: 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        if (request.barcode != null) 'barcode': request.barcode,
      });

      // Upload to backend
      final response = await _apiClient.post(
        '/media/upload',
        data: formData,
      );

      // Parse response
      final uploadResponse = UploadResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      return uploadResponse;
    } catch (e) {
      if (e is MediaException) {
        rethrow;
      }
      throw MediaException('Image upload failed: ${e.toString()}');
    }
  }

  /// Analyze medication from uploaded image
  /// Backend endpoint: POST /media/analyze
  /// Request: { "scan_id": "uuid", "barcode": "optional" }
  /// Response: { "medication_name": "...", "confidence": 0.9, ... }
  Future<ScanResult> analyzeMedication(String scanId, {String? barcode}) async {
    try {
      final response = await _apiClient.post(
        '/media/analyze',
        data: {
          'scan_id': scanId,
          if (barcode != null) 'barcode': barcode,
        },
      );

      final scanResult = ScanResult.fromJson(
        response.data as Map<String, dynamic>,
      );

      return scanResult;
    } catch (e) {
      throw MediaException('Medication analysis failed: ${e.toString()}');
    }
  }

  /// Dispose camera resources
  Future<void> disposeCamera() async {
    try {
      await _cameraController?.dispose();
      _cameraController = null;
    } catch (e) {
      // Silent fail on disposal
    }
  }

  /// Dispose all resources
  Future<void> dispose() async {
    await disposeCamera();
  }
}