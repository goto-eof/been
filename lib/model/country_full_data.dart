import 'package:been/model/country.dart';
import 'package:been/model/key_value.dart';

class CountryFullData extends Country {
  CountryFullData(
      {required super.id,
      required super.insertDateTime,
      required super.name,
      required super.numberOfChilds,
      required this.capital,
      required this.region,
      required this.subregion,
      required this.languages,
      required this.latlng,
      required this.currencies,
      required this.cca2});

  String capital;
  String region;
  String subregion;
  Set<KeyValue<String, String>> languages;
  List<double> latlng;
  Set<KeyValue<String, String>> currencies;
  String cca2;

  CountryFullData.empty()
      : capital = "",
        region = "",
        subregion = "",
        languages = Set(),
        latlng = [],
        currencies = Set(),
        cca2 = "",
        super(
            name: "", numberOfChilds: 0, id: 0, insertDateTime: DateTime.now());
}
