import '../database.dart';

class TripsViewTable extends SupabaseTable<TripsViewRow> {
  @override
  String get tableName => 'trips_view';

  @override
  TripsViewRow createRow(Map<String, dynamic> data) => TripsViewRow(data);
}

class TripsViewRow extends SupabaseDataRow {
  TripsViewRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TripsViewTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  double? get ticketPrice => getField<double>('ticket_price');
  set ticketPrice(double? value) => setField<double>('ticket_price', value);

  int? get totalSeats => getField<int>('total_seats');
  set totalSeats(int? value) => setField<int>('total_seats', value);

  int? get availableSeats => getField<int>('available_seats');
  set availableSeats(int? value) => setField<int>('available_seats', value);

  DateTime? get departureDate => getField<DateTime>('departure_date');
  set departureDate(DateTime? value) =>
      setField<DateTime>('departure_date', value);

  PostgresTime? get departureTimeOnly =>
      getField<PostgresTime>('departure_time_only');
  set departureTimeOnly(PostgresTime? value) =>
      setField<PostgresTime>('departure_time_only', value);

  String? get adminNote => getField<String>('admin_note');
  set adminNote(String? value) => setField<String>('admin_note', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get originCityName => getField<String>('origin_city_name');
  set originCityName(String? value) =>
      setField<String>('origin_city_name', value);

  String? get destinationCityName => getField<String>('destination_city_name');
  set destinationCityName(String? value) =>
      setField<String>('destination_city_name', value);

  int? get distanceKm => getField<int>('distance_km');
  set distanceKm(int? value) => setField<int>('distance_km', value);

  String? get travelTime => getField<String>('travel_time');
  set travelTime(String? value) => setField<String>('travel_time', value);

  DateTime? get calculatedArrivalTime =>
      getField<DateTime>('calculated_arrival_time');
  set calculatedArrivalTime(DateTime? value) =>
      setField<DateTime>('calculated_arrival_time', value);

  String? get carName => getField<String>('car_name');
  set carName(String? value) => setField<String>('car_name', value);

  String? get carImage => getField<String>('car_image');
  set carImage(String? value) => setField<String>('car_image', value);
}
