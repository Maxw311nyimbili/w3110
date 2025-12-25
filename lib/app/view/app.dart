// lib/app/app.dart

import 'package:api_client/api_client.dart';
import 'package:auth_repository/auth_repository.dart';
import 'package:cap_project/app/view/app_config.dart';
import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/locale/cubit/locale_cubit.dart';
import 'package:cap_project/core/locale/cubit/locale_state.dart';
import 'package:cap_project/core/theme/app_theme.dart';
import 'package:cap_project/features/auth/cubit/auth_cubit.dart';
import 'package:cap_project/features/landing/cubit/landing_cubit.dart';
import 'package:cap_project/l10n/l10n.dart';
import 'package:chat_repository/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forum_repository/forum_repository.dart';
import 'package:landing_repository/landing_repository.dart';
import 'package:media_repository/media_repository.dart';


/// Main app widget
class App extends StatefulWidget {
  const App({
    required this.config,
    super.key,
  });

  final AppConfig config;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final ChatRepository _chatRepository;
  late final ForumRepository _forumRepository;
  late final LandingRepository _landingRepository;
  late final MediaRepository _mediaRepository;
  late final AuthCubit _authCubit;
  late final LandingCubit _landingCubit;
  late final LocaleCubit _localeCubit;

  @override
  void initState() {
    super.initState();
    _initializeRepositories();
    _setupLocaleListener();
  }

  void _initializeRepositories() {
    // Initialize API client
    _apiClient = ApiClient(
      baseUrl: widget.config.apiBaseUrl,
      enableLogging: widget.config.enableLogging,
      connectTimeout: widget.config.apiTimeout,
      receiveTimeout: widget.config.apiTimeout,
      getAccessToken: () async {
        return "test-token-day2";
      },
      refreshToken: () async {},
    );

    // Initialize repositories
    _authRepository = AuthRepository(
      apiClient: _apiClient,
      secureStorage: SecureStorageHelper(),
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
      localPreferences: LocalPreferences(),
    );

    _mediaRepository = MediaRepository(
      apiClient: _apiClient,
      imageProcessor: ImageProcessor(),
    );

    // Initialize global AuthCubit
    _authCubit = AuthCubit(authRepository: _authRepository);

    // Initialize global LandingCubit with both repositories
    _landingCubit = LandingCubit(
      landingRepository: _landingRepository,
      authRepository: _authRepository,
    );

    // Initialize global LocaleCubit
    _localeCubit = LocaleCubit();
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
          BlocProvider.value(value: _landingCubit),
          BlocProvider.value(value: _localeCubit),
        ],
        child: BlocBuilder<LocaleCubit, LocaleState>(
          builder: (context, localeState) {
            return MaterialApp(
              title: 'Thanzi',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.system,
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
              initialRoute: AppRouter.landing,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authCubit.close();
    _landingCubit.close();
    _localeCubit.close();
    super.dispose();
  }
}