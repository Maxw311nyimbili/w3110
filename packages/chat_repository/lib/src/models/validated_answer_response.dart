// packages/chat_repository/lib/src/models/validated_answer_response.dart

import 'package:equatable/equatable.dart';

/// Top-level response from /api/chat/validate endpoint
class ValidatedAnswerResponse extends Equatable {
  const ValidatedAnswerResponse({
    required this.status,
    this.validatedAnswer,
    this.refusalResponse,
    required this.processingTimeMs,
    required this.sessionId,
    this.message,
    this.suggestion,
    this.queryCategory,
    this.confidence,
  });

  final String status; // "success", "refusal", or "out_of_scope"
  final ValidatedAnswer? validatedAnswer;
  final RefusalResponse? refusalResponse;
  final int processingTimeMs;
  final String sessionId;
  final String? message; // For out_of_scope: why the query is out of scope
  final String? suggestion; // For out_of_scope: suggested medical query example
  final String? queryCategory; // For out_of_scope: category of the query
  final double? confidence; // For out_of_scope: confidence in the determination

  /// True if validation was successful
  bool get isSuccess => status == 'success';

  /// True if validation was refused
  bool get isRefusal => status == 'refusal';

  /// True if query is out of scope
  bool get isOutOfScope => status == 'out_of_scope';

  factory ValidatedAnswerResponse.fromJson(Map<String, dynamic> json) {
    return ValidatedAnswerResponse(
      status: json['status'] as String? ?? 'unknown',
      validatedAnswer: json['validated_answer'] != null
          ? ValidatedAnswer.fromJson(
          json['validated_answer'] as Map<String, dynamic>)
          : null,
      refusalResponse: json['refusal_response'] != null
          ? RefusalResponse.fromJson(
          json['refusal_response'] as Map<String, dynamic>)
          : null,
      processingTimeMs: json['processing_time_ms'] as int? ?? 0,
      sessionId: json['session_id'] as String? ?? '',
      message: json['message'] as String?,
      suggestion: json['suggestion'] as String?,
      queryCategory: json['query_category'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    status,
    validatedAnswer,
    refusalResponse,
    processingTimeMs,
    sessionId,
    message,
    suggestion,
    queryCategory,
    confidence,
  ];
}

/// Successful validation response
class ValidatedAnswer extends Equatable {
  const ValidatedAnswer({
    required this.originalAnswer,
    required this.validatedSentences,
    required this.overallConfidence,
    required this.disclaimer,
    required this.auditId,
    required this.processingTimeMs,
  });

  final String originalAnswer;
  final List<SentenceValidation> validatedSentences;
  final double overallConfidence;
  final String disclaimer;
  final String auditId;
  final int processingTimeMs;

  factory ValidatedAnswer.fromJson(Map<String, dynamic> json) {
    return ValidatedAnswer(
      originalAnswer: json['original_answer'] as String? ?? '',
      validatedSentences: (json['validated_sentences'] as List?)
          ?.map((s) =>
          SentenceValidation.fromJson(s as Map<String, dynamic>))
          .toList() ??
          [],
      overallConfidence: (json['overall_confidence'] as num?)?.toDouble() ?? 0.0,
      disclaimer: json['disclaimer'] as String? ?? '',
      auditId: json['audit_id'] as String? ?? '',
      processingTimeMs: json['processing_time_ms'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    originalAnswer,
    validatedSentences,
    overallConfidence,
    disclaimer,
    auditId,
    processingTimeMs,
  ];
}

/// Individual sentence validation
class SentenceValidation extends Equatable {
  const SentenceValidation({
    required this.sentence,
    required this.rewritten,
    required this.credibility,
    required this.confidenceLabel,
    required this.status,
    required this.citations,
    this.warning,
  });

  final String sentence; // Original sentence
  final String rewritten; // Rewritten with citations [1][2][3]
  final double credibility; // 0.0-1.0
  final String confidenceLabel; // "HIGH", "MEDIUM", "LOW"
  final String status; // "VALIDATED", "UNCERTAIN", "REJECTED"
  final List<Citation> citations;
  final String? warning;

  factory SentenceValidation.fromJson(Map<String, dynamic> json) {
    return SentenceValidation(
      sentence: json['sentence'] as String? ?? '',
      rewritten: json['rewritten'] as String? ?? '',
      credibility: (json['credibility'] as num?)?.toDouble() ?? 0.0,
      confidenceLabel: json['confidence_label'] as String? ?? 'LOW',
      status: json['status'] as String? ?? 'UNKNOWN',
      citations: (json['citations'] as List?)
          ?.map((c) => Citation.fromJson(c as Map<String, dynamic>))
          .toList() ??
          [],
      warning: json['warning'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    sentence,
    rewritten,
    credibility,
    confidenceLabel,
    status,
    citations,
    warning,
  ];
}

/// Citation with source
class Citation extends Equatable {
  const Citation({
    required this.refId,
    required this.fragmentText,
    required this.source,
  });

  final int refId; // [1], [2], [3]...
  final String fragmentText; // The actual text from the source
  final CitationSource source;

  factory Citation.fromJson(Map<String, dynamic> json) {
    return Citation(
      refId: json['ref_id'] as int? ?? 0,
      fragmentText: json['fragment_text'] as String? ?? '',
      source: CitationSource.fromJson(
          json['source'] as Map<String, dynamic>? ?? {}),
    );
  }

  @override
  List<Object?> get props => [refId, fragmentText, source];
}

/// Citation source details
class CitationSource extends Equatable {
  const CitationSource({
    required this.domain,
    required this.title,
    required this.url,
    required this.authority,
  });

  final String domain; // "mayoclinic.org"
  final String title; // "Fever Treatment"
  final String url; // Full URL
  final String authority; // "HIGH", "MEDIUM", "LOW"

  factory CitationSource.fromJson(Map<String, dynamic> json) {
    return CitationSource(
      domain: json['domain'] as String? ?? '',
      title: json['title'] as String? ?? '',
      url: json['url'] as String? ?? '',
      authority: json['authority'] as String? ?? 'LOW',
    );
  }

  @override
  List<Object?> get props => [domain, title, url, authority];
}

/// Refusal response when validation fails
class RefusalResponse extends Equatable {
  const RefusalResponse({
    required this.status,
    required this.message,
    required this.reason,
    required this.auditId,
    required this.suggestion,
  });

  final String status; // "HIGH_HALLUCINATION_RISK", etc.
  final String message; // User-friendly message
  final String reason; // Why it was refused
  final String auditId; // For tracking
  final String suggestion; // What to do instead

  factory RefusalResponse.fromJson(Map<String, dynamic> json) {
    return RefusalResponse(
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      auditId: json['audit_id'] as String? ?? '',
      suggestion: json['suggestion'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [status, message, reason, auditId, suggestion];
}