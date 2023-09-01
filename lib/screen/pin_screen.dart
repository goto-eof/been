import 'package:been/widget/map/map_director_widget.dart';
import 'package:flutter/material.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PinScreenState();
  }
}

class _PinScreenState extends State<PinScreen> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: Scaffold(body: MapDirectorWidget()));
  }
}
