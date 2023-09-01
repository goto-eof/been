class City {
  City({
    this.id,
    required this.name,
    this.insertDateTime,
    required this.regionId,
    required this.numberOfChilds,
  });
  int? id;
  String name;
  DateTime? insertDateTime;
  int regionId;
  int numberOfChilds;

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "region_id": regionId,
      "insert_date_time": DateTime.now().toIso8601String()
    };
  }
}
