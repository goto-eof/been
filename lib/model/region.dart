class Region {
  Region({
    this.id,
    required this.name,
    this.insertDateTime,
    required this.countryId,
    required this.numberOfChilds,
  });
  int? id;
  String name;
  DateTime? insertDateTime;
  int countryId;
  int numberOfChilds;

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "country_id": countryId,
      "insert_date_time": DateTime.now().toIso8601String()
    };
  }
}
