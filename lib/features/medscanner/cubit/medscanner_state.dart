// lib/features/medscanner/cubit/medscanner_state.dart

import 'package:equatable/equatable.dart';

enum MedScannerStatus {
  initial,
  cameraReady,
  capturing,
  processing,
  success,
  error,
}

/// Immutable scanner state - manages camera and scan results
class MedScannerState extends Equatable {
  const MedScannerState({
    this.status = MedScannerStatus.initial,
    this.capturedImagePath,
    this.scanResult,
    this.error,
    this.isCameraInitialized = false,
    this.hasPermission = false,
  });

  final MedScannerStatus status;
  final String? capturedImagePath;
  final ScanResult? scanResult;
  final String? error;
  final bool isCameraInitialized;
  final bool hasPermission;

  bool get isProcessing => status == MedScannerStatus.processing;
  bool get hasResult => scanResult != null;
  bool get canCapture => isCameraInitialized && hasPermission;

  MedScannerState copyWith({
    MedScannerStatus? status,
    String? capturedImagePath,
    ScanResult? scanResult,
    String? error,
    bool? isCameraInitialized,
    bool? hasPermission,
  }) {
    return MedScannerState(
      status: status ?? this.status,
      capturedImagePath: capturedImagePath ?? this.capturedImagePath,
      scanResult: scanResult ?? this.scanResult,
      error: error,
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      hasPermission: hasPermission ?? this.hasPermission,
    );
  }

  MedScannerState clearError() {
    return copyWith(error: null);
  }

  MedScannerState clearResult() {
    return copyWith(
      status: MedScannerStatus.cameraReady,
      capturedImagePath: null,
      scanResult: null,
    );
  }

  @override
  List<Object?> get props => [
    status,
    capturedImagePath,
    scanResult,
    error,
    isCameraInitialized,
    hasPermission,
  ];
}

/// Scan result model - data returned from backend after image analysis
class ScanResult extends Equatable {
  const ScanResult({
    required this.medicationName,
    required this.confidence,
    this.barcode,
    this.activeIngredients = const [],
    this.dosageInfo,
    this.warnings = const [],
    this.imageUrl,
  });

  final String medicationName;
  final double confidence; // 0.0 - 1.0
  final String? barcode;
  final List<String> activeIngredients;
  final String? dosageInfo;
  final List<String> warnings;
  final String? imageUrl; // Processed image URL from backend

  @override
  List<Object?> get props => [
    medicationName,
    confidence,
    barcode,
    activeIngredients,
    dosageInfo,
    warnings,
    imageUrl,
  ];
}
