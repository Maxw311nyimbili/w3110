// lib/features/chat/cubit/chat_cubit.dart
import 'dart:async';

import 'package:cap_project/features/chat/cubit/chat_state.dart';
import 'package:cap_project/core/services/audio_recording_service.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat_repository/chat_repository.dart' as repo;
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required repo.ChatRepository chatRepository,
    required AudioRecordingService audioRecordingService,
    String? locale,
  })  : _chatRepository = chatRepository,
        _audioRecordingService = audioRecordingService,
        _audioPlayer = AudioPlayer(),
        _uuid = const Uuid(),
        _dio = Dio(),
        _currentLocale = locale ?? 'en',
        super(const ChatState());

  final repo.ChatRepository _chatRepository;
  final AudioRecordingService _audioRecordingService;
  final AudioPlayer _audioPlayer;
  final Uuid _uuid;
  final Dio _dio;
  String _currentLocale;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  Timer? _loadingTimer;

  /// Update the locale for API requests
  void setLocale(String locale) {
    _currentLocale = locale;
  }

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

  // --- Audio Recording Methods ---

  Future<void> startRecording() async {
    try {
      if (await _audioRecordingService.hasPermission()) {
        emit(state.copyWith(isRecording: true, amplitude: -160.0));
        await _audioRecordingService.startRecording();
        
        _amplitudeSubscription = _audioRecordingService.onAmplitudeChanged().listen((amp) {
          emit(state.copyWith(amplitude: amp.current));
        });
      } else {
        emit(state.copyWith(error: 'Microphone permission denied'));
      }
    } catch (e) {
      emit(state.copyWith(isRecording: false, error: 'Failed to start recording: $e'));
    }
  }

  Future<void> stopRecording() async {
    try {
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;
      emit(state.copyWith(isRecording: false, isTyping: true));
      final path = await _audioRecordingService.stopRecording();
      
      if (path != null) {
        emit(state.copyWith(recordingPath: path));
        await _sendAudioMessage(path);
      } else {
        emit(state.copyWith(isTyping: false, error: 'Recording failed'));
      }
    } catch (e) {
      emit(state.copyWith(isTyping: false, error: 'Failed to stop recording: $e'));
    }
  }

  Future<void> cancelRecording() async {
    try {
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;
      await _audioRecordingService.cancelRecording();
      emit(state.copyWith(isRecording: false));
    } catch (e) {
      emit(state.copyWith(isRecording: false));
    }
  }

  Future<void> _sendAudioMessage(String path) async {
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(path, filename: 'voice_query.m4a'),
        'session_id': state.sessionId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      });

      _startLoadingRotation();

      final response = await _dio.post(
        'http://172.26.80.1:8000/chat/voice',
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 120),
          headers: {'Accept-Language': _currentLocale},
        ),
      );

      final responseData = response.data as Map<String, dynamic>;
      
      if (responseData['transcript'] != null) {
        final userMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: responseData['transcript'] as String,
          isUser: true,
          timestamp: DateTime.now(),
        );
        emit(state.copyWith(messages: [...state.messages, userMessage]));
      }
      _handleChatResponse(responseData);
      
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
         emit(state.copyWith(
           isTyping: false,
           error: 'Audio chat endpoint not found. Please use text for now.',
         ));
      } else {
        emit(state.copyWith(
          isTyping: false,
          error: _getDioErrorMessage(e),
        ));
      }
    } catch (e) {
      emit(state.copyWith(isTyping: false, error: 'Unexpected error: $e'));
    }
  }

  void _handleChatResponse(Map<String, dynamic> responseData) {
    _loadingTimer?.cancel();
    emit(state.resetLoadingMessage());
    final status = responseData['status'] as String? ?? 'error';

    if (status == 'out_of_scope') {
      final aiMessage = ChatMessage(
        id: responseData['audit_id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        content: responseData['message'] as String? ?? 'This query is outside the scope of medical information.',
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

    final validatedAnswer = responseData['validated_answer'] as Map<String, dynamic>? ?? {};
    final quickAnswer = validatedAnswer['original_answer'] as String? ?? '';
    final audioUrl = responseData['audio_url'] as String?;
    
    String detailedAnswer = '';
    List<SourceReference> sources = [];

    if (validatedAnswer['validated_sentences'] is List &&
        (validatedAnswer['validated_sentences'] as List).isNotEmpty) {
      final firstSentence = (validatedAnswer['validated_sentences'] as List)[0] as Map<String, dynamic>;
      detailedAnswer = firstSentence['rewritten'] as String? ?? '';

      if (firstSentence['citations'] is List) {
        sources = (firstSentence['citations'] as List).map((c) {
          final citation = c as Map<String, dynamic>;
          final sourceData = citation['source'] as Map<String, dynamic>?;
          return SourceReference(
            title: (sourceData?['title'] ?? citation['title'] ?? 'No title').toString(),
            url: (sourceData?['url'] ?? citation['url'] ?? '').toString(),
            domain: (sourceData?['domain'] ?? citation['domain'] ?? 'Unknown').toString(),
            authority: (sourceData?['authority'] ?? citation['authority'] ?? 'UNKNOWN').toString(),
          );
        }).toList();
      }
    }

    final hasDualMode = quickAnswer.trim().isNotEmpty && detailedAnswer.trim().isNotEmpty;
    final primaryContent = quickAnswer.isNotEmpty ? quickAnswer : detailedAnswer;

    final aiMessage = ChatMessage(
      id: responseData['audit_id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: primaryContent,
      isUser: false,
      timestamp: DateTime.now(),
      sources: sources,
      isDualMode: hasDualMode,
      quickAnswer: quickAnswer.trim().isNotEmpty ? quickAnswer.trim() : null,
      detailedAnswer: detailedAnswer.trim().isNotEmpty ? detailedAnswer.trim() : null,
      audioUrl: audioUrl,
      latencyMs: responseData['processing_time_ms'] as int? ?? 0,
    );

    if (audioUrl != null) {
      _playAudio(audioUrl);
    }

    emit(state.copyWith(
      messages: [...state.messages, aiMessage],
      status: ChatStatus.success,
      isTyping: false,
      sessionId: state.sessionId ?? responseData['session_id'] as String?,
    ));
  }

  Future<void> _playAudio(String url) async {
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  Future<void> close() {
    _amplitudeSubscription?.cancel();
    _loadingTimer?.cancel();
    _audioPlayer.dispose();
    _audioRecordingService.dispose();
    return super.close();
  }

  void _startLoadingRotation() {
    _loadingTimer?.cancel();
    final messages = [
      'Processing your request...',
      'Analyzing context...',
      'Consulting medical guidelines...',
      'Ensuring safety protocols...',
      'Finalizing your answer...',
    ];
    int index = 0;
    
    emit(state.copyWith(loadingMessage: messages[0]));
    
    _loadingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      index = (index + 1) % messages.length;
      emit(state.copyWith(loadingMessage: messages[index]));
    });
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

    _startLoadingRotation();

    try {
      final response = await _dio.post(
        'http://172.26.80.1:8000/chat/validate',
        data: {
          'query': content.trim(),
          'session_id': state.sessionId ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          'locale': _currentLocale,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 120),
          headers: {'Accept-Language': _currentLocale},
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
      _loadingTimer?.cancel();
      emit(state.resetLoadingMessage());
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
      _loadingTimer?.cancel();
      emit(state.resetLoadingMessage());
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