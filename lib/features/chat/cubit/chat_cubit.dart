// lib/features/chat/cubit/chat_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_repository/chat_repository.dart' hide ChatMessage, SourceReference;
import 'package:uuid/uuid.dart';
import 'chat_state.dart';

/// Manages chat conversation state and AI interactions
class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required ChatRepository chatRepository,
  })  : _chatRepository = chatRepository,
        _uuid = const Uuid(),
        super(const ChatState());

  final ChatRepository _chatRepository;
  final Uuid _uuid;

  /// Initialize chat - load cached messages
  Future<void> initialize() async {
    try {
      emit(state.copyWith(status: ChatStatus.loading));

      // TODO: Uncomment when backend ready
      /*
      final cachedMessages = await _chatRepository.getCachedMessages();
      emit(state.copyWith(
        status: ChatStatus.success,
        messages: cachedMessages.map(_mapToStateMessage).toList(),
      ));
      */

      // TEMPORARY: Start with empty chat
      emit(state.copyWith(status: ChatStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        error: 'Failed to load chat history',
      ));
    }
  }

  /// Send a message and get AI response
  /// Backend endpoint: POST /chat/query
  /// Request: { "message": "user message", "conversation_id": "optional" }
  /// Response: { "response": "...", "sentences": [...], "sources": [...], "confidence": 0.85 }
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    try {
      // Add user message immediately
      final userMessage = ChatMessage(
        id: _uuid.v4(),
        content: content.trim(),
        isUser: true,
        timestamp: DateTime.now(),
      );

      emit(state.copyWith(
        messages: [...state.messages, userMessage],
        isTyping: true,
      ));

      // TODO: Uncomment when backend ready
      /*
      // Send to backend
      final request = ChatQueryRequest(
        message: content.trim(),
        conversationId: _currentConversationId,
      );

      final response = await _chatRepository.sendMessage(request);

      // Create AI message from response
      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        content: response.response,
        isUser: false,
        timestamp: DateTime.now(),
        sentences: response.sentences
            .map((s) => SentenceWithConfidence(
                  text: s.text,
                  confidence: s.confidence,
                ))
            .toList(),
        sources: response.sources
            .map((s) => SourceReference(
                  title: s.title,
                  url: s.url,
                  snippet: s.snippet,
                ))
            .toList(),
        overallConfidence: response.confidence,
      );

      // Cache messages locally
      await _chatRepository.cacheMessage(userMessage);
      await _chatRepository.cacheMessage(aiMessage);

      emit(state.copyWith(
        status: ChatStatus.success,
        messages: [...state.messages, aiMessage],
        isTyping: false,
      ));
      */

      // TEMPORARY: Mock AI response for development
      await Future.delayed(const Duration(seconds: 2));

      final mockAiMessage = ChatMessage(
        id: _uuid.v4(),
        content: _generateMockResponse(content),
        isUser: false,
        timestamp: DateTime.now(),
        sentences: [
          SentenceWithConfidence(
            text: 'This is a simulated response for development.',
            confidence: 0.95,
          ),
          SentenceWithConfidence(
            text: 'The backend will provide real medical information.',
            confidence: 0.88,
          ),
          SentenceWithConfidence(
            text: 'Always consult healthcare professionals for medical advice.',
            confidence: 0.92,
          ),
        ],
        sources: [
          const SourceReference(
            title: 'Mock Medical Source',
            url: 'https://example.com/medical-info',
            snippet: 'Example citation from medical database',
          ),
        ],
        overallConfidence: 0.90,
      );

      emit(state.copyWith(
        status: ChatStatus.success,
        messages: [...state.messages, mockAiMessage],
        isTyping: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        error: 'Failed to send message: ${e.toString()}',
        isTyping: false,
      ));
    }
  }

  /// Send message with image attachment (from MedScanner)
  Future<void> sendMessageWithImage(String content, String imageUrl) async {
    if (content.trim().isEmpty) return;

    try {
      final userMessage = ChatMessage(
        id: _uuid.v4(),
        content: content.trim(),
        isUser: true,
        timestamp: DateTime.now(),
        imageUrl: imageUrl,
      );

      emit(state.copyWith(
        messages: [...state.messages, userMessage],
        isTyping: true,
      ));

      // TODO: Backend integration for image analysis
      // Similar to sendMessage but includes image data

      await Future.delayed(const Duration(seconds: 3));

      final mockAiMessage = ChatMessage(
        id: _uuid.v4(),
        content: 'I\'ve analyzed the image. This appears to be a medication label. '
            'Here\'s what I found: [Mock analysis pending backend integration]',
        isUser: false,
        timestamp: DateTime.now(),
        overallConfidence: 0.75,
      );

      emit(state.copyWith(
        status: ChatStatus.success,
        messages: [...state.messages, mockAiMessage],
        isTyping: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        error: 'Failed to process image: ${e.toString()}',
        isTyping: false,
      ));
    }
  }

  /// Clear conversation history
  Future<void> clearHistory() async {
    try {
      // TODO: Uncomment when backend ready
      // await _chatRepository.clearCache();

      emit(state.copyWith(
        status: ChatStatus.success,
        messages: [],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        error: 'Failed to clear history',
      ));
    }
  }

  /// Clear error state
  void clearError() {
    emit(state.clearError());
  }

  /// Mock response generator for development
  String _generateMockResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('pregnancy') ||
        lowerMessage.contains('pregnant')) {
      return 'During pregnancy, it\'s important to maintain regular prenatal care. '
          'Make sure to take prenatal vitamins with folic acid and stay hydrated. '
          'Always consult your healthcare provider before taking any new medications.';
    }

    if (lowerMessage.contains('medication') ||
        lowerMessage.contains('medicine')) {
      return 'When considering any medication, it\'s crucial to consult with your healthcare provider. '
          'They can assess your specific situation and medical history. '
          'Never start or stop medications without professional guidance.';
    }

    if (lowerMessage.contains('pain') || lowerMessage.contains('hurt')) {
      return 'Pain can have many causes and should be evaluated by a healthcare professional. '
          'Keep track of when the pain occurs, its intensity, and any triggers. '
          'If pain is severe or persistent, seek medical attention promptly.';
    }

    return 'Thank you for your question. For personalized medical advice, please consult with a qualified healthcare provider. '
        'This AI assistant provides general health information but cannot replace professional medical consultation.';
  }

  /// Helper to map repository message to state message
  ChatMessage _mapToStateMessage(dynamic repoMessage) {
    // TODO: Implement proper mapping when repository models are finalized
    return ChatMessage(
      id: repoMessage.id as String,
      content: repoMessage.content as String,
      isUser: repoMessage.isUser as bool,
      timestamp: repoMessage.timestamp as DateTime,
    );


  }
}