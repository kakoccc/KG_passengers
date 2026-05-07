import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:k_g_pass_new/app_state.dart';
import 'package:k_g_pass_new/auth/supabase_auth/supabase_user_provider.dart';
import 'package:k_g_pass_new/backend/supabase/supabase.dart';
import 'package:k_g_pass_new/flutter_flow/nav/nav.dart';
import 'package:k_g_pass_new/index.dart';
import 'package:k_g_pass_new/main.dart';

bool _supabaseInitialized = false;

Future<void> _ensureSupabaseInitialized() async {
  if (_supabaseInitialized) {
    return;
  }
  await SupaFlow.initialize();
  SupaFlow.client.auth.stopAutoRefresh();
  _supabaseInitialized = true;
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required bool hasSeenWelcome,
}) async {
  SharedPreferences.setMockInitialValues({
    'ff_hasSeenWelcome': hasSeenWelcome,
  });
  FFAppState.reset();

  await _ensureSupabaseInitialized();
  SupaFlow.client.auth.stopAutoRefresh();

  final appState = FFAppState();
  await appState.initializePersistedState();

  final appStateNotifier = AppStateNotifier.instance;
  appStateNotifier.showSplashImage = false;
  appStateNotifier.clearRedirectLocation();
  appStateNotifier.update(KGPassNewSupabaseUser(null));

  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1440, 2960);

  await tester.pumpWidget(
    ChangeNotifierProvider<FFAppState>.value(
      value: appState,
      child: MyApp(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _disposeApp(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDownAll(() {
    if (_supabaseInitialized) {
      SupaFlow.client.auth.stopAutoRefresh();
    }
  });

  testWidgets('App bootstrap smoke renders Splash for signed-out user',
      (WidgetTester tester) async {
    await _pumpApp(
      tester,
      hasSeenWelcome: true,
    );

    expect(find.byType(MyApp), findsOneWidget);
    expect(find.byType(SplashWidget), findsOneWidget);
    await _disposeApp(tester);
  });

  testWidgets('First launch branch renders Welcome',
      (WidgetTester tester) async {
    await _pumpApp(
      tester,
      hasSeenWelcome: false,
    );

    expect(find.byType(MyApp), findsOneWidget);
    expect(find.byType(WelcomeWidget), findsOneWidget);
    await _disposeApp(tester);
  });
}
