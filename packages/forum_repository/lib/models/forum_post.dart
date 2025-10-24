import 'package:equatable/equatable.dart';

class ForumPost extends Equatable {
  const ForumPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.authorPhotoUrl,
    this.commentCount = 0,
    this.likeCount = 0,
    this.isLiked = false,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int commentCount;
  final int likeCount;
  final bool isLiked;

  @override
  List<Object?> get props => [
    id,
    authorId,
    authorName,
    authorPhotoUrl,
    title,
    content,
    createdAt,
    updatedAt,
    commentCount,
    likeCount,
    isLiked,
  ];

  ForumPost copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorPhotoUrl,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? commentCount,
    int? likeCount,
    bool? isLiked,
  }) {
    return ForumPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'author_name': authorName,
      'author_photo_url': authorPhotoUrl,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'comment_count': commentCount,
      'like_count': likeCount,
      'is_liked': isLiked,
    };
  }

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      authorPhotoUrl: json['author_photo_url'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      commentCount: json['comment_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }
}