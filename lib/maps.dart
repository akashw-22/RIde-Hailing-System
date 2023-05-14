import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'googleMap.dart';
import 'secrets.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'tokenContract.dart';
import 'riderContract.dart';

// import 'package:google_maps_webservice/directions.dart' as dir;
late GoogleMapController mapController;

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});
  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  String apiKey = GOOGLE_MAPS_API_KEY;
  // late dir.DirectionsResponse _directions;
  late String distance = '0';
  late String duration = '0';

  late Position position;
  late LatLng _currentLocation = LatLng(11.2588, 75.7804);

  late BitmapDescriptor userLocationIcon;

  @override
  void initState() {
    print('Inside Init State');
    _getCurrentLocation();
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'assets/Icons/UserLocation.png')
        .then((icon) {
      userLocationIcon = icon;
      print("End of Init State in maps.dart");
    });
  }

  void _getCurrentLocation() async {
    // print(_currentLocation);
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      marker.add(
          Marker(markerId: MarkerId('Source'), position: _currentLocation));
      print("Added Source as currentLocation");
    });
  }

  // bool destination = false;
  bool _visible = false;
  bool _showRouteDetails = false;
  bool _showPickupLocationMessage = false;
  Set<Marker> marker = {};

  void _setDestination(LatLng latLng) {
    // print(marker);
    setState(() {
      // widgetList.add(Card(child: Text('Test'),));

      marker.add(Marker(markerId: MarkerId('Destination'), position: latLng));
      _visible = true;
      _showRouteDetails = false;
    });
  }

  late Polyline polyline = Polyline(polylineId: PolylineId('null'));

  void getRoute() async {
    print("Inside getRoute function");
    late LatLng destination;
    // LatLng source = currentlocation;
    late LatLng source;

    for (var i in marker) {
      if (i.markerId == MarkerId('Destination')) {
        destination = i.position;
        break;
      }
    }

    for (var i in marker) {
      if (i.markerId == MarkerId('Source')) {
        source = i.position;
        break;
      }
    }

    String directionsUrl =
        "https://maps.googleapis.com/maps/api/directions/json";
    String _source =
        source.latitude.toString() + ',' + source.longitude.toString();
    String _destination = destination.latitude.toString() +
        ',' +
        destination.longitude.toString();
    Uri uri = Uri.parse(
        "$directionsUrl?origin=$_source&destination=$_destination&key=$GOOGLE_MAPS_API_KEY");
    Response response = await get(uri);

    // print(response.statusCode);
    final routeDetails = jsonDecode(response.body);
    // print(routeDetails);
    distance = routeDetails['routes'][0]['legs'][0]['distance']['text'];
    duration = routeDetails['routes'][0]['legs'][0]['duration']['text'];
    final decPolyline = PolylinePoints().decodePolyline(
        routeDetails['routes'][0]['overview_polyline']['points']);

    List<LatLng> points = [];

    for (var i in decPolyline) {
      points.add(LatLng(i.latitude, i.longitude));
    }

    setState(() {
      polyline = Polyline(polylineId: PolylineId('route'), points: points);
      showContainer = true;
      _visible = false;
    });
  }

  void _setPickupLocation(LatLng latLng) {
    print('inside setPickuplocation');
    setState(() {
      print("inside setstate of _setPickupLocation");

      marker.removeWhere((element) => element.markerId == MarkerId('Source'));
      marker.add(Marker(
          markerId: MarkerId('Source'),
          position: latLng,
          icon: userLocationIcon));
      getRoute();
    });
  }

  void sendBookingDetails() async {
    print('Inside sendBookingDetails');
    // final client = Web3Client(rpcUrl, Client());
    // // print(cline)
    // final credentials = EthPrivateKey.fromHex(hardPrivateKey);
    // // print("Credentials: ${credentials.address}");

    // final byteData = await rootBundle.load('assets/Abi/abi.json');
    // final abiCode = utf8.decode(byteData.buffer.asUint8List());
    // // print("Json String: $jsonString");
    // final contract = DeployedContract(ContractAbi.fromJson(abiCode, 'RideBooking'), rideBookingcontractAddress);
    // final requestRide = contract.function('requestRide');

    LatLng source = marker
        .where((element) {
          return (element.markerId == MarkerId('Source'));
        })
        .first
        .position;
    LatLng destination = marker
        .where((element) {
          return (element.markerId == MarkerId('Destination'));
        })
        .first
        .position;

    // print("Source: ${source.longitude * 100000000000000}");

    await giveApproval();

    try {
      await requestRide(
          source.longitude.toString(),
          source.latitude.toString(),
          destination.longitude.toString(),
          destination.latitude.toString(),
          (BigInt.from(double.parse(distance.split(' ').first) * 10)));

      setState(() {
        messageIndex = 2;
      });
      getDrivers();
    } catch (err) {
      print("ERROR RequestRide: $err");
    }
  }

  // void kotham(){
  //   setState;
  // }

  late Function _onTap = _setDestination;
  int messageIndex = 0;
  bool showContainer = false;

  late List<Widget> widgetList;
  late List<List<dynamic>> drivers = [];

  void selectedDriver(BigInt bidIndex)async {
    print('Driver Selected');
    print('Bid Index: $bidIndex');

    BigInt rideId = await getCurrentRideId();
    await selectDriver(rideId, bidIndex);

    setState(() {
      messageIndex = 4;
    });

    getRideStatus();


  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    super.build(context);
    double screenWidth = MediaQuery.of(context).size.width;
    GoogleMap map = googleMap(_currentLocation, marker, polyline, _onTap);

    print('Rebuilding');
    return Stack(children: [
      map,
      Positioned(
        bottom: MediaQuery.of(context).padding.bottom,
        left: 0,
        right: 0,
        child: Column(
          children: [
            //Set Destination Button
            Visibility(
                visible: _visible,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        // elevation: 20,
                      ),
                      onPressed: () {
                        getRoute();
                        setState(() {
                          messageIndex = 0;
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Set Destination"),
                      ),
                    ),
                  ),
                )),

            // Container for displaying messages
            Visibility(
              visible: showContainer,
              child: Container(
                constraints: BoxConstraints(maxHeight: 300),
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    boxShadow: [BoxShadow(blurRadius: 20)]),
                child: IndexedStack(
                    alignment: AlignmentDirectional.center,
                    index: messageIndex,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                    text: 'Trip Details:\n',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                          text:
                                              'Distance: $distance\nDuration: $duration')
                                    ])),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _onTap = _setPickupLocation;
                                  // polyline =
                                  //     Polyline(polylineId: PolylineId('null'));
                                  print(
                                      "Inside set State of Confirm Booking button");
                                  messageIndex = 1;
                                });
                              },
                              child: Text('Confirm Booking'))
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: RichText(
                                  textAlign: TextAlign.right,
                                  text: TextSpan(
                                    text: 'Select Your Pickup Location',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                // elevation: 20,
                              ),
                              onPressed: () {
                                sendBookingDetails();
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(20),
                                child: Text("Confirm Booking"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('Waiting for drivers to accept...')),
                      // Text('Accepted Drivers', style: TextStyle(fontSize: 20),),
                      ListView.builder(
                          itemCount: drivers.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                selectedDriver(drivers[index][3]);
                              },
                              child: Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 30.0,
                                    backgroundImage: AssetImage(
                                        'assets/Icons/BusDriver.png'),
                                  ),
                                  title: Text('Driver Name: ${drivers[index][0]}'),
                                  subtitle: Text('''Bid Amount: ${drivers[index][1]}\n
                                  Car Model: ${drivers[index][2]}\n
                                  ''')
                                ),
                              ),
                            );
                          }),
                          Text('Waiting for driver to arrive at your location....'),
                          Text('Ride In Progress...'),
                          Text('Ride Completed')
                    ]),
              ),
            ),
          ],
        ),
      ),
      SafeArea(
          minimum: EdgeInsets.only(top: 50, left: 10, right: 10),
          child: Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: CircleBorder(), elevation: 10),
                child: Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Icon(Icons.arrow_back, size: 30),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide()),
                      hintText: 'Enter Destination',
                    ),
                  ),
                ),
              ),
            ],
          )),
    ]);
  }
}

