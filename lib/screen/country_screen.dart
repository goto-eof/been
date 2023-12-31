import 'dart:io';
import 'dart:typed_data';

import 'package:been/dao/city_dao.dart';
import 'package:been/dao/country_dao.dart';
import 'package:been/dao/pin_dao.dart.dart';
import 'package:been/dao/district_dao.dart';
import 'package:been/model/country.dart';
import 'package:been/model/country_data.dart';
import 'package:been/model/country_full_data.dart';
import 'package:been/model/pin.dart';
import 'package:been/screen/common_wrappers.dart';
import 'package:been/screen/pin_retriever_screen.dart';
import 'package:been/screen/district_screen.dart';
import 'package:been/service/export/file_content_generator.dart';
import 'package:been/service/import/file_content_loader.dart';
import 'package:been/service/pin_service.dart';
import 'package:been/util/country_util.dart';
import 'package:been/widget/info_widget/count_cities_info_widget.dart';
import 'package:been/widget/info_widget/count_countries_info_widget.dart';
import 'package:been/widget/info_widget/count_districts_info_widget.dart';
import 'package:been/widget/info_widget/count_pins_info_widget.dart';
import 'package:been/widget/info_widget/count_regions_info_widget.dart';
import 'package:been/widget/info_widget/total_capitals_info_widget.dart';
import 'package:been/widget/info_widget/total_countries_info_widget.dart';
import 'package:been/widget/map/map_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:been/widget/about_dialog.dart' as been_about_dialog;

class CountryScreen extends StatefulWidget {
  const CountryScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CountryScreenState();
  }
}

class _CountryScreenState extends State<CountryScreen> {
  static final countriesJson = CountryUtil().loadCountriesData();

  @override
  initState() {
    super.initState();

    //PinService().demoData();
    // DevUtil().writeAssetsImagesFlags();
  }

  _chooseAPlace() async {
    Pin? pin =
        await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return const PinRetrieverScreen();
    }));
    if (pin != null) {
      try {
        await PinService().insertPin(pin);
        setState(() {});
      } catch (err) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Something went wrong")));
      }
    }
  }

  _goToRegions(CountryFullData country) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DistrictScreen(
          country: country,
        ),
      ),
    );

    try {
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
    } catch (err) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }
    setState(() {});
  }

  Widget _aboutDialogBuilder(BuildContext context, final String version) {
    return been_about_dialog.AboutDialog(
      applicationName: "Been!",
      applicationSnapName: "been",
      applicationIcon: SizedBox(
          width: 64, height: 64, child: Image.asset("assets/images/been.png")),
      applicationVersion: version,
      applicationLegalese: "GNU GENERAL PUBLIC LICENSE Version 3",
      applicationDeveloper: "Andrei Dodu",
    );
  }

  Future<List<CountryFullData>> _loadCountries() async {
    try {
      CountryDao countryDao = CountryDao();
      List<Country> countries = await countryDao.list();
      for (Country country in countries) {
        int? regionNumber = await countryDao.getRegionsCount(country.name);
        if (regionNumber != null) {
          country.numberOfChilds = regionNumber;
        }
      }

      List<CountryData> countriesFromJson = (await countriesJson);

      List<CountryFullData> countriesFullData = countries.map((country) {
        CountryData? foundCountryData = countriesFromJson
            .where((coutntryFromJson) =>
                coutntryFromJson.commonName.toLowerCase() ==
                country.name.toLowerCase())
            .firstOrNull;
        CountryData dummy = CountryData.empty();
        return CountryFullData(
            id: country.id,
            insertDateTime: country.insertDateTime,
            name: country.name,
            numberOfChilds: country.numberOfChilds,
            capital: (foundCountryData ?? dummy).capital,
            region: (foundCountryData ?? dummy).region,
            subregion: (foundCountryData ?? dummy).subregion,
            languages: (foundCountryData ?? dummy).languages,
            latlng: (foundCountryData ?? dummy).latlng,
            currencies: (foundCountryData ?? dummy).currencies,
            cca2: (foundCountryData ?? dummy).cca2);
      }).toList();

      return countriesFullData;
    } catch (err) {
      print(err);
      return [];
    }
  }

  Widget _countriesBuilder(
      BuildContext ctx, AsyncSnapshot<List<CountryFullData>> snapshot) {
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
                leading: Image.asset(
                  "assets/images/flags/${snapshot.data![index].cca2.toLowerCase()}.png",
                  width: 48,
                ),
                title: Text(
                  snapshot.data![index].name,
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Text(
                          "Nation of ${snapshot.data![index].region} (${snapshot.data![index].subregion}), capital ${snapshot.data![index].capital}, languages ${snapshot.data![index].languages.map((e) => e.value).join(", ")}, currencies ${snapshot.data![index].currencies.map((e) => e.value).join(", ")}"),
                    ),
                  ],
                ),
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
    try {
      List<Pin> pins = await PinDao().listAll();
      return pins;
    } catch (err) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }
    return [];
  }

  Widget _mapBuilder(BuildContext ctx, AsyncSnapshot<List<Pin>> snapshot) {
    if (snapshot.hasData) {
      return MapWidget(
        padding: const EdgeInsets.only(left: 10, right: 10),
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

  void _import() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ["csv"]);

    if (result != null) {
      List<Pin> pins = await FileContentLoader()
          .convertToList(result.files[0].path!, ImportFileType.csv);
      for (Pin pin in pins) {
        try {
          await PinService().insertPin(pin);
        } catch (err) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Something went wrong")));
        }
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Places importation completed")));
      setState(() {});
    }
  }

  void _export() async {
    String? filePathAndName = await FilePicker.platform
        .saveFile(type: FileType.custom, allowedExtensions: ["csv"]);
    if (filePathAndName != null) {
      FileContentGenerator fileGenerator = FileContentGenerator();
      List<Pin> pins = await PinDao().listAll();
      Uint8List data =
          await fileGenerator.convertToUint8List(pins, FileImportType.csv);
      final file = File("$filePathAndName.${FileImportType.csv.name}");
      await file.writeAsBytes(data);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Places exportation completed")));
    }
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
            icon: const Icon(
              Icons.help,
            ),
          ),
          TextButton(
            onPressed: _import,
            child: const Row(
              children: [
                Text("Import"),
                Icon(Icons.subdirectory_arrow_left),
              ],
            ),
          ),
          TextButton(
            onPressed: _export,
            child: const Row(
              children: [Icon(Icons.subdirectory_arrow_right), Text("Export")],
            ),
          ),
          IconButton(onPressed: _chooseAPlace, icon: const Icon(Icons.add)),
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
                      CommonWrappers.infoPane(
                          TotalCountriesInfoWidget().pieChartTotalCountries()),
                      CommonWrappers.infoPane(
                          TotalCapitalsInfoWidget().pieChartTotalCapitals()),
                      CommonWrappers.infoPane(
                          CountRegionsInfoWidget().regionsWidget()),
                      CommonWrappers.infoPane(
                          CountCountriesInfoWidget().countriesWidget()),
                      CommonWrappers.infoPane(
                          CountDistrictsInfoWidget().districtsWidget()),
                      CommonWrappers.infoPane(
                          CountCitiesInfoWidget().citiesWidget()),
                      CommonWrappers.infoPane(
                          CountPinsInfoWidget().pinsWidget()),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Countries",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<CountryFullData>>(
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
}
