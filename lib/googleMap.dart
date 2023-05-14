import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

LatLng currentlocation = LatLng(11.2588, 75.7804);

void updateCameraPosition(GoogleMapController mapController) {
    CameraPosition newPosition = CameraPosition(
      target: currentlocation,
      zoom: 17.0,
      tilt: 70,
    );
    mapController.animateCamera(CameraUpdate.newCameraPosition(newPosition));
  }

void _onMapCreated(GoogleMapController controller) async {
    GoogleMapController mapController = controller;
    print('Inside on Map Created');
    mapController.setMapStyle(
        '[{"featureType": "poi","stylers": [{"visibility": "off"}]}]');
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // print(
    // '***************************************test***************************************8');
    currentlocation = LatLng(position.latitude, position.longitude);
    print("Current Location from googleMap File ${currentlocation}");

    updateCameraPosition(mapController);
  }

GoogleMap googleMap(_currentLocation, marker, polyline, _onTap){

  print("Inside googleMap function inside googleMap file");
  return GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentLocation == null? currentlocation: _currentLocation,
          zoom: 17.0,
          tilt: 70,
        ),
        zoomControlsEnabled: false,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        compassEnabled: false,
        onTap: (latlng) => {_onTap(latlng)},
        markers: marker,
        polylines: polyline != null ? {polyline} : {},
      );
}
