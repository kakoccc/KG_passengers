import 'dart:async';

import '/backend/supabase/supabase.dart';
import 'package:flutter/foundation.dart';

class BookingLiveRefresh {
  BookingLiveRefresh({
    required this.channelName,
    required this.onRefresh,
    this.tripId,
    this.userId,
    this.pollInterval = const Duration(seconds: 4),
    this.debounce = const Duration(milliseconds: 250),
  });

  final String channelName;
  final String? tripId;
  final String? userId;
  final Future<void> Function() onRefresh;
  final Duration pollInterval;
  final Duration debounce;

  RealtimeChannel? _channel;
  Timer? _pollTimer;
  Timer? _debounceTimer;
  bool _isRefreshing = false;
  bool _disposed = false;

  void start() {
    stop();
    _disposed = false;
    _subscribeRealtime();
    _pollTimer = Timer.periodic(pollInterval, (_) => refresh());
  }

  void stop() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _pollTimer?.cancel();
    _pollTimer = null;
    final channel = _channel;
    _channel = null;
    if (channel != null) {
      unawaited(SupaFlow.client.removeChannel(channel));
    }
  }

  void dispose() {
    _disposed = true;
    stop();
  }

  Future<void> refresh() async {
    if (_disposed || _isRefreshing) {
      return;
    }

    _isRefreshing = true;
    try {
      await onRefresh();
    } catch (error, stackTrace) {
      debugPrint('Booking live refresh failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isRefreshing = false;
    }
  }

  void _scheduleRefresh() {
    if (_disposed) {
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () {
      unawaited(refresh());
    });
  }

  void _subscribeRealtime() {
    try {
      final channel = SupaFlow.client.channel(channelName)
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'bookings',
          callback: (payload) {
            if (_matches(payload)) {
              _scheduleRefresh();
            }
          },
        ).subscribe();
      _channel = channel;
    } catch (error, stackTrace) {
      debugPrint('Booking realtime subscribe failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  bool _matches(PostgresChangePayload payload) {
    final newRecord = payload.newRecord;
    final oldRecord = payload.oldRecord;
    final payloadTripId = _stringValue(newRecord, 'trip_id') ??
        _stringValue(oldRecord, 'trip_id');
    final payloadUserId = _stringValue(newRecord, 'user_id') ??
        _stringValue(oldRecord, 'user_id');

    if (tripId != null && payloadTripId != tripId) {
      return false;
    }
    if (userId != null && payloadUserId != userId) {
      return false;
    }
    return true;
  }

  String? _stringValue(Map<String, dynamic> record, String key) {
    final value = record[key];
    if (value == null) {
      return null;
    }
    return value.toString();
  }
}
