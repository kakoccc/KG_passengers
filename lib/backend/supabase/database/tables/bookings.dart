import '../database.dart';

class BookingsTable extends SupabaseTable<BookingsRow> {
  @override
  String get tableName => 'bookings';

  @override
  BookingsRow createRow(Map<String, dynamic> data) => BookingsRow(data);
}

class BookingsRow extends SupabaseDataRow {
  BookingsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BookingsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get tripId => getField<String>('trip_id');
  set tripId(String? value) => setField<String>('trip_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  int get seatNumber => getField<int>('seat_number')!;
  set seatNumber(int value) => setField<int>('seat_number', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  bool? get hasLuggage => getField<bool>('has_luggage');
  set hasLuggage(bool? value) => setField<bool>('has_luggage', value);

  int? get passengerCount => getField<int>('passenger_count');
  set passengerCount(int? value) => setField<int>('passenger_count', value);

  String? get userComment => getField<String>('user_comment');
  set userComment(String? value) => setField<String>('user_comment', value);

  String? get adminComment => getField<String>('admin_comment');
  set adminComment(String? value) => setField<String>('admin_comment', value);

  double get totalPrice => getField<double>('total_price')!;
  set totalPrice(double value) => setField<double>('total_price', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
