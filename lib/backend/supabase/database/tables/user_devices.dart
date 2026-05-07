import '../database.dart';

class UserDevicesTable extends SupabaseTable<UserDevicesRow> {
  @override
  String get tableName => 'user_devices';

  @override
  UserDevicesRow createRow(Map<String, dynamic> data) => UserDevicesRow(data);
}

class UserDevicesRow extends SupabaseDataRow {
  UserDevicesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserDevicesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get deviceToken => getField<String>('device_token')!;
  set deviceToken(String value) => setField<String>('device_token', value);

  String? get platform => getField<String>('platform');
  set platform(String? value) => setField<String>('platform', value);

  String? get appVersion => getField<String>('app_version');
  set appVersion(String? value) => setField<String>('app_version', value);

  DateTime? get lastSeenAt => getField<DateTime>('last_seen_at');
  set lastSeenAt(DateTime? value) => setField<DateTime>('last_seen_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
