// lib/features/medscanner/cubit/medscanner_cubit.dart
// PRODUCTION IMPLEMENTATION - Real camera, image processing, analysis

import 'package:camera/camera.dart';
import 'package:cap_project/features/medscanner/cubit/medscanner_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_repository/media_repository.dart' hide ScanResult;

/// Production scanner cubit - manages real camera and medication scanning
class MedScannerCubit extends Cubit<MedScannerState> {
  MedScannerCubit({
    required MediaRepository mediaRepository,
  })  : _mediaRepository = mediaRepository,
        super(const MedScannerState());

  final MediaRepository _mediaRepository;

  /// Get camera controller for widget access - FIXED TYPE
  CameraController? get cameraController => _mediaRepository.cameraController;

  /// Initialize camera and check permissions
  Future<void> initialize() async {
    try {
      emit(state.copyWith(status: MedScannerStatus.initial));

      // Check camera permission
      final hasPermission = await _mediaRepository.checkCameraPermission();

      if (!hasPermission) {
        final granted = await _mediaRepository.requestCameraPermission();
        if (!granted) {
          emit(state.copyWith(
            status: MedScannerStatus.error,
            error: 'Camera permission denied. Enable it in app settings.',
            hasPermission: false,
          ));
          return;
        }
      }

      // Initialize available cameras (IMPORTANT: do this first)
      await _mediaRepository.initializeCameras();

      // Initialize camera controller
      await _mediaRepository.initializeCamera();

      emit(state.copyWith(
        status: MedScannerStatus.cameraReady,
        isCameraInitialized: true,
        hasPermission: true,
      ));

      print('✅ Camera initialized successfully');
    } catch (e) {
      emit(state.copyWith(
        status: MedScannerStatus.error,
        error: 'Failed to initialize camera: ${e.toString()}',
      ));
      print('❌ Camera initialization error: ${e.toString()}');
    }
  }

  /// Capture image from camera
  /// Flow: Capture → Compress → Detect Barcode → Upload → Backend Analysis
  Future<void> captureImage() async {
    if (!state.canCapture) return;

    try {
      emit(state.copyWith(status: MedScannerStatus.capturing));

      // Step 1: Capture image from camera
      print('📷 Capturing image from camera...');
      final imagePath = await _mediaRepository.captureImage();

      if (imagePath == null) {
        emit(state.copyWith(
          status: MedScannerStatus.cameraReady,
          error: 'Image capture cancelled',
        ));
        return;
      }

      print('✅ Image captured: $imagePath');

      emit(state.copyWith(
        status: MedScannerStatus.processing,
        capturedImagePath: imagePath,
      ));

      // Step 2: Compress image for upload
      print('🔧 Compressing image...');
      final compressedPath = await _mediaRepository.compressImage(imagePath);

      // Step 3: Detect barcode if present (optional)
      print('🔍 Detecting barcode...');
      final barcode = await _mediaRepository.detectBarcode(compressedPath);
      if (barcode != null) {
        print('✅ Barcode found: $barcode');
      } else {
        print('⚠️ No barcode detected');
      }

      // Step 4: Upload to backend
      print('📤 Uploading to backend...');
      final uploadResponse = await _mediaRepository.uploadImage(
        UploadRequest(
          imagePath: compressedPath,
          barcode: barcode,
        ),
      );

      print('✅ Upload successful - Scan ID: ${uploadResponse.scanId}');

      // Step 5: Analyze medication (backend processes image)
      print('🔬 Analyzing medication...');
      final repoScanResult = await _mediaRepository.analyzeMedication(
        uploadResponse.scanId,
        barcode: barcode,
      );

      print('✅ Analysis complete: ${repoScanResult.medicationName}');

      // Convert repository ScanResult to state ScanResult
      final scanResult = ScanResult(
        medicationName: repoScanResult.medicationName,
        confidence: repoScanResult.confidence,
        barcode: repoScanResult.barcode,
        activeIngredients: repoScanResult.activeIngredients,
        dosageInfo: repoScanResult.dosageInfo,
        warnings: repoScanResult.warnings,
        imageUrl: uploadResponse.url,
      );

      emit(state.copyWith(
        status: MedScannerStatus.success,
        scanResult: scanResult,
      ));
    } catch (e) {
      print('❌ Scan error: ${e.toString()}');
      emit(state.copyWith(
        status: MedScannerStatus.error,
        error: _formatErrorMessage(e.toString()),
      ));
    }
  }

  /// Pick image from gallery instead of camera
  Future<void> pickImageFromGallery() async {
    try {
      emit(state.copyWith(status: MedScannerStatus.processing));

      print('📱 Opening gallery picker...');
      final imagePath = await _mediaRepository.pickImageFromGallery();

      if (imagePath == null) {
        emit(state.copyWith(
          status: MedScannerStatus.cameraReady,
          error: 'Image selection cancelled',
        ));
        return;
      }

      print('✅ Image selected from gallery: $imagePath');

      // Follow same flow as captureImage
      print('🔧 Compressing image...');
      final compressedPath = await _mediaRepository.compressImage(imagePath);

      print('🔍 Detecting barcode...');
      final barcode = await _mediaRepository.detectBarcode(compressedPath);

      print('📤 Uploading to backend...');
      final uploadResponse = await _mediaRepository.uploadImage(
        UploadRequest(imagePath: compressedPath, barcode: barcode),
      );

      print('🔬 Analyzing medication...');
      final repoScanResult = await _mediaRepository.analyzeMedication(
        uploadResponse.scanId,
        barcode: barcode,
      );

      print('✅ Analysis complete: ${repoScanResult.medicationName}');

      // Convert repository ScanResult to state ScanResult
      final scanResult = ScanResult(
        medicationName: repoScanResult.medicationName,
        confidence: repoScanResult.confidence,
        barcode: repoScanResult.barcode,
        activeIngredients: repoScanResult.activeIngredients,
        dosageInfo: repoScanResult.dosageInfo,
        warnings: repoScanResult.warnings,
        imageUrl: uploadResponse.url,
      );

      emit(state.copyWith(
        status: MedScannerStatus.success,
        capturedImagePath: imagePath,
        scanResult: scanResult,
      ));
    } catch (e) {
      print('❌ Gallery picker error: ${e.toString()}');
      emit(state.copyWith(
        status: MedScannerStatus.error,
        error: _formatErrorMessage(e.toString()),
      ));
    }
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
  @override
  Future<void> close() async {
    await _mediaRepository.dispose();
    return super.close();
  }

  /// Format error messages for user display - RETURNS TRANSLATION KEYS
  String _formatErrorMessage(String error) {
    if (error.contains('permission')) {
      return 'cameraPermissionDenied';
    } else if (error.contains('no camera')) {
      return 'noCameraFound';
    } else if (error.contains('upload')) {
      return 'uploadFailed';
    } else if (error.contains('analyze') || error.contains('analysis')) {
      return 'analysisFailed';
    } else if (error.contains('too large')) {
      return 'fileTooLarge';
    }
    return 'genericError';
  }
}