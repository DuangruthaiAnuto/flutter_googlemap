import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

import 'network.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Set<Polygon> _polygons = HashSet<Polygon>();
  Set<Polyline> polyLines = {};
  List<LatLng> polyPoints = [];
  BitmapDescriptor destinationIcon;

  LocationData currentLocation;
  Location location;
  BitmapDescriptor currentLocationIcon;
  var data;

  static final CameraPosition _kGreenWay = CameraPosition(
    target: LatLng(6.99714999917583, 100.48702882958986),
    zoom: 17.4746,
  );

  static final CameraPosition _kPark = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(7.041029549762928, 100.51037060193352),
      //tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  static final CameraPosition _kAsean = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(6.995139356171223, 100.48461619714016),
      //tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  void _setCustomMapPin() async {
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'images/destination_map_marker.png');
  }

  @override
  void initState() {
    super.initState();

    location = new Location();

    location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      updatePinOnMap();
    });

    _setCustomMapPin();
    _setPolygonsGreenWay();
    _setCurrentLationIcons();
    _getJsonData();
  }

  _setPolyLines() {
    Polyline polyline = Polyline(
      polylineId: PolylineId("polyline"),
      color: Colors.lightGreenAccent,
      points: polyPoints,
    );
    polyLines.add(polyline);
    setState(() {});
  }

  void updatePinOnMap() async {
    setState(() {
      // updated position
      var pinPosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);

      _markers.removeWhere((m) => m.markerId.value == 'currentLocationPin');
      _markers.add(Marker(
        markerId: MarkerId('currentLocationPin'),
        position: pinPosition,
        icon: currentLocationIcon,
        infoWindow:
            InfoWindow(title: "Current Location", snippet: "I am here now!"),
        //icon: BitmapDescrip
      ));
    });
  }

  void _setCurrentLationIcons() async {
    currentLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'images/driving_pin.png');
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("My Map"),
        actions: [
          IconButton(icon: Icon(Icons.store), onPressed: _goToGreenWay),
          IconButton(icon: Icon(Icons.car_rental), onPressed: _goToPark),
          IconButton(icon: Icon(Icons.storefront), onPressed: _goToAsean),
        ],
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGreenWay,
        markers: _markers,
        polygons: _polygons,
        polylines: polyLines,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _onMapCreate(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToPark,
        label: Text('To the park'),
        icon: Icon(Icons.car_rental),
      ),
    );
  }

  void _setPolygonsGreenWay() {
    // ignore: deprecated_member_use
    List<LatLng> polygonLatLongsCS = List<LatLng>();
    polygonLatLongsCS.add(LatLng(6.997185076245782, 100.4864732725926));
    polygonLatLongsCS.add(LatLng(6.997163007477395, 100.48723386408388));
    polygonLatLongsCS.add(LatLng(6.996960036905363, 100.48723897642296));
    polygonLatLongsCS.add(LatLng(6.99664881519021, 100.4870890144766));
    polygonLatLongsCS.add(LatLng(6.996708014988971, 100.48689133736549));
    polygonLatLongsCS.add(LatLng(6.996833180253044, 100.48688111268733));
    polygonLatLongsCS.add(LatLng(6.996848403052525, 100.48645508443227));
    polygonLatLongsCS.add(LatLng(6.996848403052525, 100.48645508443227));
    _polygons.add(
      Polygon(
          polygonId: PolygonId("0"),
          points: polygonLatLongsCS,
          fillColor: Colors.orangeAccent,
          strokeWidth: 3,
          strokeColor: Colors.black),
    );
  }

  void _onMapCreate(GoogleMapController controller) {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('1'),
          position: LatLng(6.99714999917583, 100.48702882958986),
          icon: BitmapDescriptor.defaultMarkerWithHue(80),
          onTap: () =>
              _openOnGoogleMapApp(6.99714999917583, 100.48702882958986),
          infoWindow:
              InfoWindow(title: "Green Way", snippet: "Go to Shopping.")));

      _markers.add(Marker(
          markerId: MarkerId('2'),
          position: LatLng(7.041029549762928, 100.51037060193352),
          icon: destinationIcon,
          infoWindow: InfoWindow(
              title: "The park", snippet: "Go to See the scenery.")));

      _markers.add(Marker(
          markerId: MarkerId('3'),
          position: LatLng(6.995139356171223, 100.48461619714016),
          icon: BitmapDescriptor.defaultMarkerWithHue(50),
          infoWindow:
              InfoWindow(title: "The Asean", snippet: "Go to Shopping.")));
    });
  }

  _openOnGoogleMapApp(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      // Could not open the map.
    }
  }

  Future<void> _goToPark() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kPark));
  }

  Future<void> _goToGreenWay() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kGreenWay));
  }

  Future<void> _goToAsean() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kAsean));
  }

  Future<LocationData> getCurrentLocation() async {
    Location location = Location();

    return await location.getLocation();
  }

  void _getJsonData() async {
    // Create an instance of Class NetworkHelper which uses http package
    // for requesting data to the server and receiving response as JSON format

    NetworkHelper network = NetworkHelper(
      startLat: 6.997330724551602,
      startLng: 100.4870184683041,
      endLat: 7.041029549762928,
      endLng: 100.51037060193352,
    );
    try {
      // getData() returns a json Decoded data
      data = await network.getData();
      print(data);
      LineString ls =
          LineString(data['features'][0]['geometry']['coordinates']);
      for (int i = 0; i < ls.lineString.length; i++) {
        polyPoints.add(LatLng(ls.lineString[i][1], ls.lineString[i][0]));
      }
      _setPolyLines();
    } catch (e) {
      print(e);
    }
  }
}

class LineString {
  LineString(this.lineString);
  List<dynamic> lineString;
}
