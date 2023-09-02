import 'package:been/dao/district_dao.dart';
import 'package:flutter/material.dart';

class CountDistrictsInfoWidget {
  Widget districtsWidget() {
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
}
