// lib/features/chat/cubit/chat_state.dart
// Business logic state ONLY - UI state stays in StatefulWidget

import 'package:equatable/equatable.dart';
import 'package:cap_project/features/medscanner/cubit/medscanner_state.dart'
    as scanner;
import 'package:chat_repository/chat_repository.dart' hide ChatMessage, SourceReference;

enum ChatStatus {
  initial,
  loading,
  success,
  error,
}

enum ConfidenceLevel {
  none,
  low,
  medium,
  high,
}

enum AttachmentType {
  image,
  document,
}

enum VoiceLanguage {
  english('en', 'English'),
  twi('tw', 'Twi');

  final String code;
  final String label;
  const VoiceLanguage(this.code, this.label);
}

class Attachment extends Equatable {
  final String path;
  final String name;
  final AttachmentType type;
  final int size;

  const Attachment({
    required this.path,
    required this.name,
    required this.type,
    required this.size,
  });

  @override
  List<Object?> get props => [path, name, type, size];
}

typedef PendingAttachment = Attachment;

/// SourceReference model (for citations)
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

/// ChatMessage with dual-mode support (business logic only)
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
    this.medicineResult,
    this.showingDetailedView = false,
  });

  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<SourceReference> sources;
  final bool isRefusal;
  final String? refusalReason;
  final bool isDualMode;
  final String? quickAnswer;
  final String? detailedAnswer;
  final String? audioUrl;
  final int? latencyMs;
  final scanner.ScanResult? medicineResult;
  final bool showingDetailedView;

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
    scanner.ScanResult? medicineResult,
    bool? showingDetailedView,
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
      medicineResult: medicineResult ?? this.medicineResult,
      showingDetailedView: showingDetailedView ?? this.showingDetailedView,
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
    medicineResult,
    showingDetailedView,
  ];
}

/// Helper model for the history drawer
class HistorySession extends Equatable {
  const HistorySession({
    required this.sessionId,
    required this.firstMessage,
    required this.timestamp,
  });

  final String sessionId;
  final String firstMessage;
  final DateTime timestamp;

  String get dateLabel {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  @override
  List<Object?> get props => [sessionId, firstMessage, timestamp];
}

/// Business logic state ONLY
/// UI state (isRecording, amplitude, audioMode, etc) stays in StatefulWidget
class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.error,
    this.isTyping = false,
    this.currentMessageId,
    this.sessionId,
    this.medicineContext,
    this.isRecording = false,
    this.amplitude = 0.0,
    this.pendingAttachments = const [],
    this.loadingMessage,
    this.dynamicGreeting,
    this.selectedLanguage = VoiceLanguage.english,
    this.isLoadingHistory = false,
    this.historySessions = const [],
  });

  final ChatStatus status;
  final List<ChatMessage> messages;
  final String? error;
  final bool isTyping;
  final String? currentMessageId;
  final String? sessionId;
  final scanner.ScanResult? medicineContext;
  final bool isRecording;
  final double amplitude;
  final List<Attachment> pendingAttachments;
  final String? loadingMessage;
  final String? dynamicGreeting;
  final VoiceLanguage selectedLanguage;
  final bool isLoadingHistory;
  final List<HistorySession> historySessions;

  bool get isLoading => status == ChatStatus.loading;
  bool get hasMessages => messages.isNotEmpty;

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    String? error,
    bool? isTyping,
    String? currentMessageId,
    String? sessionId,
    scanner.ScanResult? medicineContext,
    bool? isRecording,
    double? amplitude,
    List<Attachment>? pendingAttachments,
    String? loadingMessage,
    String? dynamicGreeting,
    VoiceLanguage? selectedLanguage,
    bool? isLoadingHistory,
    List<HistorySession>? historySessions,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      error: error,
      isTyping: isTyping ?? this.isTyping,
      currentMessageId: currentMessageId ?? this.currentMessageId,
      sessionId: sessionId ?? this.sessionId,
      medicineContext: medicineContext ?? this.medicineContext,
      isRecording: isRecording ?? this.isRecording,
      amplitude: amplitude ?? this.amplitude,
      pendingAttachments: pendingAttachments ?? this.pendingAttachments,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      dynamicGreeting: dynamicGreeting ?? this.dynamicGreeting,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      historySessions: historySessions ?? this.historySessions,
    );
  }

  ChatState clearError() {
    return copyWith(error: null);
  }

  ChatState clearMedicineContext() {
    return copyWith(medicineContext: null);
  }

  ChatState resetLoadingMessage() {
    return copyWith(loadingMessage: null);
  }

  ChatState updateLoadingMessage(String message) {
    return copyWith(loadingMessage: message);
  }

  @override
  List<Object?> get props => [
    status,
    messages,
    error,
    isTyping,
    currentMessageId,
    sessionId,
    medicineContext,
    isRecording,
    amplitude,
    pendingAttachments,
    loadingMessage,
    dynamicGreeting,
    selectedLanguage,
    isLoadingHistory,
    historySessions,
  ];
}
