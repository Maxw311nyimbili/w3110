// packages/chat_repository/lib/src/models/sentence_confidence.dart

import 'package:equatable/equatable.dart';
import 'source_reference.dart';

class SentenceConfidence extends Equatable {
  const SentenceConfidence({
    required this.text,
    required this.confidence,
    this.sources,
  });

  final String text;
  final double confidence;
  final List<SourceReference>? sources;

  factory SentenceConfidence.fromJson(Map<String, dynamic> json) {
    return SentenceConfidence(
      text: json['text'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      sources: (json['sources'] as List<dynamic>?)
          ?.map((e) => SourceReference.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'confidence': confidence,
      if (sources != null) 'sources': sources!.map((s) => s.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [text, confidence, sources];
}
