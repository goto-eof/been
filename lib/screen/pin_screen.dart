import 'package:been/dao/pin_dao.dart.dart';
import 'package:been/model/city.dart';
import 'package:been/model/country_full_data.dart';
import 'package:been/model/district.dart';
import 'package:been/model/pin.dart';
import 'package:been/screen/pin_details.dart';
import 'package:flutter/material.dart';

class PinScreen extends StatefulWidget {
  const PinScreen(
      {super.key,
      required this.city,
      required this.district,
      required this.country});
  final City city;
  final District district;
  final CountryFullData country;
  @override
  State<StatefulWidget> createState() {
    return _PinScreenState();
  }
}

class _PinScreenState extends State<PinScreen> {
  Future<List<Pin>> _future() async {
    return await PinDao().list(widget.city.id!);
  }

  Widget _builder(context, snapshot) {
    if (snapshot.hasError) {
      return const Center(
        child: Text("Error"),
      );
    }

    if (snapshot.hasData) {
      return ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (context, index) => Card(
          child: InkWell(
            onTap: () async {
              bool? deleted = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PinDetails(pin: snapshot.data![index]),
                ),
              );
              if (deleted != null && deleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("PIN deleted successfully"),
                  ),
                );
                setState(() {});
              }
            },
            child: ListTile(
              leading: const Icon(Icons.square),
              subtitle: const Text("Place"),
              title: Text(
                snapshot.data[index].address,
              ),
            ),
          ),
        ),
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
        title: Text(
            "${widget.country.name} > ${widget.district.name} > ${widget.city.name}"),
      ),
      body: FutureBuilder<List<Pin>>(
        builder: _builder,
        future: _future(),
      ),
    );
  }
}
