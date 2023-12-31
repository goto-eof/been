import 'package:been/dao/city_dao.dart';
import 'package:flutter/material.dart';

class CountCitiesInfoWidget {
  Widget citiesWidget({int? districtId}) {
    return FutureBuilder(
        future: _countCities(districtId: districtId),
        builder: _countCitiesBuilder);
  }

  Future<int> _countCities({int? districtId}) async {
    if (districtId != null) {
      return await CityDao().countByDistrict(districtId);
    }
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
}
