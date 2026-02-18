// packages/forum_repository/lib/src/models/forum_answer_line.dart

import 'package:equatable/equatable.dart';

/// Represents a single selectable line/sentence in a verified answer
class ForumAnswerLine extends Equatable {
  const ForumAnswerLine({
    required this.lineId,
    required this.answerId,
    required this.lineNumber,
    required this.text,
    required this.discussionTitle,
    this.commentCount = 0,
    this.citationRefs = const [],
  });

  /// Unique ID for this line (e.g., "line_ans_123_1")
  final String lineId;
  
  /// The parent answer ID
  final String answerId;
  
  /// 1-based index of the line in the paragraph
  final int lineNumber;
  
  /// The actual text content
  final String text;
  
  /// Auto-generated topic title (e.g., "Paracetamol Safety")
  final String discussionTitle;
  
  /// Number of approved comments on this line
  final int commentCount;
  
  /// Indices of citations relevant to this line
  final List<int> citationRefs;

  factory ForumAnswerLine.fromJson(Map<String, dynamic> json) {
    return ForumAnswerLine(
      lineId: json['line_id'] as String,
      answerId: (json['answer_id'] ?? json['post_id'] ?? '').toString(),
      lineNumber: json['line_number'] as int,
      text: json['text'] as String,
      discussionTitle: json['discussion_title'] as String,
      commentCount: json['comment_count'] as int? ?? 0,
      citationRefs: (json['citation_refs'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line_id': lineId,
      'answer_id': answerId,
      'line_number': lineNumber,
      'text': text,
      'discussion_title': discussionTitle,
      'comment_count': commentCount,
      'citation_refs': citationRefs,
    };
  }
  
  ForumAnswerLine copyWith({
    String? lineId,
    String? answerId,
    int? lineNumber,
    String? text,
    String? discussionTitle,
    int? commentCount,
    List<int>? citationRefs,
  }) {
    return ForumAnswerLine(
      lineId: lineId ?? this.lineId,
      answerId: answerId ?? this.answerId,
      lineNumber: lineNumber ?? this.lineNumber,
      text: text ?? this.text,
      discussionTitle: discussionTitle ?? this.discussionTitle,
      commentCount: commentCount ?? this.commentCount,
      citationRefs: citationRefs ?? this.citationRefs,
    );
  }

  @override
  List<Object?> get props => [
        lineId,
        answerId,
        lineNumber,
        text,
        discussionTitle,
        commentCount,
        citationRefs,
      ];
}
