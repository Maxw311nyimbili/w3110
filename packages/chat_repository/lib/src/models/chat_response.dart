// packages/chat_repository/lib/src/models/chat_response.dart

import 'package:equatable/equatable.dart';
import 'sentence_confidence.dart';
import 'source_reference.dart';

/// Response from backend chat query
class ChatResponse extends Equatable {
  const ChatResponse({
    required this.response,
    required this.sentences,
    required this.sources,
    required this.confidence,
    this.conversationId,
  });

  final String response; // Full AI response text
  final List<SentenceConfidence> sentences; // Per-sentence confidence
  final List<SourceReference> sources; // Citations
  final double confidence; // Overall confidence (0.0 - 1.0)
  final String? conversationId; // For maintaining context

  /// Parse from backend JSON
  /// Expected response from POST /chat/query:
  /// {
  ///   "response": "Ibuprofen is generally not recommended...",
  ///   "sentences": [
  ///     { "text": "Ibuprofen is generally not recommended...", "confidence": 0.92 },
  ///     { "text": "Consult your healthcare provider...", "confidence": 0.95 }
  ///   ],
  ///   "sources": [
  ///     { "title": "Mayo Clinic", "url": "https://...", "snippet": "..." }
  ///   ],
  ///   "confidence": 0.93,
  ///   "conversation_id": "uuid-here"
  /// }
  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      response: json['response'] as String,
      sentences: (json['sentences'] as List<dynamic>)
          .map((e) => SentenceConfidence.fromJson(e as Map<String, dynamic>))
          .toList(),
      sources: (json['sources'] as List<dynamic>)
          .map((e) => SourceReference.fromJson(e as Map<String, dynamic>))
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
      conversationId: json['conversation_id'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    response,
    sentences,
    sources,
    confidence,
    conversationId,
  ];
}