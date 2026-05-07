import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

export 'database/database.dart';
export 'storage/storage.dart';

String _kSupabaseUrl = 'https://tgdpwygylwdcagupaubr.supabase.co';
String _kSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRnZHB3eWd5bHdkY2FndXBhdWJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI2MjU5NDIsImV4cCI6MjA4ODIwMTk0Mn0.YL8tNEop9YjvtwFl86PF_FanY5kTXq-IAm9Ytib8Mrg';

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();
  static Future<void>? _initializeFuture;
  static bool _initialized = false;

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;

  static Future<void> initialize({
    Duration timeout = const Duration(seconds: 12),
  }) {
    if (_initialized) {
      return Future.value();
    }
    return _initializeFuture ??= _initializeWithTimeout(timeout);
  }

  static Future<void> _initializeWithTimeout(Duration timeout) async {
    try {
      await Supabase.initialize(
        url: _kSupabaseUrl,
        headers: {
          'X-Client-Info': 'flutterflow',
        },
        anonKey: _kSupabaseAnonKey,
        debug: false,
        authOptions:
            FlutterAuthClientOptions(authFlowType: AuthFlowType.implicit),
      ).timeout(timeout);
      _initialized = true;
    } on TimeoutException catch (error, stackTrace) {
      debugPrint(
        'Supabase startup exceeded ${timeout.inSeconds}s: ${error.message}',
      );
      if (_supabaseClientIsReady()) {
        _initialized = true;
        return;
      }
      _initializeFuture = null;
      Error.throwWithStackTrace(error, stackTrace);
    } catch (error, stackTrace) {
      _initializeFuture = null;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  static bool _supabaseClientIsReady() {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }
}
