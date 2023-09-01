import 'dart:async';
import 'dart:convert';

import 'package:been/model/pin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchAddressWidget extends StatefulWidget {
  SearchAddressWidget({super.key, required this.setPin});
  void Function(Pin pin) setPin;
  @override
  State<StatefulWidget> createState() {
    return _SearchAddressWidgetState();
  }
}

class _SearchAddressWidgetState extends State<SearchAddressWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  List<Pin> _options = <Pin>[];
  void _onChange(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      try {
        String url =
            'https://nominatim.openstreetmap.org/search?q=$value&format=json&polygon_svg=0&addressdetails=1';
        var response = await http.get(Uri.parse(url));
        var decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        _options = decodedResponse
            .map(
              (e) => Pin(
                address: e['display_name'],
                city: e["address"]["city"],
                region: e["address"]["state"],
                country: e["address"]["country"],
                latitude: double.parse(e['lat']),
                longitude: double.parse(
                  e['lon'],
                ),
              ),
            )
            .toList();

        if (_options.isNotEmpty) {
          widget.setPin(_options[0]);
        }

        setState(() {});
      } finally {}

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder inputBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromARGB(31, 255, 0, 0)),
    );
    OutlineInputBorder inputFocusBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromARGB(31, 255, 0, 0), width: 3.0),
    );
    return TextField(
        controller: _searchController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: "Input a city",
          border: inputBorder,
          focusedBorder: inputFocusBorder,
        ),
        onChanged: _onChange);
  }
}
