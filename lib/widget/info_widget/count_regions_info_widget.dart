import 'package:been/dao/country_dao.dart';
import 'package:been/model/country.dart';
import 'package:been/util/country_util.dart';
import 'package:flutter/material.dart';

class CountRegionsInfoWidget {
  Widget regionsWidget() {
    return FutureBuilder(
        future: _countRegions(), builder: _countRegionsBuilder);
  }

  Future<int> _countRegions() async {
    Map<String, String> countryRegionMap = {};

    for (var country in (await CountryUtil().loadCountriesData())) {
        countryRegionMap.putIfAbsent(
            country.commonName.toLowerCase(), () => country.region);
      }

    List<Country> countries = await CountryDao().list();

    Map<String, int> continentCountMap = {};
    for (var country in countries) {
      continentCountMap.putIfAbsent(
          countryRegionMap[country.name.toLowerCase()]!, () => 1);
    }

    int regions = 0;
    for (var element in continentCountMap.entries) {
      regions += continentCountMap[element.key]!;
    }

    return regions;
  }

  Widget _countRegionsBuilder(BuildContext ctx, AsyncSnapshot<int> snapshot) {
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
                color: Color.fromARGB(255, 244, 54, 120),
              ),
              Column(
                children: [
                  Text(
                    snapshot.data!.toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 244, 54, 120),
                        fontSize: 52),
                  ),
                  const Text(
                    "Continents",
                    style: TextStyle(
                      color: Color.fromARGB(255, 244, 54, 120),
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
