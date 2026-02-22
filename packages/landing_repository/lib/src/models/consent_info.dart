// packages/landing_repository/lib/src/models/consent_info.dart

import 'package:equatable/equatable.dart';

/// Consent info - medical disclaimer and consent details
class ConsentInfo extends Equatable {
  const ConsentInfo({
    required this.version,
    required this.content,
    required this.isRequired,
  });

  final String version; // e.g., "1.0", "1.1"
  final String content; // Full consent text
  final bool isRequired;

  factory ConsentInfo.fromJson(Map<String, dynamic> json) {
    return ConsentInfo(
      version: json['version'] as String,
      content: json['content'] as String,
      isRequired: json['is_required'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [version, content, isRequired];
}
