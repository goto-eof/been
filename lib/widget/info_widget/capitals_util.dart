import 'dart:convert';

import 'package:been/model/key_value.dart';
import 'package:flutter/services.dart';

class CapitalsUtil {
  Future<List<KeyValue<String, String>>> loadCapitals() async {
    final String response =
        await rootBundle.loadString('assets/json/capitals.geojson');
    final data = await jsonDecode(response);
    List<dynamic> capitals = data["features"] as List;
    List<KeyValue<String, String>> result = [];
    for (dynamic capital in capitals) {
      final String country = capital["properties"]["country"] as String;
      final String? city = capital["properties"]["city"] as String?;
      result.add(KeyValue(key: country, value: city));
    }
    return result;
  }

  Future<List<KeyValue<String, String>>> loadCountries() async {
    final String response =
        await rootBundle.loadString('assets/json/countries.json');
    final data = await jsonDecode(response);
    List<KeyValue<String, String>> countryCapitalList = [];
    for (dynamic country in data as List<dynamic>) {
      final String countryName = country["name"]["common"];
      final String countryCapital = country["capital"][0];
      countryCapitalList.add(KeyValue(key: countryName, value: countryCapital));
    }
    return countryCapitalList;
  }
}
