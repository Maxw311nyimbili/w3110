// lib/features/chat/cubit/chat_state.dart
// This file REPLACES the ChatMessage from chat_repository
// It adds dual-mode (quickAnswer + detailedAnswer) support

import 'package:equatable/equatable.dart';
import 'package:cap_project/features/medscanner/cubit/medscanner_state.dart' as scanner;
import 'package:chat_repository/chat_repository.dart' hide ChatMessage;

enum ChatStatus {
  initial,
  loading,
  success,
  error,
}

enum AttachmentType {
  image,
  document,
}

class PendingAttachment extends Equatable {
  final String path;
  final String name;
  final AttachmentType type;
  final String? mimeType;
  final int size;

  const PendingAttachment({
    required this.path,
    required this.name,
    required this.type,
    this.mimeType,
    required this.size,
  });

  @override
  List<Object?> get props => [path, name, type, mimeType, size];
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
    this.isRecording = false,
    this.recordingPath,
    this.amplitude = -160.0,
    this.loadingMessage,
    this.pendingAttachments = const [],
    this.medicineContext,
  });

  final ChatStatus status;
  final List<ChatMessage> messages;
  final String? error;
  final bool isTyping;
  final String? currentMessageId;
  final String? sessionId;
  final bool isRecording;
  final String? recordingPath;
  final double amplitude;
  final String? loadingMessage;
  final List<PendingAttachment> pendingAttachments;
  final scanner.ScanResult? medicineContext;

  bool get isLoading => status == ChatStatus.loading;
  bool get hasMessages => messages.isNotEmpty;

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    String? error,
    bool? isTyping,
    String? currentMessageId,
    String? sessionId,
    bool? isRecording,
    String? recordingPath,
    double? amplitude,
    String? loadingMessage,
    List<PendingAttachment>? pendingAttachments,
    scanner.ScanResult? medicineContext,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      error: error ?? this.error,
      isTyping: isTyping ?? this.isTyping,
      currentMessageId: currentMessageId ?? this.currentMessageId,
      sessionId: sessionId ?? this.sessionId,
      isRecording: isRecording ?? this.isRecording,
      recordingPath: recordingPath ?? this.recordingPath,
      amplitude: amplitude ?? this.amplitude,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      pendingAttachments: pendingAttachments ?? this.pendingAttachments,
      medicineContext: medicineContext ?? this.medicineContext,
    );
  }

  ChatState clearError() {
    return ChatState(
      status: status,
      messages: messages,
      error: null,
      isTyping: isTyping,
      currentMessageId: currentMessageId,
      sessionId: sessionId,
      isRecording: isRecording,
      recordingPath: recordingPath,
      amplitude: amplitude,
      loadingMessage: loadingMessage,
      pendingAttachments: pendingAttachments,
    );
  }

  ChatState clearAttachments() {
    return ChatState(
      status: status,
      messages: messages,
      error: error,
      isTyping: isTyping,
      currentMessageId: currentMessageId,
      sessionId: sessionId,
      isRecording: isRecording,
      recordingPath: recordingPath,
      amplitude: amplitude,
      loadingMessage: loadingMessage,
      pendingAttachments: const [],
      medicineContext: null,
    );
  }

  ChatState clearMedicineContext() {
    return copyWith(medicineContext: null);
  }

  ChatState resetLoadingMessage() {
    return ChatState(
      status: status,
      messages: messages,
      error: error,
      isTyping: isTyping,
      currentMessageId: currentMessageId,
      sessionId: sessionId,
      isRecording: isRecording,
      recordingPath: recordingPath,
      amplitude: amplitude,
      loadingMessage: null,
    );
  }

  @override
  List<Object?> get props => [status, messages, error, isTyping, currentMessageId, sessionId, isRecording, recordingPath, amplitude, loadingMessage, pendingAttachments];
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
    this.audioUrl,
    this.latencyMs,
    this.showingDetailedView = false,
    this.medicineResult,
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
  final String? audioUrl;
  final int? latencyMs;
  final bool showingDetailedView;
  final scanner.ScanResult? medicineResult;

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
    String? audioUrl,
    int? latencyMs,
    bool? showingDetailedView,
    scanner.ScanResult? medicineResult,
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
      audioUrl: audioUrl ?? this.audioUrl,
      latencyMs: latencyMs ?? this.latencyMs,
      showingDetailedView: showingDetailedView ?? this.showingDetailedView,
      medicineResult: medicineResult ?? this.medicineResult,
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
    audioUrl,
    latencyMs,
    showingDetailedView,
    medicineResult,
  ];
}

enum ConfidenceLevel {
  none,
  low,
  medium,
  high,
}