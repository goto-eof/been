import 'package:been/widget/map/map_director_widget.dart';
import 'package:flutter/material.dart';

class PinRetrieverScreen extends StatefulWidget {
  const PinRetrieverScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PinRetrieverScreenState();
  }
}

class _PinRetrieverScreenState extends State<PinRetrieverScreen> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: Scaffold(body: MapDirectorWidget()));
  }
}
