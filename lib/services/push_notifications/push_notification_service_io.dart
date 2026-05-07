import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:pushy_flutter/pushy_flutter.dart';

import '/auth/base_auth_user_provider.dart';
import '/backend/supabase/supabase.dart';

const _registrationTimeout = Duration(seconds: 20);
const _supabaseSyncTimeout = Duration(seconds: 12);
const _registrationRetryDelay = Duration(seconds: 4);

@pragma('vm:entry-point')
void pushyBackgroundNotificationListener(Map<String, dynamic> data) {
  final title = data['title']?.toString() ?? 'KG - passNew';
  final message = data['message']?.toString() ??
      data['body']?.toString() ??
      'У вас новое уведомление';

  if (Platform.isAndroid) {
    Pushy.notify(title, message, data);
  }
  Pushy.clearBadge();
}

class PushNotificationService {
  PushNotificationService._();

  static final instance = PushNotificationService._();

  bool _initialized = false;
  Future<void>? _initializeInFlight;
  Future<void>? _syncInFlight;
  String? _lastSyncedUserId;
  String? _lastSyncedToken;

  bool get _isSupportedPlatform => Platform.isAndroid || Platform.isIOS;

  Future<void> initialize() async {
    if (_initialized || !_isSupportedPlatform) {
      return;
    }
    if (_initializeInFlight != null) {
      return _initializeInFlight;
    }

    _initializeInFlight = _initializePushy().whenComplete(() {
      _initializeInFlight = null;
    });
    return _initializeInFlight;
  }

  Future<void> _initializePushy() async {
    try {
      Pushy.listen();
      Pushy.toggleInAppBanner(true);
      Pushy.setNotificationListener(pushyBackgroundNotificationListener);
      Pushy.setNotificationClickListener((data) {
        debugPrint('Push notification click: $data');
        Pushy.clearBadge();
      });
      _initialized = true;
    } catch (error, stackTrace) {
      _reportNonFatal(
        error,
        stackTrace,
        'while initializing Pushy notifications',
      );
    }
  }

  Future<void> syncForUser(BaseAuthUser user) async {
    if (!_isSupportedPlatform || !user.loggedIn || (user.uid ?? '').isEmpty) {
      _lastSyncedUserId = null;
      _lastSyncedToken = null;
      return;
    }

    if (_syncInFlight != null) {
      return _syncInFlight;
    }

    _syncInFlight = _registerAndPersist(user).whenComplete(() {
      _syncInFlight = null;
    });
    return _syncInFlight;
  }

  Future<void> _registerAndPersist(
    BaseAuthUser user, {
    bool retryOnFailure = true,
  }) async {
    try {
      await initialize();

      final userId = user.uid;
      if (userId == null || userId.isEmpty) {
        return;
      }

      final token = await Pushy.register().timeout(_registrationTimeout);
      if (_lastSyncedUserId == userId && _lastSyncedToken == token) {
        return;
      }

      await SupaFlow.client.rpc(
        'register_user_device',
        params: {
          'p_device_token': token,
          'p_platform': _platformName,
          'p_app_version': null,
        },
      ).timeout(_supabaseSyncTimeout);

      _lastSyncedUserId = userId;
      _lastSyncedToken = token;
    } catch (error, stackTrace) {
      _reportNonFatal(
        error,
        stackTrace,
        'while registering Pushy device token',
      );
      if (retryOnFailure && user.loggedIn && (user.uid ?? '').isNotEmpty) {
        await Future<void>.delayed(_registrationRetryDelay);
        await _registerAndPersist(user, retryOnFailure: false);
      }
    }
  }

  String get _platformName {
    if (Platform.isAndroid) {
      return 'android';
    }
    if (Platform.isIOS) {
      return 'ios';
    }
    return 'unknown';
  }

  void _reportNonFatal(
    Object error,
    StackTrace stackTrace,
    String context,
  ) {
    debugPrint('Push notifications skipped: $error');
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'KG pass push notifications',
        context: ErrorDescription(context),
      ),
    );
  }
}
