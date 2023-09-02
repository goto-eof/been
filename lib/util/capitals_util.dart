import 'dart:convert';

import 'package:been/model/country_data.dart';
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
      final bool independent = country["independent"] ?? false;
      if (independent) {
        countryCapitalList
            .add(KeyValue(key: countryName, value: countryCapital));
      }
    }
    return countryCapitalList;
  }

  Future<List<CountryData>> loadCountriesData() async {
    final String response =
        await rootBundle.loadString('assets/json/countries.json');
    final data = await jsonDecode(response);
    List<CountryData> countryCapitalList = [];
    for (dynamic country in data as List<dynamic>) {
      final String commonName = country["name"]["common"];
      final String officialName = country["name"]["official"];
      final String capital = country["capital"][0];
      final String tld = country["tld"][0];
      final String region = country["region"];
      final String subregion = country["subregion"];
      final List<double> latlng = (country["latlng"] as List<dynamic>)
          .map((e) => double.parse(e.toString()))
          .toList();
      final bool independent = country["independent"] ;
      print(country["languages"]);
      final Map<String, dynamic> languagesMap = country["languages"];
      final Set<KeyValue<String, String>> languages = languagesMap.entries
          .map((e) => KeyValue(key: e.key, value: e.value as String))
          .toSet();

      final Map<String, dynamic> currenciesMap = country["currencies"];
      Set<KeyValue<String, String>> currencies = Set();
      if (currenciesMap.entries.isNotEmpty) {
        currencies = currenciesMap.entries
            .map((currency) => KeyValue(
                key: currency.key,
                value: currenciesMap[currency.key]["name"] as String))
            .toSet();
      }
      countryCapitalList.add(CountryData(
          commonName: commonName,
          officialName: officialName,
          tld: tld,
          independent: independent,
          capital: capital,
          region: region,
          subregion: subregion,
          languages: languages,
          latlng: latlng,
          currencies: currencies));
    }
    return countryCapitalList;
  }
}
