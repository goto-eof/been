import 'package:been/dao/pin_dao.dart.dart';
import 'package:been/model/pin.dart';
import 'package:been/widget/map/map_widget.dart';
import 'package:flutter/material.dart';

class PinDetails extends StatelessWidget {
  const PinDetails({super.key, required this.pin});
  final Pin pin;

  void _deleteItem(BuildContext ctx) async {
    PinDao().delete(pin.id!).then((value) => Navigator.of(ctx).pop(true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
            onPressed: () {
              _deleteItem(context);
            },
            icon: const Icon(Icons.delete))
      ]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(pin.address),
          ),
          MapWidget(
            currentPosition: pin,
            markers: [pin],
            zoom: 13,
          ),
        ],
      ),
    );
  }
}
