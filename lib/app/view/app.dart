// lib/app/app.dart

import 'package:api_client/api_client.dart';
import 'package:auth_repository/auth_repository.dart';
import 'package:cap_project/app/view/app_config.dart';
import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/locale/cubit/locale_cubit.dart';
import 'package:cap_project/core/locale/cubit/locale_state.dart';
import 'package:cap_project/core/services/audio_recording_service.dart';
import 'package:cap_project/core/theme/app_theme.dart';
import 'package:cap_project/core/theme/cubit/theme_cubit.dart';
import 'package:cap_project/core/theme/cubit/theme_state.dart';
import 'package:cap_project/features/auth/cubit/auth_cubit.dart';
import 'package:cap_project/features/chat/cubit/chat_cubit.dart';
import 'package:cap_project/features/landing/cubit/landing_cubit.dart';
import 'package:cap_project/app/cubit/navigation_cubit.dart';
import 'package:cap_project/l10n/l10n.dart';
import 'package:chat_repository/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forum_repository/forum_repository.dart';
import 'package:landing_repository/landing_repository.dart';
import 'package:cap_project/core/widgets/app_shell.dart';
import 'package:media_repository/media_repository.dart';

/// Main app widget
class App extends StatefulWidget {
  const App({
    required this.config,
    this.localPreferences,
    super.key,
  });

  final AppConfig config;
  final LocalPreferences? localPreferences;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final SecureStorageHelper _secureStorage;
  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final ChatRepository _chatRepository;
  late final ForumRepository _forumRepository;
  late final LandingRepository _landingRepository;
  late final MediaRepository _mediaRepository;
  late final AuthCubit _authCubit;
  late final ChatCubit _chatCubit;
  late final LandingCubit _landingCubit;
  late final LocaleCubit _localeCubit;
  late final ThemeCubit _themeCubit;
  late final NavigationCubit _navigationCubit;

  @override
  void initState() {
    super.initState();
    _initializeRepositories();
    _setupLocaleListener();

    // Restore authentication session on startup
    _authCubit.initialize();
  }

  void _initializeRepositories() {
    // Enable edge-to-edge display
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
      ),
    );

    // Initialize Secure Storage
    _secureStorage = SecureStorageHelper();

    // Initialize API client
    _apiClient = ApiClient(
      baseUrl: widget.config.apiBaseUrl,
      enableLogging: widget.config.enableLogging,
      connectTimeout: widget.config.apiTimeout,
      receiveTimeout: widget.config.apiTimeout,
      getAccessToken: () async {
        // 1. Try to get real token from secure storage (Google or Demo login)
        final savedToken = await _secureStorage.getAccessToken();
        if (savedToken != null && savedToken.isNotEmpty) {
          return savedToken;
        }

        /* 
        // 2. Fallback to hardcoded demo token if nothing is saved
        // STASHED: Uncomment for stakeholder demos if needed
        return "test-token-day2";
        */
        return null;
      },
      refreshToken: () async {
        // Use the repository to refresh the token
        await _authRepository.refreshToken();
      },
    );

    // Initialize repositories
    _authRepository = AuthRepository(
      apiClient: _apiClient,
      secureStorage: _secureStorage,
    );

    _chatRepository = ChatRepository(
      apiClient: _apiClient,
      localCache: LocalChatCache(),
    );

    _forumRepository = ForumRepository(
      apiClient: _apiClient,
      database: ForumDatabase(),
    );

    _landingRepository = LandingRepository(
      apiClient: _apiClient,
      localPreferences: widget.localPreferences ?? LocalPreferences(),
    );

    _mediaRepository = MediaRepository(
      apiClient: _apiClient,
      imageProcessor: ImageProcessor(),
    );

    // 2. Initialize Cubits with correct dependency order
    
    // ThemeCubit depends only on repositories
    _themeCubit = ThemeCubit(landingRepository: _landingRepository);

    // AuthCubit depends on repositories and ThemeCubit
    _authCubit = AuthCubit(
      authRepository: _authRepository,
      themeCubit: _themeCubit,
    );

    // LandingCubit depends on repositories and AuthCubit
    _landingCubit = LandingCubit(
      landingRepository: _landingRepository,
      authRepository: _authRepository,
      authCubit: _authCubit,
      isDevelopment: widget.config.isDevelopment,
    );

    // Other Cubits with no inter-dependencies
    _localeCubit = LocaleCubit();
    _navigationCubit = NavigationCubit();

    // ChatCubit — created at app level so SideMenu can access history.
    // Profile (userRole/interests) is updated later by ChatPage once onboarding loads.
    _chatCubit = ChatCubit(
      chatRepository: _chatRepository,
      landingRepository: _landingRepository,
      audioRecordingService: AudioRecordingService(),
    );
  }

  void _setupLocaleListener() {
    // Listen to locale changes and update API client
    _localeCubit.stream.listen((localeState) {
      _apiClient.setLocale(localeState.locale.languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider.value(value: _chatRepository),
        RepositoryProvider.value(value: _forumRepository),
        RepositoryProvider.value(value: _landingRepository),
        RepositoryProvider.value(value: _mediaRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authCubit),
          BlocProvider.value(value: _chatCubit),
          BlocProvider.value(value: _landingCubit),
          BlocProvider.value(value: _localeCubit),
          BlocProvider.value(value: _themeCubit),
          BlocProvider.value(value: _navigationCubit),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return BlocBuilder<LocaleCubit, LocaleState>(
              builder: (context, localeState) {
                return MaterialApp(
                  title: 'Thanzi',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeState.flutterThemeMode,
                  locale: localeState.locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  localeResolutionCallback: (locale, supportedLocales) {
                    if (locale == null) return supportedLocales.first;
                    for (final supportedLocale in supportedLocales) {
                      if (supportedLocale.languageCode == locale.languageCode) {
                        return supportedLocale;
                      }
                    }
                    return supportedLocales.first;
                  },
                  onGenerateRoute: AppRouter.generateRoute,
                  initialRoute: AppRouter.splash,
                  builder: (context, child) {
                    if (child == null) return const SizedBox();
                    return child;
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authCubit.close();
    _chatCubit.close();
    _landingCubit.close();
    _localeCubit.close();
    _themeCubit.close();
    _navigationCubit.close();
    super.dispose();
  }
}

/// Banner to display current environment overlay
class FlavorBanner extends StatelessWidget {
  const FlavorBanner({
    required this.config,
    required this.child,
    super.key,
  });

  final AppConfig config;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        child,
        _buildBanner(context),
      ],
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: CustomPaint(
        painter: BannerPainter(
          message: config.isDevelopment ? 'DEV' : 'STAGING',
          textDirection: TextDirection.ltr,
          layoutDirection: TextDirection.ltr,
          location: BannerLocation.topEnd,
          color: config.isDevelopment
              ? Colors.green.withOpacity(0.6)
              : Colors.orange.withOpacity(0.6),
        ),
      ),
    );
  }
}
