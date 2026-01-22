// packages/forum_repository/lib/src/models/forum_line_comment.dart

import 'package:equatable/equatable.dart';
import 'sync_status.dart';

enum CommentRole {
  clinician,
  mother,
  community,
  unknown,
}

enum CommentType {
  clinical,
  evidence,
  experience,
  concern,
  general,
}

/// Represents a comment anchored to a specific line
class ForumLineComment extends Equatable {
  const ForumLineComment({
    required this.id,
    required this.lineId,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.commentType,
    required this.text,
    required this.createdAt,
    this.authorProfession,
    this.authorAvatarUrl,
    this.parentCommentId,
    this.likeCount = 0,
    this.isLiked = false,
    this.syncStatus = SyncStatus.synced,
  });

  final String id;
  final String lineId;
  final String authorId;
  final String authorName;
  final CommentRole authorRole;
  final CommentType commentType;
  final String text;
  final DateTime createdAt;
  
  final String? authorProfession; // e.g., "Midwife", "OB-GYN"
  final String? authorAvatarUrl;
  final String? parentCommentId; // For 1-level nesting
  
  final int likeCount;
  final bool isLiked;
  final SyncStatus syncStatus;

  // Helpers for UI badges
  String get roleLabel {
    switch (authorRole) {
      case CommentRole.clinician: return 'Clinician';
      case CommentRole.mother: return 'Mother';
      case CommentRole.community: return 'Community';
      default: return '';
    }
  }

  String get typeLabel {
    switch (commentType) {
      case CommentType.clinical: return 'Clinical Interpretation';
      case CommentType.evidence: return 'Supporting Evidence';
      case CommentType.experience: return 'Lived Experience';
      case CommentType.concern: return 'Concern';
      default: return 'Comment';
    }
  }

  factory ForumLineComment.fromJson(Map<String, dynamic> json) {
    return ForumLineComment(
      id: json['comment_id'] as String,
      lineId: json['line_id'] as String,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      authorRole: _parseRole(json['author_role'] as String?),
      commentType: _parseType(json['comment_type'] as String?),
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorProfession: json['author_profession'] as String?,
      authorAvatarUrl: json['author_avatar_url'] as String?,
      parentCommentId: json['parent_comment_id'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      syncStatus: SyncStatus.synced,
    );
  }

  static CommentRole _parseRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'clinician': return CommentRole.clinician;
      case 'mother': return CommentRole.mother;
      case 'community': return CommentRole.community;
      default: return CommentRole.community;
    }
  }
  
  static CommentType _parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'clinical': return CommentType.clinical;
      case 'evidence': return CommentType.evidence;
      case 'experience': return CommentType.experience;
      case 'concern': return CommentType.concern;
      default: return CommentType.general;
    }
  }

  ForumLineComment copyWith({
    String? id,
    String? lineId,
    String? authorId,
    String? authorName,
    CommentRole? authorRole,
    CommentType? commentType,
    String? text,
    DateTime? createdAt,
    String? authorProfession,
    String? authorAvatarUrl,
    String? parentCommentId,
    int? likeCount,
    bool? isLiked,
    SyncStatus? syncStatus,
  }) {
    return ForumLineComment(
      id: id ?? this.id,
      lineId: lineId ?? this.lineId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      commentType: commentType ?? this.commentType,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      authorProfession: authorProfession ?? this.authorProfession,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [
    id, lineId, authorId, authorName, authorRole, commentType, 
    text, createdAt, authorProfession, parentCommentId, 
    likeCount, isLiked, syncStatus
  ];
}
