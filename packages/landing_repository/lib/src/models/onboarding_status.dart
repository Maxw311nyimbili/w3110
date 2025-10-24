// packages/landing_repository/lib/src/models/onboarding_status.dart

import 'package:equatable/equatable.dart';

/// Onboarding status - tracks user's onboarding completion
class OnboardingStatus extends Equatable {
  const OnboardingStatus({
    required this.isComplete,
    this.userRole,
    this.consentGiven = false,
    this.consentVersion,
    this.completedAt,
  });

  final bool isComplete;
  final String? userRole;
  final bool consentGiven;
  final String? consentVersion;
  final DateTime? completedAt;

  factory OnboardingStatus.fromJson(Map<String, dynamic> json) {
    return OnboardingStatus(
      isComplete: json['is_complete'] as bool? ?? false,
      userRole: json['user_role'] as String?,
      consentGiven: json['consent_given'] as bool? ?? false,
      consentVersion: json['consent_version'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_complete': isComplete,
      'user_role': userRole,
      'consent_given': consentGiven,
      'consent_version': consentVersion,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    isComplete,
    userRole,
    consentGiven,
    consentVersion,
    completedAt,
  ];
}