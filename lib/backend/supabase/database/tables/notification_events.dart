import '../database.dart';

class NotificationEventsTable extends SupabaseTable<NotificationEventsRow> {
  @override
  String get tableName => 'notification_events';

  @override
  NotificationEventsRow createRow(Map<String, dynamic> data) =>
      NotificationEventsRow(data);
}

class NotificationEventsRow extends SupabaseDataRow {
  NotificationEventsRow(super.data);

  @override
  SupabaseTable get table => NotificationEventsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  String get recipientRole => getField<String>('recipient_role')!;
  set recipientRole(String value) => setField<String>('recipient_role', value);

  String? get bookingId => getField<String>('booking_id');
  set bookingId(String? value) => setField<String>('booking_id', value);

  String? get tripId => getField<String>('trip_id');
  set tripId(String? value) => setField<String>('trip_id', value);

  String? get recipientUserId => getField<String>('recipient_user_id');
  set recipientUserId(String? value) =>
      setField<String>('recipient_user_id', value);

  String? get actorUserId => getField<String>('actor_user_id');
  set actorUserId(String? value) => setField<String>('actor_user_id', value);

  dynamic get payload => getField<dynamic>('payload');
  set payload(dynamic value) => setField<dynamic>('payload', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get processedAt => getField<DateTime>('processed_at');
  set processedAt(DateTime? value) => setField<DateTime>('processed_at', value);
}
