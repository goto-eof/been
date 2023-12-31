class Country {
  Country(
      {this.id,
      required this.name,
      this.insertDateTime,
      required this.numberOfChilds});
  int? id;
  String name;
  DateTime? insertDateTime;
  int numberOfChilds = 0;

  Map<String, String> toMap() {
    return {"name": name, "insert_date_time": DateTime.now().toIso8601String()};
  }
}
