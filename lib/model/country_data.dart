import 'package:been/model/key_value.dart';

class CountryData {
  CountryData(
      {required this.commonName,
      required this.officialName,
      required this.tld,
      required this.independent,
      required this.capital,
      required this.region,
      required this.subregion,
      required this.languages,
      required this.latlng,
      required this.currencies,
      required this.cca2});
  String commonName;
  String officialName;
  String tld;
  bool independent;
  String capital;
  String region;
  String subregion;
  Set<KeyValue<String, String>> languages;
  List<double> latlng;
  Set<KeyValue<String, String>> currencies;
  String cca2;
}
