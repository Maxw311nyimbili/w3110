// lib/features/chat/cubit/chat_state.dart
// This file REPLACES the ChatMessage from chat_repository
// It adds dual-mode (quickAnswer + detailedAnswer) support

import 'package:equatable/equatable.dart';
import 'package:chat_repository/chat_repository.dart' hide ChatMessage;

enum ChatStatus {
  initial,
  loading,
  success,
  error,
}

/// ✅ SourceReference model (for dual-mode)
class SourceReference extends Equatable {
  final String title;
  final String url;
  final String? domain;
  final String? authority;
  final String? snippet;

  const SourceReference({
    required this.title,
    required this.url,
    this.domain,
    this.authority,
    this.snippet,
  });

  @override
  List<Object?> get props => [title, url, domain, authority, snippet];
}

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.error,
    this.isTyping = false,
    this.currentMessageId,
    this.sessionId,
  });

  final ChatStatus status;
  final List<ChatMessage> messages;
  final String? error;
  final bool isTyping;
  final String? currentMessageId;
  final String? sessionId;

  bool get isLoading => status == ChatStatus.loading;
  bool get hasMessages => messages.isNotEmpty;

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    String? error,
    bool? isTyping,
    String? currentMessageId,
    String? sessionId,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      error: error,
      isTyping: isTyping ?? this.isTyping,
      currentMessageId: currentMessageId ?? this.currentMessageId,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  ChatState clearError() {
    return copyWith(error: null);
  }

  @override
  List<Object?> get props => [status, messages, error, isTyping, currentMessageId, sessionId];
}

/// ✅ NEW ChatMessage with dual-mode support
/// Replaces chat_repository.ChatMessage
class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.sources = const [],
    this.isRefusal = false,
    this.refusalReason,
    this.isDualMode = false,
    this.quickAnswer,
    this.detailedAnswer,
    this.latencyMs,
  });

  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<SourceReference> sources;
  final bool isRefusal;
  final String? refusalReason;

  // ✅ NEW: Dual-mode fields
  final bool isDualMode;
  final String? quickAnswer;
  final String? detailedAnswer;
  final int? latencyMs;

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    List<SourceReference>? sources,
    bool? isRefusal,
    String? refusalReason,
    bool? isDualMode,
    String? quickAnswer,
    String? detailedAnswer,
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
      quickAnswer: quickAnswer ?? this.quickAnswer,
      detailedAnswer: detailedAnswer ?? this.detailedAnswer,
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
    quickAnswer,
    detailedAnswer,
    latencyMs,
  ];
}

enum ConfidenceLevel {
  none,
  low,
  medium,
  high,
}