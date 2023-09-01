
import 'package:been/model/pin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const urlTemplate = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";

class MapWidget extends StatefulWidget {
  const MapWidget(
      {super.key,
      required this.currentPosition,
      this.setUpdateMapCallback,
      this.zoom,
      this.markers});
  final Pin currentPosition;
  final List<Pin>? markers;
  final double? zoom;
  final Function(Function(Pin pin) function)? setUpdateMapCallback;

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
        _mapController!.move(LatLng(pin.latitude, pin.longitude), 10.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        child: FlutterMap(
          options: MapOptions(
              center: LatLng(widget.currentPosition.latitude,
                  widget.currentPosition.longitude),
              zoom: widget.zoom ?? 10.0,
              maxZoom: 18,
              minZoom: 1),
          mapController: _mapController,
          children: [
            TileLayer(
              urlTemplate: urlTemplate,
              subdomains: const ['a', 'b', 'c'],
              backgroundColor: const Color.fromARGB(154, 0, 0, 0),
            ),
            MarkerLayer(
                markers: (widget.markers ?? [])
                    .map(
                      (e) => Marker(
                        point: LatLng(e.latitude, e.longitude),
                        builder: (context) => const Icon(
                          Icons.location_on,
                          color: Colors.red,
                        ),
                      ),
                    )
                    .toList())
          ],
        ),
      ),
    );
  }
}
