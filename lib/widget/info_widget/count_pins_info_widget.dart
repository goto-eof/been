import 'package:been/dao/pin_dao.dart.dart';
import 'package:flutter/material.dart';

class CountPinsInfoWidget {
  Widget pinsWidget() {
    return FutureBuilder(future: _countPins(), builder: _countPinsBuilder);
  }

  Future<int> _countPins() async {
    return await PinDao().count();
  }

  Widget _countPinsBuilder(BuildContext ctx, AsyncSnapshot<int> snapshot) {
    if (snapshot.hasData) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_history,
                  size: 100, color: Color.fromARGB(255, 244, 143, 54)),
              Column(
                children: [
                  Text(
                    snapshot.data!.toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 244, 143, 54),
                        fontSize: 52),
                  ),
                  const Text(
                    "Pins",
                    style: TextStyle(
                      color: Color.fromARGB(255, 244, 143, 54),
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
