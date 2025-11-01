// lib/features/chat/cubit/chat_state.dart

import 'package:equatable/equatable.dart';

enum ChatStatus {
  initial,
  loading,
  success,
  error,
}

/// Immutable chat state - manages conversation and UI state
class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.error,
    this.isTyping = false,
    this.currentMessageId,
  });

  final ChatStatus status;
  final List<ChatMessage> messages;
  final String? error;
  final bool isTyping;
  final String? currentMessageId;

  bool get isLoading => status == ChatStatus.loading;
  bool get hasMessages => messages.isNotEmpty;

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    String? error,
    bool? isTyping,
    String? currentMessageId,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      error: error,
      isTyping: isTyping ?? this.isTyping,
      currentMessageId: currentMessageId ?? this.currentMessageId,
    );
  }

  ChatState clearError() {
    return copyWith(error: null);
  }

  @override
  List<Object?> get props => [status, messages, error, isTyping, currentMessageId];
}

/// Chat message model
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
  final List<SentenceWithConfidence> sentences;
  final List<SourceReference> sources;
  final double? overallConfidence;
  final String? imageUrl;

  ConfidenceLevel get confidenceLevel {
    if (overallConfidence == null) return ConfidenceLevel.none;
    if (overallConfidence! >= 0.8) return ConfidenceLevel.high;
    if (overallConfidence! >= 0.5) return ConfidenceLevel.medium;
    return ConfidenceLevel.low;
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    List<SentenceWithConfidence>? sentences,
    List<SourceReference>? sources,
    double? overallConfidence,
    String? imageUrl,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      sentences: sentences ?? this.sentences,
      sources: sources ?? this.sources,
      overallConfidence: overallConfidence ?? this.overallConfidence,
      imageUrl: imageUrl ?? this.imageUrl,
    );
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

/// Sentence with confidence score
class SentenceWithConfidence extends Equatable {
  const SentenceWithConfidence({
    required this.text,
    required this.confidence,
    this.sources,
  });

  final String text;
  final double confidence;
  final List<SourceReference>? sources; // ADDED: Sources per sentence

  @override
  List<Object?> get props => [text, confidence, sources];
}

/// Source reference/citation
class SourceReference extends Equatable {
  const SourceReference({
    required this.title,
    required this.url,
    this.snippet,
  });

  final String title;
  final String url;
  final String? snippet;

  @override
  List<Object?> get props => [title, url, snippet];
}

/// Confidence level categories
enum ConfidenceLevel {
  none,
  low,
  medium,
  high,
}