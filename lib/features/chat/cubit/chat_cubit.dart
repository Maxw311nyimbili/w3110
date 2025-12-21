// lib/features/chat/cubit/chat_cubit.dart

import 'package:cap_project/features/chat/cubit/chat_state.dart';
import 'package:chat_repository/chat_repository.dart' as repo;
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required repo.ChatRepository chatRepository,
  })  : _chatRepository = chatRepository,
        _uuid = const Uuid(),
        _dio = Dio(),
        super(const ChatState());

  final repo.ChatRepository _chatRepository;
  final Uuid _uuid;
  final Dio _dio;

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

  // Main send message method - use this
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );

    emit(state.copyWith(
      messages: [...state.messages, userMessage],
      status: ChatStatus.loading,
      isTyping: true,
    ));

    try {
      final response = await _dio.post(
        'http://172.26.80.1:8000/chat/validate',
        data: {
          'query': content.trim(),
          'session_id': state.sessionId ??
              DateTime.now().millisecondsSinceEpoch.toString(),
        },
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 120),
        ),
      );

      final responseData = response.data as Map<String, dynamic>;
      final status = responseData['status'] as String? ?? 'error';

      // Handle out-of-scope
      if (status == 'out_of_scope') {
        final aiMessage = ChatMessage(
          id: responseData['audit_id'] as String? ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          content: responseData['message'] as String? ??
              'This query is outside the scope of medical information.',
          isUser: false,
          timestamp: DateTime.now(),
          isRefusal: true,
          refusalReason: 'Out of scope',
        );
        emit(state.copyWith(
          messages: [...state.messages, aiMessage],
          status: ChatStatus.success,
          isTyping: false,
        ));
        return;
      }

      // Handle error
      if (status == 'error') {
        final aiMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: responseData['error'] as String? ?? 'An error occurred',
          isUser: false,
          timestamp: DateTime.now(),
          isRefusal: true,
          refusalReason: 'Backend error',
        );
        emit(state.copyWith(
          messages: [...state.messages, aiMessage],
          status: ChatStatus.error,
          error: responseData['error'] as String? ?? 'Unknown error',
          isTyping: false,
        ));
        return;
      }

      // Extract validated answer
      final validatedAnswer =
          responseData['validated_answer'] as Map<String, dynamic>? ?? {};

      // Get quick answer (from original_answer)
      final quickAnswer = validatedAnswer['original_answer'] as String? ?? '';

      // Get detailed answer (from first sentence's rewritten field)
      String detailedAnswer = '';
      List<SourceReference> sources = [];

      if (validatedAnswer['validated_sentences'] is List &&
          (validatedAnswer['validated_sentences'] as List).isNotEmpty) {
        final firstSentence = (validatedAnswer['validated_sentences'] as List)[0]
        as Map<String, dynamic>;

        detailedAnswer = firstSentence['rewritten'] as String? ?? '';

        // Extract sources from citations
        if (firstSentence['citations'] is List) {
          sources = (firstSentence['citations'] as List)
              .map((c) {
            final citation = c as Map<String, dynamic>;
            final sourceData = citation['source'] as Map<String, dynamic>?;

            return SourceReference(
              title: (sourceData?['title'] ?? citation['title'] ?? 'No title').toString(),
              url: (sourceData?['url'] ?? citation['url'] ?? '').toString(),
              domain: (sourceData?['domain'] ?? citation['domain'] ?? 'Unknown').toString(),
              authority: (sourceData?['authority'] ?? citation['authority'] ?? 'UNKNOWN').toString(),
              snippet: citation['fragment_text'] is String
                  ? citation['fragment_text'] as String
                  : null,
            );
          }).toList();
        }
      }

      // Determine if dual-mode
      final hasDualMode =
          quickAnswer.trim().isNotEmpty && detailedAnswer.trim().isNotEmpty;

      // Use quick answer as primary, fall back to detailed
      final primaryContent =
      quickAnswer.isNotEmpty ? quickAnswer : detailedAnswer;

      print('Debug: isDualMode=$hasDualMode, sources=${sources.length}');

      final aiMessage = ChatMessage(
        id: responseData['audit_id'] as String? ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        content: primaryContent,
        isUser: false,
        timestamp: DateTime.now(),
        sources: sources,
        isDualMode: hasDualMode,
        quickAnswer:
        quickAnswer.trim().isNotEmpty ? quickAnswer.trim() : null,
        detailedAnswer:
        detailedAnswer.trim().isNotEmpty ? detailedAnswer.trim() : null,
        latencyMs: responseData['processing_time_ms'] as int? ?? 0,
      );

      emit(state.copyWith(
        messages: [...state.messages, aiMessage],
        status: ChatStatus.success,
        isTyping: false,
        sessionId: state.sessionId ??
            (responseData['session_id'] as String? ??
                DateTime.now().millisecondsSinceEpoch.toString()),
      ));
    } on DioException catch (e) {
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: _getDioErrorMessage(e),
        isUser: false,
        timestamp: DateTime.now(),
        isRefusal: true,
        refusalReason: 'Network error',
      );

      emit(state.copyWith(
        messages: [...state.messages, errorMessage],
        status: ChatStatus.error,
        error: _getDioErrorMessage(e),
        isTyping: false,
      ));
    } catch (e) {
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Unexpected error: $e',
        isUser: false,
        timestamp: DateTime.now(),
        isRefusal: true,
        refusalReason: 'Unexpected error',
      );

      emit(state.copyWith(
        messages: [...state.messages, errorMessage],
        status: ChatStatus.error,
        error: 'Unexpected error: $e',
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
      );

      emit(state.copyWith(
        messages: [...state.messages, userMessage],
        isTyping: true,
      ));

      final request = repo.ChatQueryRequest(
        query: content.trim(),
        imageUrl: imageUrl,
      );

      final response = await _chatRepository.sendMessage(request);

      final allSources = <SourceReference>{};
      for (final sentence in response.sentences) {
        if (sentence.sources != null && sentence.sources!.isNotEmpty) {
          for (final repoSource in sentence.sources!) {
            allSources.add(SourceReference(
              title: repoSource.title,
              url: repoSource.url,
              snippet: repoSource.snippet,
              domain: _extractDomain(repoSource.url),
              authority: null,
            ));
          }
        }
      }

      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        content: response.answer,
        isUser: false,
        timestamp: DateTime.now(),
        sources: allSources.toList(),
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

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceAll('www.', '');
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet and try again.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. The server took too long to respond.';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout. The server took too long to respond.';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.statusCode ?? 'Unknown'}';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.unknown:
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}