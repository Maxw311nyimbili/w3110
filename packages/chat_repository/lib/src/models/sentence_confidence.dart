// packages/chat_repository/lib/src/models/sentence_confidence.dart

import 'package:equatable/equatable.dart';

/// Sentence with confidence score from AI response
class SentenceConfidence extends Equatable {
  const SentenceConfidence({
    required this.text,
    required this.confidence,
  });

  final String text;
  final double confidence; // 0.0 - 1.0

  factory SentenceConfidence.fromJson(Map<String, dynamic> json) {
    return SentenceConfidence(
      text: json['text'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'confidence': confidence,
    };
  }

  @override
  List<Object?> get props => [text, confidence];
}