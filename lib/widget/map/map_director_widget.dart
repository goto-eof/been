import 'package:been/model/pin.dart';
import 'package:been/widget/map/map_widget.dart';
import 'package:been/widget/map/search_address_widget.dart';
import 'package:flutter/material.dart';

class MapDirectorWidget extends StatefulWidget {
  const MapDirectorWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MapDirectorWidgetState();
  }
}

class _MapDirectorWidgetState extends State<MapDirectorWidget> {
  Pin currentPosition = Pin(longitude: 0, latitude: 0, address: "Unknown");
  Function(Pin pin)? updateMapCallback;

  void _setPin(Pin pin) {
    setState(() {
      currentPosition = pin;
    });
    if (updateMapCallback != null) {
      updateMapCallback!(pin);
    }
  }

  void _setUpdateMapCallback(Function(Pin pin) updateMapCallbackIn) {
    updateMapCallback = updateMapCallbackIn;
  }

  void _selectPosition() {
    Navigator.of(context).pop(currentPosition);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SearchAddressWidget(setPin: _setPin),
          MapWidget(
            currentPosition: currentPosition,
            setUpdateMapCallback: _setUpdateMapCallback,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilledButton(
                onPressed: _selectPosition, child: const Text("Save position")),
          )
        ],
      ),
    );
  }
}
