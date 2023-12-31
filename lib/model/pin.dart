class Pin {
  Pin(
      {this.id,
      required this.longitude,
      required this.latitude,
      required this.address,
      this.cityId,
      this.insertDateTime,
      this.name,
      this.city,
      this.region,
      this.country});
  int? id;
  double longitude;
  double latitude;
  String address;
  int? cityId;
  String? name;

  String? city;
  String? country;
  String? region;

  String get cityName {
    // List<String> splitted = address.split(",");
    // return splitted[splitted.length - 3];
    return city!;
  }

  String get countryName {
    // List<String> splitted = address.split(",");
    // return splitted[splitted.length - 1];
    return country!;
  }

  String get regionName {
    // List<String> splitted = address.split(",");
    // return splitted[splitted.length - 2];
    return region!;
  }

  DateTime? insertDateTime;

  Map<String, dynamic> toMap() {
    return {
      "city_id": cityId,
      "insert_date_time": DateTime.now().toIso8601String(),
      "address": address,
      "latitude": latitude,
      "longitude": longitude
    };
  }
}
