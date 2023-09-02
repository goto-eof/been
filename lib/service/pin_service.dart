import 'package:been/dao/city_dao.dart';
import 'package:been/dao/country_dao.dart';
import 'package:been/dao/district_dao.dart';
import 'package:been/dao/pin_dao.dart.dart';
import 'package:been/model/city.dart';
import 'package:been/model/country.dart';
import 'package:been/model/district.dart';
import 'package:been/model/pin.dart';

class PinService {
  Future<void> insertPin(Pin pin) async {
    int countryId = await _insertOrRetrieveCountryId(pin);

    int regionId = await _insertOrRetrieveRegionId(pin, countryId);

    int cityId = await _insertOrRetrieveCityId(pin, regionId);

    await _insertOrRetrievePinId(pin, cityId);
  }

  Future<void> _insertOrRetrievePinId(Pin pin, int cityId) async {
    PinDao pinDao = PinDao();
    Pin? existingPin = await pinDao.getByLatLong(pin.latitude, pin.longitude);

    if (existingPin != null) {
      return;
    }
    pin.cityId = cityId;
    await pinDao.insert(pin);
  }

  Future<int> _insertOrRetrieveCityId(Pin pin, int regionId) async {
    CityDao cityDao = CityDao();
    City? existingCity =
        await cityDao.getByCityNameAndRegionId(pin.city!, regionId);
    if (existingCity != null) {
      return existingCity.id!;
    }

    City city = City(name: pin.cityName, regionId: regionId, numberOfChilds: 0);
    int cityId = await cityDao.insert(city);
    return cityId;
  }

  Future<int> _insertOrRetrieveRegionId(Pin pin, int countryId) async {
    DistrictDao regionDao = DistrictDao();

    District? existingRegion =
        await regionDao.getByRegionNameAndCountryId(pin.regionName, countryId);

    if (existingRegion != null) {
      return existingRegion.id!;
    }

    District region =
        District(name: pin.regionName, countryId: countryId, numberOfChilds: 0);
    int regionId = await regionDao.insert(region);
    return regionId;
  }

  Future<int> _insertOrRetrieveCountryId(Pin pin) async {
    CountryDao countryDao = CountryDao();

    Country? existingCountry = await countryDao.getByName(pin.countryName);
    if (existingCountry != null) {
      return existingCountry.id!;
    }
    Country country = Country(name: pin.countryName, numberOfChilds: 0);
    int countryId = await countryDao.insert(country);
    return countryId;
  }
}
