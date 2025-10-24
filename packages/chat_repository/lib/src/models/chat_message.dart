// packages/chat_repository/lib/src/models/chat_message.dart

import 'package:equatable/equatable.dart';
import 'sentence_confidence.dart';
import 'source_reference.dart';

/// Chat message model - for local cache
class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.sentences = const [],
    this.sources = const [],
    this.overallConfidence,
    this.imageUrl,
  });

  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<SentenceConfidence> sentences;
  final List<SourceReference> sources;
  final double? overallConfidence;
  final String? imageUrl;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['is_user'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      sentences: (json['sentences'] as List<dynamic>?)
          ?.map((e) => SentenceConfidence.fromJson(e as Map<String, dynamic>))
          .toList() ??
          const [],
      sources: (json['sources'] as List<dynamic>?)
          ?.map((e) => SourceReference.fromJson(e as Map<String, dynamic>))
          .toList() ??
          const [],
      overallConfidence: json['overall_confidence'] as double?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'is_user': isUser,
      'timestamp': timestamp.toIso8601String(),
      'sentences': sentences.map((e) => e.toJson()).toList(),
      'sources': sources.map((e) => e.toJson()).toList(),
      'overall_confidence': overallConfidence,
      'image_url': imageUrl,
    };
  }

  @override
  List<Object?> get props => [
    id,
    content,
    isUser,
    timestamp,
    sentences,
    sources,
    overallConfidence,
    imageUrl,
  ];
}