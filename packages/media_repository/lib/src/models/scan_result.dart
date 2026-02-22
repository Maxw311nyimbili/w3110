// packages/media_repository/lib/src/models/scan_result.dart

import 'package:equatable/equatable.dart';

/// Scan result from backend medication analysis
class ScanResult extends Equatable {
  const ScanResult({
    required this.medicationName,
    required this.confidence,
    this.barcode,
    this.activeIngredients = const [],
    this.dosageInfo,
    this.warnings = const [],
  });

  final String medicationName;
  final double confidence; // 0.0 - 1.0
  final String? barcode;
  final List<String> activeIngredients;
  final String? dosageInfo;
  final List<String> warnings;

  /// Parse from backend JSON
  /// Expected response from POST /media/analyze:
  /// {
  ///   "medication_name": "Ibuprofen 200mg",
  ///   "confidence": 0.92,
  ///   "barcode": "123456789012",
  ///   "active_ingredients": ["Ibuprofen 200mg"],
  ///   "dosage_info": "Take 1-2 tablets every 4-6 hours",
  ///   "warnings": [
  ///     "Do not exceed 6 tablets in 24 hours",
  ///     "May cause stomach upset"
  ///   ]
  /// }
  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      medicationName: json['medication_name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      barcode: json['barcode'] as String?,
      activeIngredients:
          (json['active_ingredients'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dosageInfo: json['dosage_info'] as String?,
      warnings:
          (json['warnings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [
    medicationName,
    confidence,
    barcode,
    activeIngredients,
    dosageInfo,
    warnings,
  ];
}
