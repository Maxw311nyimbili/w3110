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
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? role;

  /// Create user from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      role: json['role'] as String?,
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
    };
  }

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, role];
}