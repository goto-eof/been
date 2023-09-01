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
import 'package:been/widget/map/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

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
    setState(() {});
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
        leading: SizedBox(
          width: 24,
          height: 24,
          child: Image.asset("assets/images/been.png"),
        ),
        title: const Text("Been! "),
        actions: [
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
                      _infoPane(_pieChartTotalCountries()),
                      _infoPane(_countriesWidget()),
                      _infoPane(_districtsWidget()),
                      _infoPane(_citiesWidget()),
                      _infoPane(_pinsWidget()),
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

  Widget _citiesWidget() {
    return FutureBuilder(future: _countCities(), builder: _countCitiesBuilder);
  }

  Future<int> _countCities() async {
    return await CityDao().count();
  }

  Widget _countCitiesBuilder(BuildContext ctx, AsyncSnapshot<int> snapshot) {
    if (snapshot.hasData) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_city,
                size: 100,
                color: Colors.green,
              ),
              Column(
                children: [
                  Text(
                    snapshot.data!.toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 52),
                  ),
                  const Text(
                    "Cities",
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
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

  Widget _districtsWidget() {
    return FutureBuilder(
        future: _countDistricts(), builder: _countDistrictBuilder);
  }

  Future<int> _countDistricts() async {
    return await DistrictDao().count();
  }

  Widget _countDistrictBuilder(BuildContext ctx, AsyncSnapshot<int> snapshot) {
    if (snapshot.hasData) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_activity,
                size: 100,
                color: Colors.blue,
              ),
              Column(
                children: [
                  Text(
                    snapshot.data!.toString(),
                    style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 52),
                  ),
                  const Text(
                    "Districts",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
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

  Widget _pinsWidget() {
    return FutureBuilder(future: _countPins(), builder: _countPinsBuilder);
  }

  Future<int> _countPins() async {
    return await PinDao().count();
  }

  Widget _countPinsBuilder(BuildContext ctx, AsyncSnapshot<int> snapshot) {
    if (snapshot.hasData) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_history,
                  size: 100, color: Color.fromARGB(255, 244, 143, 54)),
              Column(
                children: [
                  Text(
                    snapshot.data!.toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 244, 143, 54),
                        fontSize: 52),
                  ),
                  const Text(
                    "Pins",
                    style: TextStyle(
                      color: Color.fromARGB(255, 244, 143, 54),
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
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

  Widget _countriesWidget() {
    return FutureBuilder(
        future: _countCountries(), builder: _countCountriesBuilder);
  }

  Future<int> _countCountries() async {
    return await CountryDao().count();
  }

  Widget _countCountriesBuilder(BuildContext ctx, AsyncSnapshot<int> snapshot) {
    if (snapshot.hasData) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.flag,
                size: 100,
                color: Color.fromARGB(255, 149, 54, 244),
              ),
              Column(
                children: [
                  Text(
                    snapshot.data!.toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 149, 54, 244),
                        fontSize: 52),
                  ),
                  const Text(
                    "Countries",
                    style: TextStyle(
                      color: Color.fromARGB(255, 149, 54, 244),
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
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

  Widget _pieChartTotalCountries() {
    return FutureBuilder(
      builder: _totalCountriesBuilder,
      future: _totalCountriesCount(),
    );
  }

  Future<int> _totalCountriesCount() async {
    return await CountryDao().count();
  }

  Widget _totalCountriesBuilder(BuildContext ctx, AsyncSnapshot<int> snapshot) {
    if (snapshot.hasData) {
      Map<String, double> dataMap = {
        "Unvisited countries": double.parse((195 - snapshot.data!).toString()),
        "Visited countries": double.parse(snapshot.data.toString()),
      };

      // Colors for each segment
      // of the pie chart
      List<Color> colorList = [
        const Color(0xffD95AF3),
        const Color(0xff3EE094),
        const Color(0xff3398F6),
        const Color(0xffFA4A42),
        const Color(0xffFE9539)
      ];

      // List of gradients for the
      // background of the pie chart
      final gradientList = <List<Color>>[
        [
          const Color.fromRGBO(255, 0, 0, 1),
          const Color.fromRGBO(253, 113, 91, 1),
        ],
        [
          const Color.fromRGBO(223, 250, 92, 1),
          const Color.fromRGBO(129, 250, 112, 1),
        ],
      ];
      return Center(
        child: PieChart(
          // Pass in the data for
          // the pie chart
          dataMap: dataMap,
          // Set the colors for the
          // pie chart segments
          colorList: colorList,
          // Set the radius of the pie chart
          chartRadius: 200,
          // Set the center text of the pie chart
          centerText: "Countries",
          // Set the width of the
          // ring around the pie chart
          ringStrokeWidth: 24,
          // Set the animation duration of the pie chart
          animationDuration: const Duration(seconds: 3),
          // Set the options for the chart values (e.g. show percentages, etc.)
          chartValuesOptions: const ChartValuesOptions(
              showChartValues: true,
              showChartValuesOutside: true,
              showChartValuesInPercentage: true,
              showChartValueBackground: true),
          // Set the options for the legend of the pie chart
          legendOptions: const LegendOptions(
              showLegends: true,
              legendShape: BoxShape.circle,
              legendTextStyle: TextStyle(fontSize: 10),
              legendPosition: LegendPosition.top,
              showLegendsInRow: true),
          // Set the list of gradients for
          // the background of the pie chart
          gradientList: gradientList,
        ),
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
}
