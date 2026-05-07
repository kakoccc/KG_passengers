import 'dart:async';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'auth/supabase_auth/supabase_user_provider.dart';
import 'auth/supabase_auth/auth_util.dart';

import '/backend/supabase/supabase.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'services/push_notifications/push_notification_service.dart';

const _startupTaskTimeout = Duration(seconds: 20);
const _appPrimary = Color(0xFF1976D2);
const _appBlack = Color(0xFF1C1C1C);
const _appBackground = Color(0xFFF0F1F5);
const _appGrey = Color(0xFFADB4C9);
const _appRed = Color(0xFFE53935);
const _appFontFamily = 'Inter';

final ThemeData _appLightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: false,
  fontFamily: _appFontFamily,
  primaryColor: _appPrimary,
  scaffoldBackgroundColor: _appBackground,
  cardColor: Colors.white,
  dividerColor: _appGrey,
  colorScheme: const ColorScheme.light(
    primary: _appPrimary,
    secondary: _appBlack,
    surface: _appBackground,
    error: _appRed,
    onPrimary: Colors.white,
    onSecondary: _appBackground,
    onSurface: _appBlack,
    onError: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: _appBackground,
    foregroundColor: _appBlack,
    elevation: 0.0,
    titleTextStyle: TextStyle(
      color: _appBlack,
      fontFamily: _appFontFamily,
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: _appBlack,
      fontFamily: _appFontFamily,
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
    ),
    displayMedium: TextStyle(
      color: _appBlack,
      fontFamily: _appFontFamily,
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
    ),
    displaySmall: TextStyle(
      color: _appBlack,
      fontFamily: _appFontFamily,
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
    ),
    headlineLarge: TextStyle(
      color: _appBlack,
      fontFamily: _appFontFamily,
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: TextStyle(
      color: _appBlack,
      fontFamily: _appFontFamily,
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      color: _appBlack,
      fontFamily: _appFontFamily,
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: _appBlack,
      fontFamily: _appFontFamily,
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      color: _appBlack,
      fontFamily: _appFontFamily,
      fontSize: 20.0,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      color: _appBlack,
      fontFamily: _appFontFamily,
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
    ),
    bodyLarge: TextStyle(
      color: _appBlack,
      fontFamily: _appFontFamily,
      fontSize: 20.0,
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: TextStyle(
      color: _appBlack,
      fontFamily: _appFontFamily,
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      color: _appBlack,
      fontFamily: _appFontFamily,
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(
      color: _appBlack,
      fontFamily: _appFontFamily,
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: TextStyle(
      color: _appBlack,
      fontFamily: _appFontFamily,
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      color: _appBlack,
      fontFamily: _appFontFamily,
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _appPrimary,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontFamily: _appFontFamily,
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999.0),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _appPrimary,
      textStyle: const TextStyle(
        fontFamily: _appFontFamily,
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _appPrimary,
      side: const BorderSide(color: _appPrimary),
      textStyle: const TextStyle(
        fontFamily: _appFontFamily,
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999.0),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    labelStyle: const TextStyle(
      color: _appGrey,
      fontFamily: _appFontFamily,
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
    ),
    hintStyle: const TextStyle(
      color: _appGrey,
      fontFamily: _appFontFamily,
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: _appGrey),
      borderRadius: BorderRadius.circular(16.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: _appPrimary, width: 2.0),
      borderRadius: BorderRadius.circular(16.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: _appRed),
      borderRadius: BorderRadius.circular(16.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: _appRed, width: 2.0),
      borderRadius: BorderRadius.circular(16.0),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _appPrimary,
    foregroundColor: Colors.white,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: _appPrimary,
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: _appBlack,
    contentTextStyle: TextStyle(
      color: Colors.white,
      fontFamily: _appFontFamily,
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
    ),
  ),
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    ),
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarColor: _appBackground,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: _appBackground,
      systemNavigationBarContrastEnforced: false,
    ),
  );
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final Completer<FFAppState> _startupCompleter;
  late Future<FFAppState> _startupFuture;

  @override
  void initState() {
    super.initState();
    _startupCompleter = Completer<FFAppState>();
    _startupFuture = _startupCompleter.future;
    WidgetsBinding.instance.addPostFrameCallback((_) => _completeStartup());
  }

  Future<void> _completeStartup() async {
    try {
      _startupCompleter.complete(await _initializeApp());
    } catch (error, stackTrace) {
      if (!_startupCompleter.isCompleted) {
        _startupCompleter.completeError(error, stackTrace);
      }
    }
  }

  Future<FFAppState> _initializeApp() async {
    final appState = FFAppState(); // Initialize FFAppState
    try {
      await _runStartupTask('Supabase', () => SupaFlow.initialize());
      await _runStartupTask(
        'Persisted app state',
        appState.initializePersistedState,
      );
      return appState;
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'KG pass startup',
          context: ErrorDescription('while initializing the app before MyApp'),
        ),
      );
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FFAppState>(
      future: _startupFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return StartupFailureApp(error: snapshot.error!);
        }

        final appState = snapshot.data;
        if (appState == null) {
          return const StartupLoadingApp();
        }

        return ChangeNotifierProvider<FFAppState>.value(
          value: appState,
          child: MyApp(),
        );
      },
    );
  }
}

class StartupLoadingApp extends StatelessWidget {
  const StartupLoadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _appLightTheme,
      home: const Scaffold(
        backgroundColor: _appBackground,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20.0),
                Text(
                  'Запускаем приложение...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: _appFontFamily,
                    color: _appBlack,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _runStartupTask(
  String label,
  Future<void> Function() task,
) {
  return task().timeout(
    _startupTaskTimeout,
    onTimeout: () => throw TimeoutException(
      '$label did not finish during startup',
      _startupTaskTimeout,
    ),
  );
}

class StartupFailureApp extends StatelessWidget {
  const StartupFailureApp({
    super.key,
    required this.error,
  });

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _appLightTheme,
      home: Scaffold(
        backgroundColor: _appBackground,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: _appRed,
                    size: 56.0,
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    'Не удалось запустить приложение',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: _appFontFamily,
                      color: _appBlack,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  const Text(
                    'Проверьте интернет и перезапустите приложение. '
                    'Если ошибка повторится, отправьте разработчику текст ниже.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: _appFontFamily,
                      color: _appBlack,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  SelectableText(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: _appFontFamily,
                      color: _appGrey,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  ThemeMode _themeMode = ThemeMode.system;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.path;
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  late Stream<BaseAuthUser> userStream;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(PushNotificationService.instance.initialize());
    });
    userStream = kGPassNewSupabaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
        unawaited(PushNotificationService.instance.syncForUser(user));
      });
    jwtTokenStream.listen((_) {});
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  void setLocale(String language) {
    safeSetState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'KG - passNew',
      localizationsDelegates: [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('ru'),
      ],
      theme: _appLightTheme,
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
