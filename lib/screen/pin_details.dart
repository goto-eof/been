import 'package:been/model/pin.dart';
import 'package:been/widget/map/map_widget.dart';
import 'package:flutter/material.dart';

class PinDetails extends StatelessWidget {
  PinDetails({super.key, required this.pin});
  Pin pin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(pin.address),
          ),
          MapWidget(
            currentPosition: pin,
            zoom: 16,
          ),
        ],
      ),
    );
  }
}
