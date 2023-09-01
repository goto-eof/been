import 'package:been/dao/city_dao.dart';
import 'package:been/dao/country_dao.dart';
import 'package:been/dao/pin_dao.dart.dart';
import 'package:been/dao/region_dao.dart';
import 'package:been/model/city.dart';
import 'package:been/model/country.dart';
import 'package:been/model/pin.dart';
import 'package:been/model/region.dart';
import 'package:been/screen/pin_retriever_screen.dart';
import 'package:been/screen/region_screen.dart';
import 'package:flutter/material.dart';

class CountryScreen extends StatefulWidget {
  const CountryScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CountryScreenState();
  }
}

class _CountryScreenState extends State<CountryScreen> {
  List<Pin> places = [];

  _chooseAPlace() async {
    Pin? pin =
        await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return const PinRetrieverScreen();
    }));
    if (pin != null) {
      try {
        int countryId = await _insertOrRetrieveCountryId(pin);

        int regionId = await _insertOrRetrieveRegionId(pin, countryId);

        int cityId = await _insertOrRetrieveCityId(pin, regionId);

        await _insertOrRetrievePinId(pin, cityId);
      } catch (err) {
        print(err);
      }
      setState(() {
        places.add(pin);
      });
    }
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

    City city = City(name: pin.cityName, regionId: regionId);
    int cityId = await cityDao.insert(city);
    return cityId;
  }

  Future<int> _insertOrRetrieveRegionId(Pin pin, int countryId) async {
    RegionDao regionDao = RegionDao();

    Region? existingRegion =
        await regionDao.getByRegionNameAndCountryId(pin.regionName, countryId);

    if (existingRegion != null) {
      return existingRegion.id!;
    }

    Region region = Region(name: pin.regionName, countryId: countryId);
    int regionId = await regionDao.insert(region);
    return regionId;
  }

  Future<int> _insertOrRetrieveCountryId(Pin pin) async {
    CountryDao countryDao = CountryDao();

    Country? existingCountry = await countryDao.getByName(pin.countryName);
    if (existingCountry != null) {
      return existingCountry.id!;
    }
    Country country = Country(name: pin.countryName);
    int countryId = await countryDao.insert(country);
    return countryId;
  }

  _goToRegions(Country country) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegionScreen(
          country: country,
        ),
      ),
    );
  }

  Future<List<Country>> _loadCountries() async {
    CountryDao countryDao = CountryDao();
    try {
      return await countryDao.list();
    } catch (err) {
      print(err);
      return [];
    }
  }

  Widget _builder(BuildContext ctx, AsyncSnapshot<List<Country>> snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        itemBuilder: (BuildContext ctx, int index) {
          return Card(
            child: Row(
              children: [
                InkWell(
                    onTap: () {
                      _goToRegions(snapshot.data![index]);
                    },
                    child: Card(child: Text(snapshot.data![index].name)))
              ],
            ),
          );
        },
        itemCount: snapshot.data!.length,
      );
    }

    if (snapshot.hasError) {
      return const Center(
        child: Text("Error"),
      );
    }
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Been! "),
        actions: [
          IconButton(onPressed: _chooseAPlace, icon: const Icon(Icons.add))
        ],
      ),
      drawer: const Drawer(),
      body: FutureBuilder<List<Country>>(
        future: _loadCountries(),
        builder: _builder,
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: 0,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.abc), label: "Cioa"),
      //     BottomNavigationBarItem(icon: Icon(Icons.abc), label: "Yahoo")
      //   ],
      // ),
    );
  }
}
