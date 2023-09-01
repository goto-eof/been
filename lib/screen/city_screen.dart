import 'package:been/dao/city_dao.dart';
import 'package:been/model/city.dart';
import 'package:been/model/region.dart';
import 'package:flutter/material.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key, required this.region});
  final Region region;

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
            child: Row(
              children: [
                InkWell(
                    onTap: () {
                      // widget.goToDetails(snapshot.data![index]);
                    },
                    child: Card(child: Text(snapshot.data![index].name)))
              ],
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
    return await CityDao().byRegion(widget.region);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<List<City>>(
        builder: _builder,
        future: _future(),
      ),
    );
  }
}
