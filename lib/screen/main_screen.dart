import 'package:been/model/pin.dart';
import 'package:been/screen/pin_screen.dart';
import 'package:been/screen/place_details.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  List<Pin> places = [];

  _chooseAPlace() async {
    Pin? pin =
        await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return PinScreen();
    }));
    if (pin != null) {
      setState(() {
        places.add(pin);
      });
    }
  }

  _goToPlaceDetails(Pin pin) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlaceDetails(pin: pin),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Been! "),
        actions: [IconButton(onPressed: _chooseAPlace, icon: Icon(Icons.add))],
      ),
      drawer: Drawer(),
      body: ListView.builder(
        itemBuilder: (BuildContext ctx, int index) {
          return Card(
            child: Row(
              children: [
                InkWell(
                    onTap: () {
                      _goToPlaceDetails(places[index]);
                    },
                    child: Card(child: Text(places[index].address)))
              ],
            ),
          );
        },
        itemCount: places.length,
      ),
      bottomNavigationBar: BottomNavigationBar(currentIndex: 0, items: const [
        BottomNavigationBarItem(icon: Icon(Icons.abc), label: "Cioa"),
        BottomNavigationBarItem(icon: Icon(Icons.abc), label: "Yahoo")
      ]),
    );
  }
}
