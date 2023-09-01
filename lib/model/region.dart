class Region {
  Region(
      {this.id,
      required this.name,
      this.insertDateTime,
      required this.countryId});
  int? id;
  String name;
  DateTime? insertDateTime;
  int countryId;

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "country_id": countryId,
      "insert_date_time": DateTime.now().toIso8601String()
    };
  }
}
