import 'package:been/dao/region_dao.dart';
import 'package:been/model/country.dart';
import 'package:been/model/region.dart';
import 'package:been/screen/city_screen.dart';
import 'package:flutter/material.dart';

class RegionScreen extends StatefulWidget {
  const RegionScreen({super.key, required this.country});
  final Country country;

  @override
  State<StatefulWidget> createState() {
    return _RegionScreenState();
  }
}

class _RegionScreenState extends State<RegionScreen> {
  Future<List<Region>> _retrieveRegions() async {
    final String countryName = widget.country.name;
    try {
      RegionDao regionDao = RegionDao();
      List<Region> regions = await regionDao.list(countryName);

      for (Region region in regions) {
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
      return ListView.builder(
        itemBuilder: (BuildContext ctx, int index) {
          return Card(
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CityScreen(
                      region: snapshot.data[index],
                    ),
                  ),
                );
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
        actions: const [],
      ),
      body: FutureBuilder(
        builder: _builder,
        future: _retrieveRegions(),
      ),
    );
  }
}
