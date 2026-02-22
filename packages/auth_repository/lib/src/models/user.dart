// packages/auth_repository/lib/src/models/user.dart

import 'package:equatable/equatable.dart';

/// User model - represents authenticated user
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role,
    this.interests = const [],
    this.onboardingCompleted = false,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? role;
  final List<String> interests;
  final bool onboardingCompleted;

  /// Create user from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      role: json['role'] as String?,
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
    );
  }

  /// Convert user to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'role': role,
      'interests': interests,
      'onboarding_completed': onboardingCompleted,
    };
  }

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    role,
    interests,
    onboardingCompleted,
  ];
}
