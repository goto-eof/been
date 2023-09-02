import 'package:been/dao/city_dao.dart';
import 'package:been/dao/country_dao.dart';
import 'package:been/dao/district_dao.dart';
import 'package:been/dao/pin_dao.dart.dart';
import 'package:been/model/country_data.dart';
import 'package:been/model/pin.dart';
import 'package:been/service/pin_service.dart';
import 'package:been/util/country_util.dart';

class DemoDataUtil {
  void _demoData() async {
    PinDao().truncate();
    CityDao().truncate();
    DistrictDao().truncate();
    CountryDao().truncate();

    List<CountryData> data = await CountryUtil().loadCountriesData();
    data.where((element) => element.independent).forEach((country) async {
      await PinService().insertPin(
        Pin(
          country: country.commonName,
          city: country.capital,
          region: "Unknown",
          longitude: country.latlng[1],
          latitude: country.latlng[0],
          address: country.capital.isNotEmpty ? country.capital : "Unknown",
        ),
      );
    });
  }
}
