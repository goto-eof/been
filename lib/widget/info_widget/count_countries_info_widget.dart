import 'package:been/dao/country_dao.dart';
import 'package:flutter/material.dart';

class CountCountriesInfoWidget {
  Widget countriesWidget() {
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
}
