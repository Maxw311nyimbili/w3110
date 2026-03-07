import 'dart:async';
import 'dart:io';

import 'package:cap_project/features/chat/cubit/chat_state.dart';
import 'package:cap_project/features/medscanner/cubit/medscanner_state.dart'
    as scanner;
import 'package:cap_project/core/services/audio_recording_service.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat_repository/chat_repository.dart' as repo hide ChatMessage, SourceReference;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:landing_repository/landing_repository.dart' as landing;

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required repo.ChatRepository chatRepository,
    required landing.LandingRepository landingRepository,
    required AudioRecordingService audioRecordingService,
    String? locale,
    String? userRole,
    List<String>? interests,
  }) : _chatRepository = chatRepository,
       _landingRepository = landingRepository,
       _audioRecordingService = audioRecordingService,
       _audioPlayer = AudioPlayer(),
       _uuid = const Uuid(),
       _currentLocale = locale ?? 'en',
       _userRole = userRole,
       _interests = interests,
       super(const ChatState()) {
    _initAudioListeners();
    _configureAudioContext();
  }

  void _configureAudioContext() {
    AudioLogger.logLevel = AudioLogLevel.error;
    // Configure for iOS Safari compatibility:
    // - Stay playing when silent switch is on
    // - Mix with other apps if needed
    // - Don't stop on route change unless necessary
    AudioPlayer.global.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.duckOthers,
            AVAudioSessionOptions.defaultToSpeaker,
          },
        ),
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.assistanceSonification,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );
  }

  /// Primes the audio engine during a user gesture to unlock Safari/iOS playback.
  /// This should be called inside methods triggered by a click/tap.
  Future<void> _primeAudio() async {
    try {
      // Tiny 1-second silent MP3 to "bless" the context during the user gesture.
      // Safari requires a real source to be played to unlock subsequent programmatic playback.
      const silentMp3 = 'data:audio/mpeg;base64,SUQzBAAAAAABAFRYWFgAAAASAAADbWFqb3JfYnJhbmQAZGFzaABUWFhYAAAAEQAAA21pbm9yX3ZlcnNpb24AMABUWFhYAAAAHAAAA2NvbXBhdGlibGVfYnJhbmRzAGlzb21tcDQyAFVTRVIAAAAWAAADY3JlYXRpbmdfbGlicmFyeQBMQVZFAAAA//uQZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAoxAAAo0AAAKMAAAEjGzszMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMTM=';
      await _audioPlayer.setVolume(0.0);
      await _audioPlayer.play(UrlSource(silentMp3));
      await _audioPlayer.stop();
      await _audioPlayer.setVolume(1.0);
      print('🔊 [TTS] Audio engine primed with silent source');
    } catch (e) {
      print('🔊 [TTS] ⚠️ Failed to prime audio: $e');
    }
  }

  void _initAudioListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        emit(this.state.copyWith(isPlayingAudio: true));
      } else if (state == PlayerState.completed ||
                 state == PlayerState.stopped ||
                 state == PlayerState.paused) {
        emit(this.state.copyWith(isPlayingAudio: false, playingLanguage: null));
      }
    });
  }

  final repo.ChatRepository _chatRepository;
  final landing.LandingRepository _landingRepository;
  final AudioRecordingService _audioRecordingService;
  final AudioPlayer _audioPlayer;
  final Uuid _uuid;
  String _currentLocale;
  String? _userRole;
  List<String>? _interests;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  Timer? _loadingTimer;

  /// Update the locale for API requests
  void setLocale(String locale) {
    _currentLocale = locale;
  }

  /// Update user profile (role/interests) — called after onboarding status loads.
  void updateProfile({String? userRole, List<String>? interests}) {
    _userRole = userRole;
    _interests = interests;
  }

  /// Update the voice language for the Bilingual Bridge
  void updateLanguage(VoiceLanguage language) {
    emit(state.copyWith(selectedLanguage: language));
  }

  Future<void> initialize() async {
    try {
      emit(state.copyWith(status: ChatStatus.loading));

      // Fetch dynamic greeting in parallel with other initialization if needed
      final greeting = await _landingRepository.fetchGreeting();

      emit(
        state.copyWith(
          status: ChatStatus.success,
          dynamicGreeting: greeting,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          error: 'Failed to initialize chat',
        ),
      );
    }
  }

  // --- Audio Recording Methods ---

  Future<void> startRecording() async {
    try {
      print('🎤 [STT] startRecording called');
      await _primeAudio(); // Prime on mic click
      final hasPermission = await _audioRecordingService.hasPermission();
      print('🎤 [STT]   hasPermission: $hasPermission');
      if (!hasPermission) {
        print('🎤 [STT] ❌ Microphone permission denied');
        emit(state.copyWith(error: 'Microphone permission denied'));
        return;
      }

      await _audioRecordingService.startRecording();
      print('🎤 [STT] ✅ Recording started');

      _amplitudeSubscription?.cancel();
      _amplitudeSubscription = _audioRecordingService
          .onAmplitudeChanged()
          .listen((amp) {
            emit(state.copyWith(amplitude: amp.current.toDouble()));
          });

      emit(state.copyWith(isRecording: true));
    } catch (e) {
      print('🎤 [STT] ❌ startRecording ERROR: $e');
      emit(state.copyWith(error: 'Failed to start recording: $e'));
    }
  }

  Future<void> stopRecording() async {
    try {
      print('🎤 [STT] stopRecording called');
      final path = await _audioRecordingService.stopRecording();
      print('🎤 [STT]   recording saved to path: $path');
      _amplitudeSubscription?.cancel();
      emit(state.copyWith(isRecording: false, amplitude: 0.0));

      if (path != null) {
        print('🎤 [STT] ✅ Sending audio message...');
        await sendAudioMessage(path);
      } else {
        print('🎤 [STT] ⚠️ No recording path returned - audio NOT sent');
      }
    } catch (e) {
      print('🎤 [STT] ❌ stopRecording ERROR: $e');
      emit(
        state.copyWith(
          isRecording: false,
          amplitude: 0.0,
          error: 'Failed to stop recording: $e',
        ),
      );
    }
  }

  Future<void> cancelRecording() async {
    try {
      await _audioRecordingService.stopRecording();
      _amplitudeSubscription?.cancel();
      emit(state.copyWith(isRecording: false, amplitude: 0.0));
    } catch (e) {
      emit(state.copyWith(isRecording: false, amplitude: 0.0));
    }
  }

  Future<void> sendAudioMessage(String audioPath) async {
    try {
      print('🎤 [VOICE] sendAudioMessage called');
      print('🎤 [VOICE]   audioPath: $audioPath');
      print('🎤 [VOICE]   language: ${state.selectedLanguage.code}');

      emit(state.copyWith(isTyping: true));

      final responseData = await _chatRepository.sendVoiceMessage(
        audioPath: audioPath,
        sessionId:
            state.sessionId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userRole: _userRole,
        interests: _interests,
        inputLanguage: state.selectedLanguage.code,
        outputLanguage: state.selectedLanguage.code,
      );

      print('🎤 [VOICE] Response received:');
      print('🎤 [VOICE]   transcript: ${responseData['transcript']}');
      print('🎤 [VOICE]   audio_url: ${responseData['audio_url']}');
      print('🎤 [VOICE]   status: ${responseData['status']}');

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
    } catch (e) {
      print('🎤 [VOICE] ❌ ERROR in sendAudioMessage: $e');
      if (e.toString().contains('404')) {
        emit(
          state.copyWith(
            isTyping: false,
            error: 'Audio chat endpoint not found. Please use text for now.',
          ),
        );
      } else {
        emit(
          state.copyWith(
            isTyping: false,
            error: 'Failed to send audio: ${e.toString()}',
          ),
        );
      }
    }
  }

  void _handleChatResponse(Map<String, dynamic> responseData) {
    _loadingTimer?.cancel();
    final status = responseData['status'] as String? ?? 'error';

    if (status == 'out_of_scope') {
      final aiMessage = ChatMessage(
        id:
            responseData['audit_id'] as String? ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        content:
            responseData['message'] as String? ??
            'This query is outside the scope of medical information.',
        isUser: false,
        timestamp: DateTime.now(),
        isRefusal: true,
        refusalReason: 'Out of scope',
      );
      emit(
        state.copyWith(
          messages: [...state.messages, aiMessage],
          status: ChatStatus.success,
          isTyping: false,
        ),
      );
      return;
    }

    final validatedAnswer =
        responseData['validated_answer'] as Map<String, dynamic>? ?? {};
    final quickAnswer = validatedAnswer['original_answer'] as String? ?? '';
    final audioUrl = responseData['audio_url'] as String?;

    print('🔊 [TTS] _handleChatResponse:');
    print('🔊 [TTS]   status: $status');
    print('🔊 [TTS]   audio_url: $audioUrl');
    print('🔊 [TTS]   quickAnswer length: ${quickAnswer.length}');

    String detailedAnswer = '';
    List<SourceReference> sources = [];

    if (validatedAnswer['validated_sentences'] is List &&
        (validatedAnswer['validated_sentences'] as List).isNotEmpty) {
      final firstSentence =
          (validatedAnswer['validated_sentences'] as List)[0]
              as Map<String, dynamic>;
      detailedAnswer = firstSentence['rewritten'] as String? ?? '';

      if (firstSentence['citations'] is List) {
        sources = (firstSentence['citations'] as List).map<SourceReference>((c) {
          final citation = c as Map<String, dynamic>;
          final sourceData = citation['source'] as Map<String, dynamic>?;
          return SourceReference(
            title: (sourceData?['title'] ?? citation['title'] ?? 'No title')
                .toString(),
            url: (sourceData?['url'] ?? citation['url'] ?? '').toString(),
            domain: (sourceData?['domain'] ?? citation['domain'] ?? 'Unknown')
                .toString(),
            authority:
                (sourceData?['authority'] ?? citation['authority'] ?? 'UNKNOWN')
                    .toString(),
          );
        }).toList();
      }
    }

    final hasDualMode =
        quickAnswer.trim().isNotEmpty && detailedAnswer.trim().isNotEmpty;
    final primaryContent = quickAnswer.isNotEmpty
        ? quickAnswer
        : detailedAnswer;

    final aiMessage = ChatMessage(
      id:
          responseData['audit_id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      content: primaryContent,
      isUser: false,
      timestamp: DateTime.now(),
      sources: sources,
      isDualMode: hasDualMode,
      quickAnswer: quickAnswer.trim().isNotEmpty ? quickAnswer.trim() : null,
      detailedAnswer: detailedAnswer.trim().isNotEmpty
          ? detailedAnswer.trim()
          : null,
      audioUrl: audioUrl,
      latencyMs: responseData['processing_time_ms'] as int? ?? 0,
    );

    if (audioUrl != null) {
      print('🔊 [TTS] Audio URL found, attempting playback: $audioUrl');
      // Default to English if not specified, or use the selected language if it's the AI response
      _playAudio(audioUrl, language: state.selectedLanguage);
    } else {
      print('🔊 [TTS] ⚠️ No audio_url in response - TTS will NOT play');
    }

    emit(
      state.copyWith(
        messages: [...state.messages, aiMessage],
        status: ChatStatus.success,
        isTyping: false,
        sessionId: state.sessionId ?? responseData['session_id'] as String?,
      ),
    );
  }

  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      emit(state.copyWith(isPlayingAudio: false, isSynthesizingAudio: false, playingLanguage: null));
    } catch (e) {
      print('🔊 [TTS] ❌ Error stopping audio: $e');
    }
  }

  Future<void> _playAudio(String url, {VoiceLanguage? language}) async {
    try {
      emit(state.copyWith(playingLanguage: language));
      print('🔊 [TTS] _playAudio called (${url.length > 60 ? url.substring(0, 60) + '...' : url})');
      
      // On Web, Safari and other browsers often handle data URIs better via UrlSource
      // than decoding to bytes and using BytesSource.
      if (url.startsWith('data:')) {
        await _audioPlayer.play(UrlSource(url));
      } else {
        await _audioPlayer.play(UrlSource(url));
      }
      print('🔊 [TTS] ✅ Audio playback started successfully');
    } catch (e) {
      print('🔊 [TTS] ❌ Error playing audio: $e');
    }
  }

  /// Synthesize a specific message into speech (speak button on a message)
  /// Takes the message content directly - no database ID needed.
  Future<void> speakMessage(String messageContent, VoiceLanguage language) async {
    try {
      print('🔊 [TTS] speakMessage called:');
      await _primeAudio(); // Prime on speak icon click
      print('🔊 [TTS]   content length: ${messageContent.length}');
      print('🔊 [TTS]   language: ${language.code}');

      if (messageContent.trim().isEmpty) {
        print('🔊 [TTS] ⚠️ Empty content, skipping synthesis');
        return;
      }

      emit(state.copyWith(isSynthesizingAudio: true));

      print('🔊 [TTS]   Calling /chat/synthesize ...');
      final response = await _chatRepository.synthesizeSpeech(
        text: messageContent,
        language: language.code,
      );

      emit(state.copyWith(isSynthesizingAudio: false));

      final audioUrl = response['audio_url'] as String?;
      print('🔊 [TTS]   synthesize response audio_url: $audioUrl');

      if (audioUrl != null) {
        await _playAudio(audioUrl, language: language);
      } else {
        print('🔊 [TTS] ⚠️ synthesize returned no audio_url');
      }
    } catch (e) {
      print('🔊 [TTS] ❌ speakMessage error: $e');
      emit(state.copyWith(error: 'Failed to speak message: ${e.toString()}'));
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
    // Loading visual feedback handled in UI layer with isTyping state
  }

  // Main send message method
  Future<void> sendMessage(String content, {String? imageUrl}) async {
    if (content.trim().isEmpty) return;

    await _primeAudio(); // Prime on send button click

    // Generate or reuse the sessionId for the entire conversation.
    // This must be done BEFORE any async call so every message in the same
    // session always carries the same ID — regardless of network timing.
    final sessionId = state.sessionId ?? _uuid.v4();

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final loadingMessages = [
      'Thinking...',
      'Searching medical sources...',
      'Verifying with experts...',
      'Looking up citations...',
    ];
    int currentMsgIdx = 0;
    _loadingTimer?.cancel();
    _loadingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (currentMsgIdx < loadingMessages.length) {
        emit(state.updateLoadingMessage(loadingMessages[currentMsgIdx]));
        currentMsgIdx++;
      }
    });

    emit(
      state.copyWith(
        messages: [...state.messages, userMessage],
        status: ChatStatus.loading,
        isTyping: true,
        loadingMessage: loadingMessages[0],
        // Pin the sessionId into state immediately so the next sendMessage
        // call picks up the same ID even before this response returns.
        sessionId: sessionId,
      ),
    );

    try {
      final request = repo.ChatQueryRequest(
        query: content.trim(),
        imageUrl: imageUrl,
        conversationId: sessionId,
        userRole: _userRole,
        interests: _interests,
      );

      final response = await _chatRepository.sendMessageValidated(request);

      final status = response.status;

      // Handle out-of-scope
      if (status == 'out_of_scope') {
        final aiMessage = ChatMessage(
          id: response.sessionId,
          content:
              response.message ??
              'This query is outside the scope of medical information.',
          isUser: false,
          timestamp: DateTime.now(),
          isRefusal: true,
          refusalReason: 'Out of scope',
        );
        emit(
          state.copyWith(
            messages: [...state.messages, aiMessage],
            status: ChatStatus.success,
            isTyping: false,
          ),
        );
        return;
      }

      // Handle error
      if (status == 'error') {
        final aiMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: response.message ?? 'An error occurred',
          isUser: false,
          timestamp: DateTime.now(),
          isRefusal: true,
          refusalReason: 'Backend error',
        );
        emit(
          state.copyWith(
            messages: [...state.messages, aiMessage],
            status: ChatStatus.error,
            error: response.message ?? 'Unknown error',
            isTyping: false,
          ),
        );
        return;
      }

      // Extract validated answer
      final validatedAnswer = response.validatedAnswer;

      // Get quick answer (from original_answer)
      final quickAnswer = validatedAnswer?.originalAnswer ?? '';

      // Get detailed answer (from first sentence's rewritten field)
      String detailedAnswer = '';
      List<SourceReference> sources = [];

      if (validatedAnswer?.validatedSentences != null &&
          validatedAnswer!.validatedSentences.isNotEmpty) {
        final firstSentence = validatedAnswer.validatedSentences[0];

        detailedAnswer = firstSentence.rewritten;

        // Extract sources from citations
        if (firstSentence.citations.isNotEmpty) {
          sources = firstSentence.citations.map<SourceReference>((citation) {
            return SourceReference(
              title: citation.source.title,
              url: citation.source.url,
              domain: citation.source.domain,
              authority: citation.source.authority,
              snippet: citation.fragmentText,
            );
          }).toList();
        }
      }

      // Determine if dual-mode
      final hasDualMode =
          quickAnswer.trim().isNotEmpty && detailedAnswer.trim().isNotEmpty;

      // Use quick answer as primary, fall back to detailed
      final primaryContent = quickAnswer.isNotEmpty
          ? quickAnswer
          : detailedAnswer;

      print('Debug: isDualMode=$hasDualMode, sources=${sources.length}');

      final aiMessage = ChatMessage(
        id: validatedAnswer?.auditId ?? response.sessionId,
        content: primaryContent,
        isUser: false,
        timestamp: DateTime.now(),
        sources: sources,
        isDualMode: hasDualMode,
        quickAnswer: quickAnswer.trim().isNotEmpty ? quickAnswer.trim() : null,
        detailedAnswer: detailedAnswer.trim().isNotEmpty
            ? detailedAnswer.trim()
            : null,
        latencyMs: response.processingTimeMs,
      );

      emit(
        state.copyWith(
          messages: [...state.messages, aiMessage],
          status: ChatStatus.success,
          isTyping: false,
          // sessionId was pinned into state before the request was sent.
          sessionId: sessionId,
        ),
      );
    } catch (e) {
      _loadingTimer?.cancel();
      emit(state.resetLoadingMessage());
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
        isRefusal: true,
        refusalReason: 'Network error',
      );

      emit(
        state.copyWith(
          messages: [...state.messages, errorMessage],
          status: ChatStatus.error,
          error: e.toString(),
          isTyping: false,
        ),
      );
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

      emit(
        state.copyWith(
          messages: [...state.messages, userMessage],
          isTyping: true,
        ),
      );

      final request = repo.ChatQueryRequest(
        query: content.trim(),
        imageUrl: imageUrl,
        userRole: _userRole,
        interests: _interests,
      );

      final response = await _chatRepository.sendMessage(request);

      final allSources = <SourceReference>{};
      for (final sentence in response.sentences) {
        if (sentence.sources != null && sentence.sources!.isNotEmpty) {
          for (final repoSource in sentence.sources!) {
            allSources.add(
              SourceReference(
                title: repoSource.title,
                url: repoSource.url,
                snippet: repoSource.snippet,
                domain: _extractDomain(repoSource.url),
                authority: null,
              ),
            );
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

      emit(
        state.copyWith(
          status: ChatStatus.success,
          messages: [...state.messages, aiMessage],
          isTyping: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          error: 'Failed to process image: ${e.toString()}',
          isTyping: false,
        ),
      );
    }
  }

  Future<void> clearHistory() async {
    try {
      await _chatRepository.clearCache();
      emit(
        state.copyWith(
          status: ChatStatus.success,
          messages: [],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          error: 'Failed to clear history',
        ),
      );
    }
  }

  Future<void> pickImage() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        var status = await Permission.photos.status;
        if (status.isDenied) {
          status = await Permission.photos.request();
        }

        // On Android 13+, READ_MEDIA_IMAGES might be checking instead
        if (Platform.isAndroid && await Permission.photos.isDenied) {
          // Fallback or specific Android 13 check if needed,
          // but often image_picker handles this internal intent.
        }

        if (status.isPermanentlyDenied) {
          emit(
            state.copyWith(
              error:
                  'Photo library permission permanently denied. Please enable in settings.',
            ),
          );
          return;
        }
      }

      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final attachment = PendingAttachment(
          path: image.path,
          name: image.name,
          type: AttachmentType.image,
          size: await image.length(),
        );
        emit(
          state.copyWith(
            pendingAttachments: [...state.pendingAttachments, attachment],
          ),
        );
      } else {
        // User cancelled, do nothing
      }
    } catch (e) {
      print('❌ Failed to pick image: $e');
      emit(state.copyWith(error: 'Failed to pick image: $e'));
    }
  }

  Future<void> pickDocument() async {
    try {
      print('📂 Picking document...');
      // File picker often doesn't need explicit permission on newer Android/iOS for picking
      // as it uses system picker, but let's be safe.

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null && result.files.first.path != null) {
        final file = result.files.first;
        final attachment = PendingAttachment(
          path: file.path!,
          name: file.name,
          type: AttachmentType.document,
          size: file.size,
        );
        emit(
          state.copyWith(
            pendingAttachments: [...state.pendingAttachments, attachment],
          ),
        );
      }
    } catch (e) {
      print('❌ Failed to pick document: $e');
      emit(state.copyWith(error: 'Failed to pick document: $e'));
    }
  }

  void removeAttachment(String path) {
    final updated = state.pendingAttachments
        .where((a) => a.path != path)
        .toList();
    emit(state.copyWith(pendingAttachments: updated));
  }

  void addMedicineResult(scanner.ScanResult result) {
    final summaryMessage = ChatMessage(
      id: _uuid.v4(),
      content:
          'I have successfully scanned: ${result.medicationName}. '
          'How can I help you with this medication?',
      isUser: false,
      timestamp: DateTime.now(),
      medicineResult: result,
    );

    emit(
      state.copyWith(
        medicineContext: result,
        messages: [...state.messages, summaryMessage],
      ),
    );
  }

  void clearError() {
    emit(state.clearError());
  }

  void toggleMessageView(String messageId) {
    final List<ChatMessage> updatedMessages = state.messages.map<ChatMessage>((msg) {
      if (msg.id == messageId) {
        return msg.copyWith(showingDetailedView: !msg.showingDetailedView);
      }
      return msg;
    }).toList();

    emit(state.copyWith(messages: updatedMessages));
  }

  Future<void> loadHistory() async {
    try {
      emit(state.copyWith(isLoadingHistory: true));
      final historyData = await _chatRepository.fetchHistory(limit: 100);

      // Group by sessionId and create HistorySession objects
      final sessions = <String, List<Map<String, dynamic>>>{};
      for (final msg in historyData) {
        final sid = msg['session_id'] as String? ?? 'unknown';
        sessions.putIfAbsent(sid, () => []).add(msg);
      }

      final List<HistorySession> historySessions = sessions.entries.map<HistorySession>((entry) {
        final msgs = entry.value;
        // Search for the first user message in this session to use as title
        final Map<String, dynamic> firstUserMsg = msgs.firstWhere(
          (m) => m['role'] == 'user',
          orElse: () => msgs.first,
        );
        return HistorySession(
          sessionId: entry.key,
          firstMessage: firstUserMsg['content'] as String? ?? 'New Chat',
          timestamp: DateTime.parse(msgs.first['created_at'] as String),
        );
      }).toList();

      // Sort by timestamp descending
      historySessions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      emit(state.copyWith(
        isLoadingHistory: false,
        historySessions: historySessions,
      ));
    } catch (e) {
      print('❌ Failed to load history: $e');
      emit(state.copyWith(isLoadingHistory: false));
    }
  }

  Future<void> loadSession(String sessionId) async {
    try {
      emit(state.copyWith(status: ChatStatus.loading, isTyping: true));
      final historyData = await _chatRepository.fetchHistory(limit: 50);
      
      // Filter for this session
      final List<Map<String, dynamic>> sessionMsgs = historyData.where((m) => m['session_id'] == sessionId).toList();
      
      final List<ChatMessage> messages = sessionMsgs.map<ChatMessage>((m) => _mapRepoMessageToModel(m)).toList();

      emit(state.copyWith(
        status: ChatStatus.success,
        messages: messages,
        sessionId: sessionId,
        isTyping: false,
      ));
    } catch (e) {
      print('❌ Failed to load session: $e');
      emit(state.copyWith(status: ChatStatus.error, error: 'Failed to load chat session', isTyping: false));
    }
  }

  ChatMessage _mapRepoMessageToModel(Map<String, dynamic> m) {
    final isUser = m['role'] == 'user';
    final content = m['content'] as String? ?? '';
    final sentencesRaw = m['sentences'];

    List<SourceReference> sources = [];
    if (sentencesRaw is List) {
      try {
        sources = sentencesRaw.map<SourceReference>((s) {
          final map = s as Map<String, dynamic>;
          final sourceData = map['source'] as Map<String, dynamic>?;
          return SourceReference(
            title: (sourceData?['title'] ?? map['title'] ?? 'No title').toString(),
            url: (sourceData?['url'] ?? map['url'] ?? '').toString(),
            domain: (sourceData?['domain'] ?? map['domain'] ?? 'Unknown').toString(),
            authority: (sourceData?['authority'] ?? map['authority'] ?? 'UNKNOWN').toString(),
            snippet: (map['fragment_text'] ?? map['snippet']) as String?,
          );
        }).toList();
      } catch (e) {
        print('⚠️ Error parsing sources from history: $e');
      }
    }

    return ChatMessage(
      id: m['id'].toString(),
      content: content,
      isUser: isUser,
      timestamp: DateTime.parse(m['created_at'] as String),
      sources: sources,
    );
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceAll('www.', '');
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Clear current conversation and start a fresh session.
  void startNewSession() {
    emit(
      state.copyWith(
        messages: [],
        sessionId: null,
        status: ChatStatus.initial,
        isTyping: false,
        error: null,
      ),
    );
  }

  /// Clear the history sessions list locally (e.g., on logout).
  void clearLocalHistorySessions() {
    emit(state.copyWith(historySessions: []));
  }
}
