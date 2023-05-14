import 'package:flutter/material.dart';
import 'maps.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'googleMap.dart';

class BigCard extends StatefulWidget {
  BigCard({super.key});

  @override
  State<BigCard> createState() => _BigCardState();
}

class _BigCardState extends State<BigCard> with AutomaticKeepAliveClientMixin {
  late GoogleMapController _mapController;
  bool get wantKeepAlive => true;

  void _onMapCreated(controller) async {
    mapController = controller;
    mapController.setMapStyle(
        '[{"featureType": "poi","stylers": [{"visibility": "off"}]}]');
    Position _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
        color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w700);
    return SafeArea(
      child: ListView(
        children: [
          // const Card(
          //     elevation: 10,
          //     child: Padding(
          //       padding: EdgeInsets.all(19.0),
          //       child: Text('This is the home page'),
          //     )),
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Scaffold(
                              body: MapsPage(),
                            )));
    
              },
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width / 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: IgnorePointer(child: googleMap(null, {Marker(markerId: MarkerId('NullMarker'))}, null, {})),
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
