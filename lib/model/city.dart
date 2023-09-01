class City {
  City(
      {this.id,
      required this.name,
      this.insertDateTime,
      required this.regionId});
  int? id;
  String name;
  DateTime? insertDateTime;
  int regionId;

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "region_id": regionId,
      "insert_date_time": DateTime.now().toIso8601String()
    };
  }
}
