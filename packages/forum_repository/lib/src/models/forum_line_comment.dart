// packages/forum_repository/lib/src/models/forum_line_comment.dart

import 'package:equatable/equatable.dart';
import 'sync_status.dart';
import '../database/forum_database.dart';

enum CommentRole {
  clinician,
  mother,
  community,
  supportPartner,
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
    required this.localId,
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
    this.isDeleted = false,
    this.version = 1,
  });

  final String id;
  final String localId;
  final String lineId;
  final String authorId;
  final String authorName;
  final CommentRole authorRole;
  final CommentType commentType;
  final String text;
  final DateTime createdAt;

  final String? authorProfession;
  final String? authorAvatarUrl;
  final String? parentCommentId;

  final int likeCount;
  final bool isLiked;
  final SyncStatus syncStatus;
  final bool isDeleted;
  final int version;

  // Helpers for UI badges
  String get roleLabel {
    switch (authorRole) {
      case CommentRole.clinician:
        return 'Clinician';
      case CommentRole.mother:
        return 'Mother';
      case CommentRole.community:
        return 'Community';
      case CommentRole.supportPartner:
        return 'Support Partner';
      default:
        return '';
    }
  }

  String get typeLabel {
    switch (commentType) {
      case CommentType.clinical:
        return 'Clinical Interpretation';
      case CommentType.evidence:
        return 'Supporting Evidence';
      case CommentType.experience:
        return 'Lived Experience';
      case CommentType.concern:
        return 'Concern';
      default:
        return 'Comment';
    }
  }

  factory ForumLineComment.fromJson(Map<String, dynamic> json) {
    return ForumLineComment(
      id: json['comment_id']?.toString() ?? '',
      localId:
          json['local_id']?.toString() ??
          (json['comment_id']?.toString() ?? ''),
      lineId: (json['line_id'] ?? '').toString(),
      authorId: (json['author_id'] ?? '').toString(),
      authorName: json['author_name']?.toString() ?? 'Unknown',
      authorRole: _parseRole(json['author_role'] as String?),
      commentType: _parseType(json['comment_type'] as String?),
      text: json['text']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      authorProfession: json['author_profession'] as String?,
      authorAvatarUrl: json['author_avatar_url'] as String?,
      parentCommentId: json['parent_comment_id']?.toString(),
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      syncStatus: SyncStatus.synced,
      isDeleted: json['is_deleted'] as bool? ?? false,
      version: json['version'] as int? ?? 1,
    );
  }

  static CommentRole _parseRole(String? role) {
    final r = role?.toLowerCase() ?? '';
    if (r == 'clinician') return CommentRole.clinician;
    if (r == 'mother') return CommentRole.mother;
    if (r == 'support_partner' || r == 'supportpartner')
      return CommentRole.supportPartner;
    if (r.contains('community')) return CommentRole.community;
    return CommentRole.unknown;
  }

  static CommentType _parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'clinical':
        return CommentType.clinical;
      case 'evidence':
        return CommentType.evidence;
      case 'experience':
        return CommentType.experience;
      case 'concern':
        return CommentType.concern;
      default:
        return CommentType.general;
    }
  }

  ForumLineComment copyWith({
    String? id,
    String? localId,
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
    bool? isDeleted,
    int? version,
  }) {
    return ForumLineComment(
      id: id ?? this.id,
      localId: localId ?? this.localId,
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
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
    );
  }

  /// Create from Drift database row
  factory ForumLineComment.fromDatabase(ForumLineCommentData d) {
    return ForumLineComment(
      id: d.serverId,
      localId: d.localId,
      lineId: d.lineId,
      authorId: d.authorId,
      authorName: d.authorName,
      authorRole: _parseRole(d.authorRole),
      commentType: _parseType(d.commentType),
      text: d.content,
      createdAt: d.createdAt,
      parentCommentId: d.parentCommentId,
      syncStatus: _parseSyncStatus(d.syncStatus),
      isDeleted: d.isDeleted,
      version: d.version,
    );
  }

  static SyncStatus _parseSyncStatus(String status) {
    switch (status) {
      case 'pending':
        return SyncStatus.pending;
      case 'syncing':
        return SyncStatus.syncing;
      case 'error':
        return SyncStatus.error;
      default:
        return SyncStatus.synced;
    }
  }

  @override
  List<Object?> get props => [
    id,
    localId,
    lineId,
    authorId,
    authorName,
    authorRole,
    commentType,
    text,
    createdAt,
    authorProfession,
    parentCommentId,
    likeCount,
    isLiked,
    syncStatus,
    isDeleted,
    version,
  ];
}
