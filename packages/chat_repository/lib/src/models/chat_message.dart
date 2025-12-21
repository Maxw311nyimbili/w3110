import 'package:equatable/equatable.dart';

// ============================================================================
// SOURCE REFERENCE MODEL (Define locally to avoid conflicts)
// ============================================================================

class SourceReference extends Equatable {
  final String domain;
  final String title;
  final String url;
  final String authority;
  final String? snippet;

  const SourceReference({
    required this.domain,
    required this.title,
    required this.url,
    required this.authority,
    this.snippet,
  });

  factory SourceReference.fromJson(Map<String, dynamic> json) {
    final sourceMap = json['source'] as Map<String, dynamic>?;

    return SourceReference(
      domain: (sourceMap?['domain'] ?? json['domain'] ?? 'Unknown').toString(),
      title: (sourceMap?['title'] ?? json['title'] ?? 'No title').toString(),
      url: (sourceMap?['url'] ?? json['url'] ?? '').toString(),
      authority: (sourceMap?['authority'] ?? json['authority'] ?? 'UNKNOWN').toString(),
      snippet: json['fragment_text'] is String ? json['fragment_text'] as String : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'domain': domain,
    'title': title,
    'url': url,
    'authority': authority,
    'snippet': snippet,
  };

  @override
  List<Object?> get props => [domain, title, url, authority, snippet];
}

// ============================================================================
// DUAL MODE ANSWER MODEL
// ============================================================================

class DualModeAnswer extends Equatable {
  final String quickAnswer;
  final String detailedAnswer;
  final int quickTokensUsed;
  final int detailedTokensUsed;

  const DualModeAnswer({
    required this.quickAnswer,
    required this.detailedAnswer,
    this.quickTokensUsed = 0,
    this.detailedTokensUsed = 0,
  });

  /// Parse from backend V1.2.1 response structure
  factory DualModeAnswer.fromValidatedAnswer(Map<String, dynamic> json) {
    try {
      // Extract quick answer from original_answer
      final quickAnswer = json['original_answer'] as String? ?? '';

      // Extract detailed answer from validated_sentences[0].rewritten
      String detailedAnswer = '';
      if (json['validated_sentences'] is List &&
          (json['validated_sentences'] as List).isNotEmpty) {
        final firstSentence =
        (json['validated_sentences'] as List)[0] as Map<String, dynamic>;
        detailedAnswer = firstSentence['rewritten'] as String? ?? '';
      }

      return DualModeAnswer(
        quickAnswer: quickAnswer.trim(),
        detailedAnswer: detailedAnswer.trim(),
        quickTokensUsed: 0,
        detailedTokensUsed: 0,
      );
    } catch (e) {
      return const DualModeAnswer(
        quickAnswer: '',
        detailedAnswer: '',
      );
    }
  }

  @override
  List<Object?> get props => [
    quickAnswer,
    detailedAnswer,
    quickTokensUsed,
    detailedTokensUsed,
  ];
}

// ============================================================================
// CHAT MESSAGE MODEL
// ============================================================================

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<SourceReference> sources;
  final bool isRefusal;
  final String? refusalReason;

  // ✅ Dual-mode support
  final bool? isDualMode;
  final DualModeAnswer? dualModeAnswer;
  final int? latencyMs;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.sources = const [],
    this.isRefusal = false,
    this.refusalReason,
    this.isDualMode,
    this.dualModeAnswer,
    this.latencyMs,
  });

  /// Parse from backend validation response
  /// ✅ AUTO-DETECTS dual-mode if both answers exist
  factory ChatMessage.fromValidationResponse({
    required Map<String, dynamic> response,
    required String sessionId,
  }) {
    try {
      final status = response['status'] as String? ?? 'error';

      // Handle out-of-scope
      if (status == 'out_of_scope') {
        return ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: response['message'] as String? ?? 'Out of scope',
          isUser: false,
          timestamp: DateTime.now(),
          isRefusal: true,
          refusalReason: 'This query is outside medical information scope',
        );
      }

      // Handle error
      if (status == 'error') {
        return ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: response['error'] as String? ?? 'Validation error',
          isUser: false,
          timestamp: DateTime.now(),
          isRefusal: true,
        );
      }

      // ✅ PARSE DUAL-MODE ANSWER
      final validatedAnswer =
          response['validated_answer'] as Map<String, dynamic>? ?? {};

      // Create DualModeAnswer from validated_answer
      final dualMode = DualModeAnswer.fromValidatedAnswer(validatedAnswer);

      // Extract sources from citations
      final sources = <SourceReference>[];
      if (validatedAnswer['validated_sentences'] is List &&
          (validatedAnswer['validated_sentences'] as List).isNotEmpty) {
        final firstSentence =
        (validatedAnswer['validated_sentences'] as List)[0]
        as Map<String, dynamic>;
        if (firstSentence['citations'] is List) {
          sources.addAll(
            (firstSentence['citations'] as List)
                .map((c) => SourceReference.fromJson(c as Map<String, dynamic>))
                .toList(),
          );
        }
      }

      // Determine primary content (quick answer if available, else detailed)
      final primaryContent = dualMode.quickAnswer.isNotEmpty
          ? dualMode.quickAnswer
          : dualMode.detailedAnswer;

      // ✅ ENABLE DUAL-MODE only if BOTH answers exist
      final isDualMode =
          dualMode.quickAnswer.isNotEmpty && dualMode.detailedAnswer.isNotEmpty;

      return ChatMessage(
        id: response['audit_id'] as String? ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        content: primaryContent,
        isUser: false,
        timestamp: DateTime.now(),
        sources: sources,
        isDualMode: isDualMode,
        dualModeAnswer: isDualMode ? dualMode : null,
        latencyMs: response['processing_time_ms'] as int? ?? 0,
      );
    } catch (e) {
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Failed to parse response: $e',
        isUser: false,
        timestamp: DateTime.now(),
        isRefusal: true,
      );
    }
  }

  /// Factory for user messages
  factory ChatMessage.user({
    required String content,
    required String sessionId,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'sources': sources.map((s) => s.toJson()).toList(),
      'isRefusal': isRefusal,
      'refusalReason': refusalReason,
      'isDualMode': isDualMode,
      'latencyMs': latencyMs,
    };

    // Include dual-mode data if present
    if (isDualMode == true && dualModeAnswer != null) {
      json['dualModeAnswer'] = {
        'quickAnswer': dualModeAnswer!.quickAnswer,
        'detailedAnswer': dualModeAnswer!.detailedAnswer,
      };
    }

    return json;
  }

  /// Create copy with modified fields
  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    List<SourceReference>? sources,
    bool? isRefusal,
    String? refusalReason,
    bool? isDualMode,
    DualModeAnswer? dualModeAnswer,
    int? latencyMs,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      sources: sources ?? this.sources,
      isRefusal: isRefusal ?? this.isRefusal,
      refusalReason: refusalReason ?? this.refusalReason,
      isDualMode: isDualMode ?? this.isDualMode,
      dualModeAnswer: dualModeAnswer ?? this.dualModeAnswer,
      latencyMs: latencyMs ?? this.latencyMs,
    );
  }

  @override
  List<Object?> get props => [
    id,
    content,
    isUser,
    timestamp,
    sources,
    isRefusal,
    refusalReason,
    isDualMode,
    dualModeAnswer,
    latencyMs,
  ];
}