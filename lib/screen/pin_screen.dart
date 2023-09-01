import 'package:been/dao/pin_dao.dart.dart';
import 'package:been/model/city.dart';
import 'package:been/model/pin.dart';
import 'package:been/screen/pin_details.dart';
import 'package:flutter/material.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key, required this.city});
  final City city;
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
        itemBuilder: (context, index) => InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PinDetails(pin: snapshot.data![index]),
              ));
            },
            child: Card(child: Text(snapshot.data[index].address))),
      );
    }
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<List<Pin>>(
        builder: _builder,
        future: _future(),
      ),
    );
  }
}
