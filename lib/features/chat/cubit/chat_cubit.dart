// lib/features/chat/cubit/chat_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_repository/chat_repository.dart' as repo;
import 'package:uuid/uuid.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required repo.ChatRepository chatRepository,
  })  : _chatRepository = chatRepository,
        _uuid = const Uuid(),
        super(const ChatState());

  final repo.ChatRepository _chatRepository;
  final Uuid _uuid;
  String? _currentConversationId;

  Future<void> initialize() async {
    try {
      emit(state.copyWith(status: ChatStatus.loading));
      emit(state.copyWith(status: ChatStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        error: 'Failed to initialize chat',
      ));
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    try {
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

      final request = repo.ChatQueryRequest(
        query: content.trim(),
        conversationId: _currentConversationId,
      );

      final response = await _chatRepository.sendMessage(request);

      // Extract unique sources from all sentences
      final allSources = <SourceReference>{};
      for (final sentence in response.sentences) {
        if (sentence.sources != null && sentence.sources!.isNotEmpty) {
          for (final repoSource in sentence.sources!) {
            allSources.add(SourceReference(
              title: repoSource.title,
              url: repoSource.url,
              snippet: repoSource.snippet,
            ));
          }
        }
      }

      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        content: response.answer,
        isUser: false,
        timestamp: DateTime.now(),
        sentences: response.sentences
            .map((s) => SentenceWithConfidence(
          text: s.text,
          confidence: s.confidence,
          sources: s.sources
              ?.map((src) => SourceReference(
            title: src.title,
            url: src.url,
            snippet: src.snippet,
          ))
              .toList(),
        ))
            .toList(),
        sources: allSources.toList(),
        overallConfidence: response.sentences.isNotEmpty
            ? response.sentences.map((s) => s.confidence).reduce((a, b) => a + b) /
            response.sentences.length
            : null,
      );

      emit(state.copyWith(
        status: ChatStatus.success,
        messages: [...state.messages, aiMessage],
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

      final request = repo.ChatQueryRequest(
        query: content.trim(),
        conversationId: _currentConversationId,
        imageUrl: imageUrl,
      );

      final response = await _chatRepository.sendMessage(request);

      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        content: response.answer,
        isUser: false,
        timestamp: DateTime.now(),
        sentences: response.sentences
            .map((s) => SentenceWithConfidence(
          text: s.text,
          confidence: s.confidence,
          sources: s.sources
              ?.map((src) => SourceReference(
            title: src.title,
            url: src.url,
            snippet: src.snippet,
          ))
              .toList(),
        ))
            .toList(),
      );

      emit(state.copyWith(
        status: ChatStatus.success,
        messages: [...state.messages, aiMessage],
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

  Future<void> clearHistory() async {
    try {
      await _chatRepository.clearCache();
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

  void clearError() {
    emit(state.clearError());
  }
}