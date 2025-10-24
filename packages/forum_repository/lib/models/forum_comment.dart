import 'package:equatable/equatable.dart';

class ForumComment extends Equatable {
  const ForumComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.authorPhotoUrl,
    this.likeCount = 0,
    this.isLiked = false,
  });

  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likeCount;
  final bool isLiked;

  @override
  List<Object?> get props => [
    id,
    postId,
    authorId,
    authorName,
    authorPhotoUrl,
    content,
    createdAt,
    updatedAt,
    likeCount,
    isLiked,
  ];

  ForumComment copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? authorName,
    String? authorPhotoUrl,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    bool? isLiked,
  }) {
    return ForumComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'author_id': authorId,
      'author_name': authorName,
      'author_photo_url': authorPhotoUrl,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'like_count': likeCount,
      'is_liked': isLiked,
    };
  }

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    return ForumComment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      authorPhotoUrl: json['author_photo_url'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }
}