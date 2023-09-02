import 'package:been/dao/country_dao.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class TotalCountriesInfoWidget {
  Widget pieChartTotalCountries() {
    return FutureBuilder(
      builder: _totalCountriesBuilder,
      future: _totalCountriesCount(),
    );
  }

  Future<int> _totalCountriesCount() async {
    return await CountryDao().count();
  }

  Widget _totalCountriesBuilder(BuildContext ctx, AsyncSnapshot<int> snapshot) {
    if (snapshot.hasData) {
      Map<String, double> dataMap = {
        "Unvisited countries": double.parse((195 - snapshot.data!).toString()),
        "Visited countries": double.parse(snapshot.data.toString()),
      };

      // Colors for each segment
      // of the pie chart
      List<Color> colorList = [
        const Color(0xffD95AF3),
        const Color(0xff3EE094),
        const Color(0xff3398F6),
        const Color(0xffFA4A42),
        const Color(0xffFE9539)
      ];

      // List of gradients for the
      // background of the pie chart
      final gradientList = <List<Color>>[
        [
          const Color.fromRGBO(255, 0, 0, 1),
          const Color.fromRGBO(253, 113, 91, 1),
        ],
        [
          const Color.fromRGBO(223, 250, 92, 1),
          const Color.fromRGBO(129, 250, 112, 1),
        ],
      ];
      return Center(
        child: PieChart(
          // Pass in the data for
          // the pie chart
          dataMap: dataMap,
          // Set the colors for the
          // pie chart segments
          colorList: colorList,
          // Set the radius of the pie chart
          chartRadius: 200,
          // Set the center text of the pie chart
          centerText: "Countries",
          // Set the width of the
          // ring around the pie chart
          ringStrokeWidth: 24,
          // Set the animation duration of the pie chart
          animationDuration: const Duration(seconds: 3),
          // Set the options for the chart values (e.g. show percentages, etc.)
          chartValuesOptions: const ChartValuesOptions(
              showChartValues: true,
              showChartValuesOutside: true,
              showChartValuesInPercentage: true,
              showChartValueBackground: true),
          // Set the options for the legend of the pie chart
          legendOptions: const LegendOptions(
              showLegends: true,
              legendShape: BoxShape.circle,
              legendTextStyle: TextStyle(fontSize: 10),
              legendPosition: LegendPosition.top,
              showLegendsInRow: true),
          // Set the list of gradients for
          // the background of the pie chart
          gradientList: gradientList,
        ),
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
