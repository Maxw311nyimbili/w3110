// lib/features/medscanner/cubit/medscanner_cubit.dart

import 'package:cap_project/features/medscanner/cubit/medscanner_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_repository/media_repository.dart' hide ScanResult;

/// Manages camera, image capture, and medication scanning
class MedScannerCubit extends Cubit<MedScannerState> {
  MedScannerCubit({
    required MediaRepository mediaRepository,
  })  : _mediaRepository = mediaRepository,
        super(const MedScannerState());

  final MediaRepository _mediaRepository;

  /// Initialize camera and check permissions
  Future<void> initialize() async {
    try {
      emit(state.copyWith(status: MedScannerStatus.initial));

      // TODO: Uncomment when camera package is integrated
      /*
      // Check camera permission
      final hasPermission = await _mediaRepository.checkCameraPermission();
      
      if (!hasPermission) {
        final granted = await _mediaRepository.requestCameraPermission();
        if (!granted) {
          emit(state.copyWith(
            status: MedScannerStatus.error,
            error: 'Camera permission denied',
            hasPermission: false,
          ));
          return;
        }
      }

      // Initialize camera
      await _mediaRepository.initializeCamera();
      
      emit(state.copyWith(
        status: MedScannerStatus.cameraReady,
        isCameraInitialized: true,
        hasPermission: true,
      ));
      */

      // TEMPORARY: Skip camera initialization for development
      emit(state.copyWith(
        status: MedScannerStatus.cameraReady,
        isCameraInitialized: true,
        hasPermission: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MedScannerStatus.error,
        error: 'Failed to initialize camera: ${e.toString()}',
      ));
    }
  }

  /// Capture image from camera
  /// Flow: Capture → Compress → Detect Barcode → Upload → Backend Analysis
  Future<void> captureImage() async {
    if (!state.canCapture) return;

    try {
      emit(state.copyWith(status: MedScannerStatus.capturing));

      // TODO: Uncomment when camera package is integrated
      /*
      // Step 1: Capture image from camera
      final imagePath = await _mediaRepository.captureImage();
      
      if (imagePath == null) {
        emit(state.copyWith(
          status: MedScannerStatus.cameraReady,
          error: 'Image capture cancelled',
        ));
        return;
      }

      emit(state.copyWith(
        status: MedScannerStatus.processing,
        capturedImagePath: imagePath,
      ));

      // Step 2: Compress image for upload
      final compressedPath = await _mediaRepository.compressImage(imagePath);

      // Step 3: Detect barcode if present (optional but helpful)
      final barcode = await _mediaRepository.detectBarcode(compressedPath);

      // Step 4: Upload to backend
      // Backend endpoint: POST /media/upload
      // Request: multipart/form-data with image file
      // Response: { "url": "uploaded_image_url", "scan_id": "..." }
      final uploadResponse = await _mediaRepository.uploadImage(
        UploadRequest(
          imagePath: compressedPath,
          barcode: barcode,
        ),
      );

      // Step 5: Analyze medication (backend processes image)
      // Backend endpoint: POST /media/analyze
      // Request: { "scan_id": "...", "barcode": "..." }
      // Response: { "medication_name": "...", "confidence": 0.9, ... }
      final scanResult = await _mediaRepository.analyzeMedication(
        uploadResponse.scanId,
      );

      emit(state.copyWith(
        status: MedScannerStatus.success,
        scanResult: ScanResult(
          medicationName: scanResult.medicationName,
          confidence: scanResult.confidence,
          barcode: scanResult.barcode,
          activeIngredients: scanResult.activeIngredients,
          dosageInfo: scanResult.dosageInfo,
          warnings: scanResult.warnings,
          imageUrl: uploadResponse.url,
        ),
      ));
      */

      // TEMPORARY: Mock scan result for development
      await Future.delayed(const Duration(seconds: 2));

      emit(state.copyWith(
        status: MedScannerStatus.success,
        capturedImagePath: '/mock/path/image.jpg',
        scanResult: const ScanResult(
          medicationName: 'Ibuprofen 200mg',
          confidence: 0.92,
          barcode: '123456789012',
          activeIngredients: ['Ibuprofen 200mg'],
          dosageInfo: 'Take 1-2 tablets every 4-6 hours as needed',
          warnings: [
            'Do not exceed 6 tablets in 24 hours',
            'Consult doctor if pregnant or breastfeeding',
            'May cause stomach upset',
          ],
          imageUrl: 'https://example.com/mock-image.jpg',
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MedScannerStatus.error,
        error: 'Scan failed: ${e.toString()}',
      ));
    }
  }

  /// Pick image from gallery instead of camera
  Future<void> pickImageFromGallery() async {
    try {
      emit(state.copyWith(status: MedScannerStatus.processing));

      // TODO: Uncomment when image_picker is integrated
      /*
      final imagePath = await _mediaRepository.pickImageFromGallery();
      
      if (imagePath == null) {
        emit(state.copyWith(
          status: MedScannerStatus.cameraReady,
          error: 'Image selection cancelled',
        ));
        return;
      }

      // Follow same flow as captureImage (compress → upload → analyze)
      final compressedPath = await _mediaRepository.compressImage(imagePath);
      final barcode = await _mediaRepository.detectBarcode(compressedPath);
      
      final uploadResponse = await _mediaRepository.uploadImage(
        UploadRequest(imagePath: compressedPath, barcode: barcode),
      );
      
      final scanResult = await _mediaRepository.analyzeMedication(
        uploadResponse.scanId,
      );

      emit(state.copyWith(
        status: MedScannerStatus.success,
        capturedImagePath: imagePath,
        scanResult: ScanResult(...),
      ));
      */

      // TEMPORARY: Mock result
      await Future.delayed(const Duration(seconds: 2));

      emit(state.copyWith(
        status: MedScannerStatus.success,
        capturedImagePath: '/mock/gallery/image.jpg',
        scanResult: const ScanResult(
          medicationName: 'Acetaminophen 500mg',
          confidence: 0.88,
          activeIngredients: ['Acetaminophen 500mg'],
          dosageInfo: 'Take 1-2 tablets every 4-6 hours',
          warnings: ['Do not exceed 4000mg in 24 hours'],
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MedScannerStatus.error,
        error: 'Failed to process image: ${e.toString()}',
      ));
    }
  }

  /// Send scan result to chat for further discussion
  void sendResultToChat() {
    // This will be called from the UI to navigate to chat with result
    // The navigation logic will be in the widget
  }

  /// Clear current scan and reset to camera
  void clearScan() {
    emit(state.clearResult());
  }

  /// Clear error state
  void clearError() {
    emit(state.clearError());
  }

  /// Dispose camera resources
  Future<void> dispose() async {
    // TODO: Uncomment when camera package is integrated
    // await _mediaRepository.disposeCamera();
  }
}