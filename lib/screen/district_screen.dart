import 'package:been/dao/district_dao.dart';
import 'package:been/dao/pin_dao.dart.dart';
import 'package:been/model/country_full_data.dart';
import 'package:been/model/district.dart';
import 'package:been/model/key_value.dart';
import 'package:been/model/pin.dart';
import 'package:been/screen/city_screen.dart';
import 'package:been/widget/map/map_widget.dart';
import 'package:flutter/material.dart';

class DistrictScreen extends StatefulWidget {
  const DistrictScreen({super.key, required this.country});
  final CountryFullData country;

  @override
  State<StatefulWidget> createState() {
    return _DistrictScreenState();
  }
}

class _DistrictScreenState extends State<DistrictScreen> {
  @override
  initState() {
    super.initState();
  }

  Future<KeyValue<List<District>, List<Pin>>> _retrieveRegions() async {
    final String countryName = widget.country.name;
    try {
      DistrictDao regionDao = DistrictDao();
      List<District> regions = await regionDao.list(countryName);

      for (District region in regions) {
        int countCities = await regionDao.getCitiesCount(region.id!);
        region.numberOfChilds = countCities;
      }
      List<Pin> pins = await PinDao().byCountry(widget.country.id!);
      return KeyValue<List<District>, List<Pin>>(key: regions, value: pins);
    } catch (err) {
      print(err);
      return KeyValue(key: [], value: []);
    }
  }

  Widget _builder(
      context, AsyncSnapshot<KeyValue<List<District>, List<Pin>>> snapshot) {
    if (snapshot.hasData) {
      List<District> districts = snapshot.data!.key;
      List<Pin> pins = snapshot.data!.value!;

      Pin pin = Pin(
          longitude: widget.country.latlng[1],
          latitude: widget.country.latlng[0],
          address: widget.country.capital);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    width: double.infinity,
                    height: 300,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MapWidget(
                          zoom: 5,
                          markers: pins,
                          currentPosition: pin,
                        ),
                      ],
                    ),
                  ),
                  _keyValueWidget("Country", widget.country.name),
                  _keyValueWidget(
                    "Flag",
                    Image.asset(
                      width: 32,
                      "assets/images/flags/${widget.country.cca2.toLowerCase()}.png",
                    ),
                  ),
                  _keyValueWidget("Capital", widget.country.capital),
                  _keyValueWidget("CCA2", widget.country.cca2),
                  _keyValueWidget(
                      "Latitude/Longitude", widget.country.latlng.join(", ")),
                  _keyValueWidget("Region", widget.country.region),
                  _keyValueWidget("Subregion", widget.country.subregion),
                  _keyValueWidget("Languages",
                      widget.country.languages.map((e) => e.value).join(", ")),
                  _keyValueWidget("Currencies",
                      widget.country.currencies.map((e) => e.value).join(", ")),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Districts",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground),
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (BuildContext ctx, int index) {
                      return Card(
                        child: InkWell(
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CityScreen(
                                  region: districts[index],
                                ),
                              ),
                            );
                            setState(() {});
                          },
                          child: ListTile(
                            leading: const Icon(Icons.square),
                            subtitle: const Text("District"),
                            title: Text(
                              districts[index].name,
                            ),
                            trailing: Text(
                              "(${districts[index].numberOfChilds.toString()})",
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: districts.length,
                  ),
                ),
              ],
            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.country.name),
      ),
      body: FutureBuilder(
        builder: _builder,
        future: _retrieveRegions(),
      ),
    );
  }

  Widget _keyValueWidget<T>(String key, T value) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text("$key:"),
              const SizedBox(
                width: 5,
              ),
              value is Widget ? value : Expanded(child: Text(value as String)),
            ],
          ),
        ),
      ),
    );
  }
}
