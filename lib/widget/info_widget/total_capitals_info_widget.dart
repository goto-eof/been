import 'package:been/dao/pin_dao.dart.dart';
import 'package:been/model/key_value.dart';
import 'package:been/util/capitals_util.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class TotalCapitalsInfoWidget {
  Widget pieChartTotalCapitals() {
    return FutureBuilder(
      builder: _totalCapitalsBuilder,
      future: _readCapitalsJson(),
    );
  }

  Future<KeyValue<int, int>> _readCapitalsJson() async {
    await CapitalsUtil().loadCountriesData();
    List<KeyValue<String, String>> result =
        await CapitalsUtil().loadCountries();
    Set<String> allCapitals = result
        .where((element) => element.value != null)
        .map((e) => e.value!.toLowerCase())
        .toSet();
    Set<String> citiesBeen = (await PinDao().listAll())
        .map((pin) => pin.city!.toLowerCase())
        .toSet();

    int been = 0;
    for (String cityBeen in citiesBeen) {
      if (allCapitals.contains(cityBeen)) {
        been++;
      }
    }

    return KeyValue(key: allCapitals.length, value: been);
  }

  Widget _totalCapitalsBuilder(
      BuildContext ctx, AsyncSnapshot<KeyValue> snapshot) {
    if (snapshot.hasData) {
      Map<String, double> dataMap = {
        "Unvisited Capitals": double.parse(
            (snapshot.data!.key - snapshot.data!.value).toString()),
        "Visited Capitals": double.parse(snapshot.data!.value.toString()),
      };

      List<Color> colorList = [
        const Color(0xffD95AF3),
        const Color(0xff3EE094),
        const Color(0xff3398F6),
        const Color(0xffFA4A42),
        const Color(0xffFE9539)
      ];

      final gradientList = <List<Color>>[
        [
          const Color.fromRGBO(255, 0, 0, 1),
          const Color.fromRGBO(253, 113, 91, 1),
        ],
        [
          const Color.fromARGB(255, 159, 30, 234),
          const Color.fromARGB(255, 143, 60, 237),
        ],
      ];
      return Center(
        child: PieChart(
          dataMap: dataMap,
          colorList: colorList,
          chartRadius: 200,
          centerText: "Capitals (${snapshot.data!.key})",
          ringStrokeWidth: 24,
          animationDuration: const Duration(seconds: 3),
          chartValuesOptions: const ChartValuesOptions(
              showChartValues: true,
              showChartValuesOutside: true,
              showChartValuesInPercentage: true,
              showChartValueBackground: true),
          legendOptions: const LegendOptions(
              showLegends: true,
              legendShape: BoxShape.circle,
              legendTextStyle: TextStyle(fontSize: 10),
              legendPosition: LegendPosition.top,
              showLegendsInRow: true),
          gradientList: gradientList,
        ),
      );
    }
    if (snapshot.hasError) {
      return Center(
        child: Text("Error: ${snapshot.error.toString()}"),
      );
    }
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
