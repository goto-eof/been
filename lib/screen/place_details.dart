import 'package:been/model/pin.dart';
import 'package:flutter/material.dart';

class PlaceDetails extends StatefulWidget {
  const PlaceDetails({super.key, required this.pin});
  final Pin pin;

  @override
  State<StatefulWidget> createState() {
    return _PlaceDetailsStatus();
  }
}

class _PlaceDetailsStatus extends State<PlaceDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Text(widget.pin.address),
    );
  }
}
