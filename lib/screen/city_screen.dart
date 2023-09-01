import 'package:been/dao/city_dao.dart';
import 'package:been/model/city.dart';
import 'package:been/model/district.dart';
import 'package:been/screen/pin_screen.dart';
import 'package:flutter/material.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key, required this.region});
  final District region;

  @override
  State<StatefulWidget> createState() {
    return _CityScreenStatus();
  }
}

class _CityScreenStatus extends State<CityScreen> {
  Widget _builder(BuildContext ctx, AsyncSnapshot<List<City>> snapshot) {
    if (snapshot.hasError) {
      return const Center(
        child: Text("Err"),
      );
    }
    if (snapshot.hasData) {
      return ListView.builder(
        itemBuilder: (BuildContext ctx, int index) {
          return Card(
            child: InkWell(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PinScreen(city: snapshot.data![index]),
                ));
                setState(() {});
              },
              child: ListTile(
                leading: const Icon(Icons.square),
                title: Text(snapshot.data![index].name),
                subtitle: const Text("City/County"),
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

    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<List<City>> _future() async {
    CityDao cityDao = CityDao();
    List<City> cities = await cityDao.byRegion(widget.region);
    for (City city in cities) {
      int numberOfPlaces = await cityDao.getPins(city.id!);
      city.numberOfChilds = numberOfPlaces;
    }
    return cities;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cities/Counties"),
      ),
      body: FutureBuilder<List<City>>(
        builder: _builder,
        future: _future(),
      ),
    );
  }
}
