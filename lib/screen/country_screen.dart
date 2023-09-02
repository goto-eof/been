import 'package:been/dao/city_dao.dart';
import 'package:been/dao/country_dao.dart';
import 'package:been/dao/pin_dao.dart.dart';
import 'package:been/dao/district_dao.dart';
import 'package:been/model/city.dart';
import 'package:been/model/country.dart';
import 'package:been/model/pin.dart';
import 'package:been/model/district.dart';
import 'package:been/screen/pin_retriever_screen.dart';
import 'package:been/screen/region_screen.dart';
import 'package:been/widget/info_widget/count_cities_info_widget.dart';
import 'package:been/widget/info_widget/count_countries_info_widget.dart';
import 'package:been/widget/info_widget/count_districts_info_widget.dart';
import 'package:been/widget/info_widget/count_pins_info_widget.dart';
import 'package:been/widget/info_widget/total_countries_info_widget.dart';
import 'package:been/widget/map/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:been/widget/about_dialog.dart' as BeenAboutDialog;

class CountryScreen extends StatefulWidget {
  const CountryScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CountryScreenState();
  }
}

class _CountryScreenState extends State<CountryScreen> {
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
        setState(() {});
      } catch (err) {
        print(err);
      }
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

  _goToRegions(Country country) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegionScreen(
          country: country,
        ),
      ),
    );

    List<int> citiesIdsToDelete = await CityDao().retrieveCitiesToDelete();
    for (final int id in citiesIdsToDelete) {
      await CityDao().delete(id);
    }

    List<int> districtIdsToDelete =
        await DistrictDao().retrieveDistrictsToDelete();
    for (final int id in districtIdsToDelete) {
      await DistrictDao().delete(id);
    }

    List<int> countriesIdsToDelete =
        await CountryDao().retrieveCountriesToDelete();
    for (final int id in countriesIdsToDelete) {
      await CountryDao().delete(id);
    }

    setState(() {});
  }

  Widget _aboutDialogBuilder(BuildContext context, final String version) {
    return BeenAboutDialog.AboutDialog(
      applicationName: "Been!",
      applicationSnapName: "been",
      applicationIcon: SizedBox(
          width: 64, height: 64, child: Image.asset("assets/images/been.png")),
      applicationVersion: version,
      applicationLegalese: "GNU GENERAL PUBLIC LICENSE Version 3",
      applicationDeveloper: "Andrei Dodu",
    );
  }

  Future<List<Country>> _loadCountries() async {
    try {
      CountryDao countryDao = CountryDao();
      List<Country> countries = await countryDao.list();
      for (Country country in countries) {
        int? regionNumber = await countryDao.getRegionsCount(country.name);
        if (regionNumber != null) {
          country.numberOfChilds = regionNumber;
        }
      }

      return countries;
    } catch (err) {
      print(err);
      return [];
    }
  }

  Widget _countriesBuilder(
      BuildContext ctx, AsyncSnapshot<List<Country>> snapshot) {
    if (snapshot.hasData) {
      if (snapshot.data!.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            const Text("No data found"),
            const SizedBox(
              height: 10,
            ),
            FilledButton(
              onPressed: _chooseAPlace,
              child: const Text(
                "Add new Place that you visited",
              ),
            ),
          ],
        );
      }

      return ListView.builder(
        itemBuilder: (BuildContext ctx, int index) {
          return Card(
            child: InkWell(
              onTap: () {
                _goToRegions(snapshot.data![index]);
              },
              child: ListTile(
                leading: const Icon(Icons.square),
                title: Text(
                  snapshot.data![index].name,
                ),
                subtitle: const Text("Nation"),
                trailing: Text(
                  "(${snapshot.data![index].numberOfChilds.toString()})",
                ),
              ),
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

  Future<List<Pin>> _mapMarkers() async {
    List<Pin> pins = await PinDao().listAll();
    debugPrint("Updateting pins: $pins");
    return pins;
  }

  Widget _mapBuilder(BuildContext ctx, AsyncSnapshot<List<Pin>> snapshot) {
    if (snapshot.hasData) {
      return MapWidget(
        currentPosition: Pin(
          longitude: 0,
          latitude: 0,
          address: "",
        ),
        zoom: 2,
        markers: snapshot.data,
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
        title: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: Image.asset("assets/images/been.png"),
              ),
              const SizedBox(
                width: 5,
              ),
              const Text(
                "Been! ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                PackageInfo.fromPlatform().then((value) => showDialog(
                    context: context,
                    builder: (ctx) {
                      return _aboutDialogBuilder(ctx, value.version);
                    }));
              },
              icon: const Icon(Icons.help)),
          IconButton(onPressed: _chooseAPlace, icon: const Icon(Icons.add))
        ],
      ),
      // drawer: const Drawer(),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder(
                  future: _mapMarkers(),
                  builder: _mapBuilder,
                ),
                Expanded(
                  child: GridView(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                    children: [
                      _infoPane(
                          TotalCountriesInfoWidget().pieChartTotalCountries()),
                      _infoPane(CountCountriesInfoWidget().countriesWidget()),
                      _infoPane(CountDistrictsInfoWidget().districtsWidget()),
                      _infoPane(CountCitiesInfoWidget().citiesWidget()),
                      _infoPane(CountPinsInfoWidget().pinsWidget()),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: FutureBuilder<List<Country>>(
                    future: _loadCountries(),
                    builder: _countriesBuilder,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoPane(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            end: Alignment.bottomRight,
            begin: Alignment.topLeft,
            colors: [
              Color.fromARGB(28, 179, 179, 179),
              Color.fromARGB(32, 206, 206, 206)
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}
