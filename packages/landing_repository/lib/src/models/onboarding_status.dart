// packages/landing_repository/lib/src/models/onboarding_status.dart

import 'package:equatable/equatable.dart';

/// Onboarding status - tracks user's onboarding completion
class OnboardingStatus extends Equatable {
  const OnboardingStatus({
    required this.isComplete,
    this.userRole,
    this.userName,
    this.accountNickname,
    this.interests = const [],
    this.consentGiven = false,
    this.consentVersion,
    this.completedAt,
  });

  final bool isComplete;
  final String? userRole;
  final String? userName;
  final String? accountNickname;
  final List<String> interests;
  final bool consentGiven;
  final String? consentVersion;
  final DateTime? completedAt;

  factory OnboardingStatus.fromJson(Map<String, dynamic> json) {
    return OnboardingStatus(
      isComplete: json['is_complete'] as bool? ?? false,
      userRole: json['user_role'] as String?,
      userName: json['user_name'] as String?,
      accountNickname: json['account_nickname'] as String?,
      interests: (json['interests'] as List<dynamic>?)?.cast<String>() ?? const [],
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
      'user_name': userName,
      'account_nickname': accountNickname,
      'interests': interests,
      'consent_given': consentGiven,
      'consent_version': consentVersion,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    isComplete,
    userRole,
    userName,
    accountNickname,
    interests,
    consentGiven,
    consentVersion,
    completedAt,
  ];
}