extension _MapsPageStateExtension on _MapsPageState {
  void getDrivers() async {
    await init();

    print("In getDrivers... Listening....");
    final rideAcceptedEvent = contract.event('RideAccepted');

    await client.events(FilterOptions.events(contract: contract, event: rideAcceptedEvent))
    .take(2)
    .listen((event){

      print("event triggered.");
      final decoded = rideAcceptedEvent.decodeResults(event.topics, event.data);
      
      final driverName = decoded[0] as String;
      print(driverName);
      final bidAmount = decoded[1] as BigInt;
      print(bidAmount);
      final carModel = decoded[2] as String;
      print(carModel);
      final bidIndex = decoded[3] as BigInt;
      print(bidIndex);

      List<dynamic> driverDetails = [];
      driverDetails.addAll([driverName, bidAmount, carModel, bidIndex]);

      setState(() {
        messageIndex = 3;
        drivers.add(driverDetails);
      });

    });
  }

  void getRideStatus() async{
    await init();
    final rideStartedEvent = contract.event('RideStarted');
    final rideCompletedEvent = contract.event('RideCompleted');

    print("Inside getRideStatus");
    await client.events(FilterOptions.events(contract: contract, event: rideStartedEvent))
    .take(1)
    .listen((event){

      print("Listening....");
      setState(() {
        messageIndex = 5;
      });
    });

    await client.events(FilterOptions.events(contract: contract, event: rideCompletedEvent))
    .take(1)
    .listen((event){
      print("Inside Ride Completed");

      setState(() {
        messageIndex = 6;
      });
    });
  }

  void getCompleted() async{
    await init();
    final rideStartedEvent = contract.event('RideStarted');

    print("Inside getRideStatus");
    await client.events(FilterOptions.events(contract: contract, event: rideStartedEvent))
    .take(1)
    .listen((event){

      print("Listening....");
      setState(() {
        messageIndex = 5;
      });
    });
  }
}
