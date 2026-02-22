// packages/chat_repository/lib/src/models/chat_response.dart

import 'package:equatable/equatable.dart';
import 'sentence_confidence.dart';

class ChatResponse extends Equatable {
  const ChatResponse({
    required this.answer,
    required this.sentences,
  });

  final String answer;
  final List<SentenceConfidence> sentences;

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      answer: json['answer'] as String,
      sentences:
          (json['sentences'] as List<dynamic>?)
              ?.map(
                (e) => SentenceConfidence.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  @override
  List<Object> get props => [answer, sentences];
}
