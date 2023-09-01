import 'package:been/model/pin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const urlTemplate = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";

class MapWidget extends StatefulWidget {
  MapWidget(
      {super.key, required this.currentPosition, this.setUpdateMapCallback});
  Pin currentPosition;
  Function(Function(Pin pin) function)? setUpdateMapCallback;

  @override
  State<StatefulWidget> createState() {
    return MapWidgetState();
  }
}

class MapWidgetState extends State<MapWidget> {
  MapController? _mapController;

  @override
  void initState() {
    super.initState();
    if (widget.setUpdateMapCallback != null) {
      widget.setUpdateMapCallback!(updateMap);
    }
    _mapController = MapController();
  }

  @override
  void dispose() {
    super.dispose();
    _mapController!.dispose();
  }

  updateMap(Pin pin) {
    if (_mapController != null) {
      setState(() {
        print(pin.address);
        _mapController!.move(LatLng(pin.latitude, pin.longitude), 10.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      height: 300,
      child: FlutterMap(
        options: MapOptions(
            center: LatLng(widget.currentPosition.latitude,
                widget.currentPosition.longitude),
            zoom: 1.0,
            maxZoom: 18,
            minZoom: 1),
        mapController: _mapController,
        children: [
          TileLayer(
            urlTemplate: urlTemplate,
            subdomains: const ['a', 'b', 'c'],
          ),
        ],
      ),
    );
  }
}
