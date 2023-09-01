class Country {
  Country({this.id, required this.name, this.insertDateTime});
  int? id;
  String name;
  DateTime? insertDateTime;

  Map<String, String> toMap() {
    return {"name": name, "insert_date_time": DateTime.now().toIso8601String()};
  }
}
