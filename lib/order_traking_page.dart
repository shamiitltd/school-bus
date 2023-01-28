import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:school_bus/constant.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(37.411, -122.072);
  static const LatLng destination = LatLng(37.4227, -122.084);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentlocationData;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  void getCurrentLocation() async{
    Location location = Location();
    location.getLocation().then((value) {
      setState(() {
        currentlocationData = value;
        getPolyPoints();
      });
    });
    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen((event) {
      setState(() {
        currentlocationData = event;
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(
                  zoom: zoomMap,
                  target: LatLng(currentlocationData!.latitude!, currentlocationData!.longitude!)
              )
          )
        );
      });
    });
  }

  void getPolyPoints() async{
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude)
    );
    if(result.points.isNotEmpty){
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {
        // print(currentlocationData!);
      });
    }

  }

  void setCustomMarkerIcon(){
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/person.png").then((value)
    {
      sourceIcon = value;
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/person.png").then((value)
    {
      destinationIcon = value;
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/bus.png").then((value)
    {
      currentLocationIcon = value;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    getCurrentLocation();
    setCustomMarkerIcon();
    // getPolyPoints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track order",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body:currentlocationData == null
          ? const Center(child: Text("Loading..."),)
          :GoogleMap(
        initialCameraPosition: CameraPosition(
            target: sourceLocation,
            zoom: zoomMap
        ),
        polylines: {
          Polyline(
            polylineId: PolylineId("route"),
            points: polylineCoordinates,
            color: primaryColor,
            width: 6
          )
        },
        markers: {
          Marker(
            icon: currentLocationIcon,
            markerId: MarkerId("currentLocation"),
            position: LatLng(currentlocationData!.latitude!, currentlocationData!.longitude!),
          ),Marker(
            icon: sourceIcon,
            markerId: MarkerId("source"),
            position: sourceLocation,
          ),Marker(
            icon: destinationIcon,
            markerId: MarkerId("destination"),
            position: destination,
          ),
        },
        onMapCreated: (mapController){
          _controller.complete(mapController);
        },
      ),
    );
  }
}
