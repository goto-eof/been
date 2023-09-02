import 'package:been/dao/district_dao.dart';
import 'package:been/model/country_full_data.dart';
import 'package:been/model/district.dart';
import 'package:been/screen/city_screen.dart';
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
  Future<List<District>> _retrieveRegions() async {
    final String countryName = widget.country.name;
    try {
      DistrictDao regionDao = DistrictDao();
      List<District> regions = await regionDao.list(countryName);

      for (District region in regions) {
        int countCities = await regionDao.getCitiesCount(region.id!);
        region.numberOfChilds = countCities;
      }

      return regions;
    } catch (err) {
      print(err);
      return [];
    }
  }

  Widget _builder(context, snapshot) {
    if (snapshot.hasData) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 100.0, right: 100, bottom: 50),
                    child: Image.asset(
                      "assets/images/flags-1000/${widget.country.cca2.toLowerCase()}.png",
                    ),
                  ),
                  _keyValueWidget("Country", widget.country.name),
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
                                  region: snapshot.data[index],
                                ),
                              ),
                            );
                            setState(() {});
                          },
                          child: ListTile(
                            leading: const Icon(Icons.square),
                            subtitle: const Text("District"),
                            title: Text(
                              snapshot.data![index].name,
                            ),
                            trailing: Text(
                              "(${snapshot.data![index].numberOfChilds.toString()})",
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: snapshot.data!.length,
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

  Widget _keyValueWidget(String key, String value) {
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
              Expanded(child: Text(value)),
            ],
          ),
        ),
      ),
    );
  }
}
