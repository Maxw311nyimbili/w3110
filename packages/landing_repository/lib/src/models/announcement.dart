// packages/landing_repository/lib/src/models/announcement.dart

import 'package:equatable/equatable.dart';

/// Announcement model - app announcements/updates from backend
class Announcement extends Equatable {
  const Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.expiresAt,
    this.priority = 'normal',
  });

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String priority; // low, normal, high, critical

  /// Create from backend JSON
  /// Backend endpoint: GET /announcements
  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      priority: json['priority'] as String? ?? 'normal',
    );
  }

  @override
  List<Object?> get props => [id, title, message, createdAt, expiresAt, priority];
}