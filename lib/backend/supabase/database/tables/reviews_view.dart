import '../database.dart';

class ReviewsViewTable extends SupabaseTable<ReviewsViewRow> {
  @override
  String get tableName => 'reviews_view';

  @override
  ReviewsViewRow createRow(Map<String, dynamic> data) => ReviewsViewRow(data);
}

class ReviewsViewRow extends SupabaseDataRow {
  ReviewsViewRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ReviewsViewTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  int get rating => getField<int>('rating')!;
  set rating(int value) => setField<int>('rating', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String get comment => getField<String>('comment')!;
  set comment(String value) => setField<String>('comment', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get firstName => getField<String>('first_name');
  set firstName(String? value) => setField<String>('first_name', value);

  String? get avatarUrl => getField<String>('avatar_url');
  set avatarUrl(String? value) => setField<String>('avatar_url', value);
}
