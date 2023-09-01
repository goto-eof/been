import 'package:been/model/pin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MapStateObjects { currentPosition }

class MapStateNotifier extends StateNotifier<Map<MapStateObjects, dynamic>> {
  MapStateNotifier()
      : super(
          {
            MapStateObjects.currentPosition:
                Pin(longitude: 0, latitude: 0, address: ""),
          },
        );

  void setData(MapStateObjects key, dynamic value) {
    state = {...state, key: value};
  }
}

final mapProvider =
    StateNotifierProvider<MapStateNotifier, Map<MapStateObjects, dynamic>>(
        (ref) => MapStateNotifier());
