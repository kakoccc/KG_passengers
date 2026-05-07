import '../database.dart';

class TripsTable extends SupabaseTable<TripsRow> {
  @override
  String get tableName => 'trips';

  @override
  TripsRow createRow(Map<String, dynamic> data) => TripsRow(data);
}

class TripsRow extends SupabaseDataRow {
  TripsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TripsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  String? get originCityId => getField<String>('origin_city_id');
  set originCityId(String? value) => setField<String>('origin_city_id', value);

  String? get destinationCityId => getField<String>('destination_city_id');
  set destinationCityId(String? value) =>
      setField<String>('destination_city_id', value);

  double get ticketPrice => getField<double>('ticket_price')!;
  set ticketPrice(double value) => setField<double>('ticket_price', value);

  int get totalSeats => getField<int>('total_seats')!;
  set totalSeats(int value) => setField<int>('total_seats', value);

  String? get adminNote => getField<String>('admin_note');
  set adminNote(String? value) => setField<String>('admin_note', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get carId => getField<String>('car_id');
  set carId(String? value) => setField<String>('car_id', value);

  DateTime? get departureDate => getField<DateTime>('departure_date');
  set departureDate(DateTime? value) =>
      setField<DateTime>('departure_date', value);

  PostgresTime? get departureTimeOnly =>
      getField<PostgresTime>('departure_time_only');
  set departureTimeOnly(PostgresTime? value) =>
      setField<PostgresTime>('departure_time_only', value);
}
